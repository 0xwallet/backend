defmodule BackendWeb.Schema.AccountTypes do
  use Absinthe.Schema.Notation

  alias BackendWeb.Resolvers

  @desc "A user"
  object :user do
    field :id, :id
    field :type, :string
    field :value, :string
  end

  # enum :contact_type do
  #   value :phone, as: "phone"
  #   value :email, as: "email"
  # end

  # input_object :contact_input do
  #   field :type, non_null(:contact_type)
  #   field :value, non_null(:string)
  # end
end
