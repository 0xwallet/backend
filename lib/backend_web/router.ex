defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :graphql do
    plug BackendWeb.Context
  end

  scope "/api" do
    pipe_through :graphql

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: BackendWeb.Schema

    forward "/", Absinthe.Plug,
      schema: BackendWeb.Schema
  end
end
