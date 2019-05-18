defmodule Backend.Repo.Migrations.MoveTokenFromUsersToContacts do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :token
    end

    alter table(:contacts) do
      add :token, :string
    end
  end
end
