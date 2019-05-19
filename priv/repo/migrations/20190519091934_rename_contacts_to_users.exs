defmodule Backend.Repo.Migrations.RenameContactsToUsers do
  use Ecto.Migration

  def change do
    rename table(:contacts), to: table(:users)

    create unique_index(:users, [:token])
  end
end
