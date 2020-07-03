defmodule ChatApp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias ChatApp.Repo
  alias Argon2
  alias ChatApp.Accounts.User

  @expire_time_in_seconds 60*60*24*30*12

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  alias ChatApp.Accounts.Auth

  def get_auth_by_code(code) do
    query = from a in Auth, where: a.code == ^code
    Repo.one(query)
  end

  @doc """
  Creates a auth.

  ## Examples

      iex> create_auth(%{field: value})
      {:ok, %Auth{}}

      iex> create_auth(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_auth(attrs \\ %{}) do
    %Auth{}
    |> Auth.changeset(attrs)
    |> Repo.insert()
  end

  def verify_credentials(username, password) do
    query = from u in User, where: u.username == ^username

    case Repo.one(query) do
      nil ->
        {:error, :invalid_credentials}

      user ->
        if Argon2.verify_pass(password, user.password) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  def validate_time(conn, auth) do
    expire_date = auth.inserted_at |> NaiveDateTime.add(@expire_time_in_seconds)
    NaiveDateTime.compare(expire_date, NaiveDateTime.utc_now()) == :gt
  end

  def verify_auth(conn) do
    if Map.has_key?(conn.cookies, "TOKEN") do
      query = from a in Auth, where: a.code == ^conn.cookies["TOKEN"]
      auth = Repo.one(query) |> Repo.preload(:user)

      if auth && validate_time(conn, auth) do
        {:ok, auth.user}
      else
        {:error, :invalid_token}
      end
    else
      {:error, "TOKEN is not set."}
    end
  end

  defp gen_cookie(conn, code) do
    conn
    |> Plug.Conn.put_resp_cookie("TOKEN", code, max_age: @expire_time_in_seconds, http_only: true)
    |> Plug.Conn.fetch_cookies()
  end

  def login(conn, %User{id: id}) do
    code = :crypto.strong_rand_bytes(64) |> Base.encode64() |> binary_part(0, 64)
    params = %{user_id: id, code: code}

    case create_auth(params) do
      {:ok, _record} ->
        gen_cookie(conn, code)

      {:error, _msg} ->
        conn
    end
  end

  def drop_cookie(conn) do
    Plug.Conn.delete_resp_cookie(conn, "TOKEN")
  end

  @doc """
  Deletes a auth.

  ## Examples

      iex> delete_auth(auth)
      {:ok, %Auth{}}

      iex> delete_auth(auth)
      {:error, %Ecto.Changeset{}}

  """
  def delete_auth(%Auth{} = auth) do
    Repo.delete(auth)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking auth changes.

  ## Examples

      iex> change_auth(auth)
      %Ecto.Changeset{data: %Auth{}}

  """
  def change_auth(%Auth{} = auth, attrs \\ %{}) do
    Auth.changeset(auth, attrs)
  end
end
