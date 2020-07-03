defmodule ChatApp.Accounts.Auth do
  use Ecto.Schema
  import Ecto.Changeset

  schema "auths" do
    field :code, :string
    belongs_to :user, ChatApp.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(auth, attrs) do
    auth
    |> cast(attrs, [:code, :user_id])
    |> validate_required([:code, :user_id])
  end
end
