defmodule ChatApp.Repo.Migrations.AddGroupidToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :group_id, references(:groups, on_delete: :delete_all)
    end

    create index(:messages, [:group_id])
  end
end
