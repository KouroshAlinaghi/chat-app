defmodule ChatAppWeb.AuthController do
  use ChatAppWeb, :controller

  alias ChatApp.Accounts

  def new(conn, _parmas) do
    changeset = Accounts.change_user(%Accounts.User{})
    render(conn, "new.html", changeset: changeset, action: Routes.auth_path(conn, :create))
  end

  def create(conn, %{"user" => %{"username" => username, "password" => password}}) do
    case Accounts.verify_credentials(username, password) do
      {:ok, user} ->
        conn
        |> Accounts.login(user)
        |> put_flash(:info, "Logged In Successfully")
        |> redirect(to: Routes.group_path(conn, :index))

      {:error, _} ->
        changeset = Accounts.change_user(%Accounts.User{})

        conn
        |> put_flash(:error, "Invalid Credentials")
        |> render("new.html", changeset: changeset, action: Routes.auth_path(conn, :create))
    end
  end

  def delete(conn, _params) do
    conn.cookies["TOKEN"]
    |> Accounts.get_auth_by_code()
    |> Accounts.delete_auth()

    conn
    |> Accounts.drop_cookie()
    |> put_flash(:info, "Logged Out Successfully.")
    |> redirect(to: Routes.group_path(conn, :index))
  end
end

