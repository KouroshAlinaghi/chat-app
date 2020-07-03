defmodule ChatAppWeb.RoomChannel do
  use Phoenix.Channel

  import Ecto.Query, warn: false
  alias ChatAppWeb.Presence

  def join("room:"<>group_id, payload, socket) do
    if ChatApp.Msg.is_member?(socket.assigns.current_user, group_id) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))
    user = ChatApp.Repo.get(ChatApp.Accounts.User, socket.assigns.current_user)
    {:ok, _} = Presence.track(socket, "user:#{user.id}", %{
      user_id: user.id,
      username: user.username
    })

    IO.inspect ChatApp.Msg.recent_messages(socket.topic)
    ChatApp.Msg.recent_messages(socket.topic)
    |> Enum.each(fn msg -> push(socket, "new_msg", format_msg(msg)) end)
    {:noreply, socket}
  end
  
  defp format_msg(msg) do
    %{
      body: msg.body,
      user: msg.user.username
    }
  end

  def handle_in("new_msg", payload, socket) do
    spawn(fn -> save_message(payload, socket) end)
    payload = Map.put(payload, :user, ChatApp.Repo.get(ChatApp.Accounts.User, socket.assigns.current_user).username)
    broadcast!(socket, "new_msg", payload)
    {:noreply, socket}
  end

  defp save_message(message, socket) do
    "room:"<>group_id = socket.topic 
    params = %{user_id: socket.assigns.current_user, body: message["body"], group_id: group_id}
    
    case %ChatApp.Msg.Message{} |> ChatApp.Msg.Message.changeset(params) |> ChatApp.Repo.insert() do
      {:ok, _bruh} -> IO.inspect "dsdssdsd"
      {:error, changeset} -> IO.inspect changeset
    end
  end
end
