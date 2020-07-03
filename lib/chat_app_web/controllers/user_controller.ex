defmodule ChatAppWeb.UserController do
  use ChatAppWeb, :controller

  alias ChatApp.{Accounts, Accounts.User}

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset, action: Routes.user_path(conn, :create))
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> Accounts.login(user)
        |> put_flash(:info, "User Created And Logged In Successfully")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, action: Routes.user_path(conn, :create))
    end
  end

  def delete(conn, _params) do
    {:ok, _user} = Accounts.delete_user(conn.assigns.current_user)
    
    conn
    |> Accounts.drop_cookie()
    |> put_flash(:info, "Account Deleted Successfully")
    |> redirect(to: Routes.auth_path(conn, :new))
  end
end
