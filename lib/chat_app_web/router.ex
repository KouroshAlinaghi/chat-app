defmodule ChatAppWeb.Router do
  use ChatAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :auth_verify
    plug :put_user_token
  end
  
  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end

  pipeline :protected do
    plug :protected_path
  end

  pipeline :req_not_auth do
    plug :req_not_auth_path 
  end

  def req_not_auth_path(conn, _params) do
    unless conn.assigns.user_signed_in do
      conn
    else
      conn 
      |> put_flash(:error, "You Must Be Logged Out")
      |> redirect(to: "/")
    end
  end

  def protected_path(conn, _params) do
    if conn.assigns.user_signed_in do
      conn
    else
      conn 
      |> put_flash(:error, "You Must Be Logged In")
      |> redirect(to: "/login")
    end
  end

  defp auth_verify(conn, _params) do
    case ChatApp.Accounts.verify_auth(conn) do
      {:ok, user} ->
        conn
        |> assign(:current_user, user)
        |> assign(:user_signed_in, true)
      {:error, :invalid_token} ->
        conn
        |> ChatApp.Accounts.drop_cookie()
        |> assign(:user_signed_in, false)
      {:error, _} ->
        conn
        |> assign(:user_signed_in, false)
    end
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChatAppWeb do
    pipe_through [:browser]
    
    get "/", GroupController, :index
  end

  scope "/", ChatAppWeb do
    pipe_through [:browser, :protected]

    delete "/delete_account", UserController, :delete
    delete "/logout", AuthController, :delete
    resources "groups", GroupController, only: [:new, :create, :show, :delete]
    post "/join/:id", GroupController, :join
    delete "/leave/:id", GroupController, :leave
  end

  scope "/", ChatAppWeb do
    pipe_through [:browser, :req_not_auth]

    get "/login", AuthController, :new
    post "/login", AuthController, :create
    get "/sign_up", UserController, :new
    post "/sign_up", UserController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChatAppWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ChatAppWeb.Telemetry
    end
  end
end
