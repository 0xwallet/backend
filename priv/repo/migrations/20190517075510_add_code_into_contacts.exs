defmodule Backend.Repo.Migrations.AddCodeIntoContacts do
  use Ecto.Migration

  def change do
    alter table(:contacts) do
      add :code, :string
    end
  end
end
