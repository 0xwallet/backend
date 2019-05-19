defmodule Backend.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Accounts

  schema "users" do
    field :type, :string
    field :value, :string
    field :code, :string
    field :token, :string

    # belongs_to :user, Accounts.User

    timestamps()
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
  end

  def changeset(%Accounts.User{} = user, attrs) do
    user
    |> cast(attrs, [:type, :value, :code, :token])
    |> validate_required([:type, :value])
  end
end