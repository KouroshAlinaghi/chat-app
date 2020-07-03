defmodule ChatApp.Msg.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    many_to_many :users, ChatApp.Accounts.User, join_through: ChatApp.Msg.GroupUser
    has_many :messages, ChatApp.Msg.Message
    
    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
