defmodule Backend.Accounts.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Accounts

  schema "contacts" do
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

  def changeset(%Accounts.Contact{} = contact, attrs) do
    contact
    |> cast(attrs, [:type, :value, :code, :token])
    |> validate_required([:type, :value])
  end
end