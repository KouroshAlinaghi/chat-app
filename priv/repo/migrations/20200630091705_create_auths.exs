defmodule ChatApp.Repo.Migrations.CreateAuths do
  use Ecto.Migration

  def change do
    create table(:auths) do
      add :code, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:auths, [:user_id])
  end
end
