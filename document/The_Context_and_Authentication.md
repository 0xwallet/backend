# The Context and Authentication

Absinthe 的 context(上下文) 提供了对一个给定的 document(GraphQL 语句) 执行时的共享值.
常用于向一个给定的请求中, 传入当前的用户. 上下文是在调用 `Absinthe.run` 的时候设置的,
并且不可以在执行的过程中修改.

## Basic Usage

举个基本的例子, 用户的个人信息, 我们希望用户可以获得他们自己的基础信息, 但不能获得其他
用户的.

首先, 我们需要一个非常基础的 schema:

```elixir
defmodule MyAppWeb.Schema do
  use Absinthe.Schema

  @fakedb %{
    "1" => %{name: "Bob", email: "bubba@foo.com"},
    "2" => %{name: "Fred", email: "fredmeister@foo.com"},
  }

  query do
    field :profile, :user do
      resolve fn _, _, _ ->
        # How could we get a current user here?
      end
    end
  end

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
  end
end
```

查询语句大概是这样:

```graphql
{
  profile {
    email
  }
}
```

如果我们以 user 1 的身份登录, 我们应该只能得到 user 1 的 email, 例如:

```json
{
  "profile": {
    "email": "bubba@foo.com"
  }
}
```

为了设置上下文, 我们需要这样调用 `Absinthe.run/3` :

```elixir
Absinthe.run(document, MyAppWeb.Schema, context: %{current_user: %{id: "1"}})
```

我们要更新 query 的 reslove 函数, 以使用这个参数:

```elixir
query do
  field :profile, :user do
    resolve fn _, _, %{context: %{current_user: current_user}} ->
      {:ok, Map.get(@fakedb, current_user.id)}
    end
  end
end
```

现在目标达成了!

## Context and Plugs

当使用 Absinthe.Plug 的时候, 我们不需要直接调用 Absinthe.run. 相反
我们使用 `Absinthe.Plug.put_options/2` 来设置上下文.

设置你的 GraphQL 上下文, 就像写一个 plug 来往连接中插入合适的值一样简单.

让我们使用这个机制, 在前面那个例子里, 使用一个身份验证的 header 来设置
current_user. 我们将使用与之前相同的 Schema.

首先是我们的 plug. 我们将会检查 `authorization` header, 然后调用一些
未定义的验证机制.

```elixir
defmodule MyAppWeb.Context do
  @behaviour Plug

  import Plug.Conn
  import Ecto.Query, only: [where: 2]

  alias MyApp.{Repo, User}

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  @doc """
  Return the current user context based on the authorization header
  """
  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
    {:ok, current_user} <- authorize(token) do
      %{current_user: current_user}
    else
      _ -> %{}
    end
  end

  defp authorize(token) do
    User
    |> where(token: ^token)
    |> Repo.one
    |> case do
      nil -> {:error, "invalid authorization token"}
      user -> {:ok, user}
    end
  end

end
```

这个 plug 将会使用 `authorization` header 来寻找当前用户. 如果找到了, 它将被正确
地设置到 absinthe 的上下文. 如果你使用 Guardian 或者其他的 authentication 库, 你也可以
在这里使用它们, 然后将它们的输出加入到 context 即可.

如果没有当前用户, 最好就不要有 `:current_user` 这个 key, 而不是使用 `%{current_user: nil}`.
这样在代码里皆可以直接匹配 `%{current_user: user}` , 且不用担心出错.

使用这个 plug 非常简单. 如果我们有一个普通的 plug 上下文, 我们只要确保它在 Absinthe.Plug 上方即可


```elixir
plug MyAppWeb.Context

plug Absinthe.Plug,
  schema: MyAppWeb.Schema
```

如果你正在使用 Phoenix 路由, 将上下文 plug 加入 pipeline 即可.

```elixir
defmodule MyAppWeb.Router do
  use Phoenix.Router

  resource "/pages", MyAppWeb.PagesController

  pipeline :graphql do
    plug MyAppWeb.Context
  end

  scope "/api" do
    pipe_through :graphql

    forward "/", Absinthe.Plug,
      schema: MyAppWeb.Schema
  end
end
```