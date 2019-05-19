# defmodule Backend.Content.Post do
#   use Ecto.Schema
#   import Ecto.Changeset

#   alias Backend.{Accounts, Content}

#   schema "posts" do
#     field :body, :string
#     field :published_at, :naive_datetime
#     field :title, :string

#     belongs_to :author, Accounts.User

#     timestamps()
#   end

#   def changeset(attrs) do
#     %__MODULE__{}
#     |> changeset(attrs)
#   end

#   def changeset(%__MODULE__{} = post, attrs) do
#     post
#     |> cast(attrs, [:title, :body, :published_at])
#     |> validate_required([:title, :body])
#   end
# end
