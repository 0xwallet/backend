defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: BackendWeb.Schema

    forward "/", Absinthe.Plug,
      schema: BackendWeb.Schema
  end
end
