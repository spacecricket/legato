defmodule LegatoWeb.Router do
  use LegatoWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_session do
    plug :fetch_session
  end

  scope "/api", LegatoWeb do
    pipe_through :api

    scope "/sign-in" do
      pipe_through :api_session

      post "/start",  SignInController, :start
      post "/verify", SignInController, :verify
      get "/token", SignInController, :token
    end

    scope "/workspaces" do
      pipe_through :api_session

      get "/:workspaceId", WorkspaceController, :get_workspace
      get "/:workspaceId/users", WorkspaceController, :get_workspace_users
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:legato, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: LegatoWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
