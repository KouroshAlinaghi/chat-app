defmodule ChatApp.Repo.Migrations.RemoveGroupIdFromMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      remove :group_id
    end
  end
end
