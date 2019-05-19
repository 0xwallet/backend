defmodule Backend.Repo.Migrations.DropUsersTable do
  use Ecto.Migration

  def change do
    drop index(:contacts, [:user_id])

    alter table(:contacts) do
      remove :user_id
    end

    drop table(:posts)
    drop table(:users)
  end
end
