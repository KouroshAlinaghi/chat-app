defmodule ChatApp.Repo.Migrations.CreateGroupsUser do
  use Ecto.Migration

  def change do
    create table(:groups_users) do
      add :role, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all)
      add :group_id, references(:groups, on_delete: :delete_all)

      timestamps()
    end

    create index(:groups_users, [:user_id])
    create index(:groups_users, [:group_id])
  end
end
