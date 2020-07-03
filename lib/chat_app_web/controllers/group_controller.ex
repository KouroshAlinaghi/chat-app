defmodule ChatAppWeb.GroupController do
  use ChatAppWeb, :controller

  alias ChatApp.Msg
  alias ChatApp.Msg.{Group, Message, GroupUser}

  plug :ensure_not_member when action in [:join]
  plug :ensure_member when action in [:leave, :show]
  plug :ensure_owner when action in [:delete]

  def join(conn, %{"id" => id}) do
    case Msg.create_group_user(%{group_id: id, user_id: conn.assigns.current_user.id, role: "normal"}) do
      {:ok, _join} ->
        conn
        |> put_flash(:info, "Joined Successfully")
        |> redirect(to: Routes.group_path(conn, :show, Msg.get_group!(id)))

      {:error, _reason} ->
        conn
        |> put_flash(:info, "There is an error.")
        |> redirect(to: Routes.group_path(conn, :index))
    end
  end

  def leave(conn, %{"id" => id}) do
    group_user = Msg.get_group_user(id, conn.assigns.current_user.id)
    {:ok, _join} = Msg.delete_group_user(group_user)

    conn
    |> put_flash(:infor, "Left The Group Successfully")
    |> redirect(to: Routes.group_path(conn, :index))
  end

  def index(conn, _params) do
    groups = Msg.list_groups()
    render(conn, "index.html", groups: groups)
  end

  def new(conn, _params) do
    changeset = Msg.change_group(%Group{})
    render(conn, "new.html", changeset: changeset, action: Routes.group_path(conn, :create))
  end

  def create(conn, %{"group" => group_params}) do
    case Msg.create_group(group_params) do
      {:ok, %Group{id: id} = group} ->

        case Msg.create_group_user(%{group_id: id, user_id: conn.assigns.current_user.id, role: "owner"}) do
          {:ok, _join} ->
            conn
            |> put_flash(:info, "Group Created And Joined Successfully")
            |> redirect(to: Routes.group_path(conn, :show, group))

          {:error, _reason} ->
            conn
            |> put_flash(:error, "Cannot Create Join")
            |> redirect(to: Routes.group_path(conn, :index))
        end
        
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, action: Routes.group_path(conn, :create))
    end
  end

  def show(conn, %{"id" => id}) do
    group = Msg.get_group!(id)
    render(conn, "show.html", group: group)
  end

  def delete(conn, %{"id" => id}) do
    group = Msg.get_group!(id)
    {:ok, _group} = Msg.delete_group(group)
    
    conn
    |> put_flash(:info, "Group Deleted Successfully")
    |> redirect(to: Routes.group_path(conn, :index))
  end

  defp ensure_not_member(conn, _params) do
    if Msg.is_member?(conn.assigns.current_user.id, conn.params["id"]) do
      conn
      |> put_flash(:error, "You're Already A Member")
      |> redirect(to: Routes.group_path(conn, :index))
    else
      conn
    end
  end

  def ensure_member(conn, _params) do
    unless Msg.is_member?(conn.assigns.current_user.id, conn.params["id"]) do
      conn
      |> put_flash(:error, "You're Not A Member")
      |> redirect(to: Routes.group_path(conn, :index))
    else
      conn
    end
  end

  def ensure_owner(conn, _params) do
    if Msg.is_member?(conn.assigns.current_user.id, conn.params["id"]) do
      conn
    else
      conn
      |> put_flash(:error, "You Cant Delete/Change Group")
      |> redirect(to: Routes.group_path(conn, :index))
    end
  end

end
