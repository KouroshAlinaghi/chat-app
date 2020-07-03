defmodule ChatApp.Msg.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :body, :string
    belongs_to :user, ChatApp.Accounts.User
    belongs_to :group, ChatApp.Msg.Group

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body, :user_id, :group_id])
    |> validate_required([:body, :user_id, :group_id])
  end
end
