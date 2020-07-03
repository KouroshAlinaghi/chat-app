defmodule ChatApp.Msg.GroupUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups_users" do
    field :role, :string
    belongs_to :user, ChatApp.Accounts.User
    belongs_to :group, ChatApp.Msg.Group

    timestamps()
  end

  @doc false
  def changeset(group_user, attrs) do
    group_user
    |> cast(attrs, [:role, :user_id, :group_id])
    |> validate_required([:role, :user_id, :group_id])
  end
end
