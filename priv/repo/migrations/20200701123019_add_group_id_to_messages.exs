defmodule ChatApp.Repo.Migrations.AddGroupIdToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :group_id, references(:users, on_delete: :delete_all)
    end

    create index(:messages, [:group_id])
  end
end
