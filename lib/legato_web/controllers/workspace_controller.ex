defmodule LegatoWeb.WorkspaceController do
  use LegatoWeb, :controller
  require Logger
  alias Legato.{Accounts, Workspace, User}

  def get_workspace(conn, %{"workspaceSlug" => workspace_slug}) when is_binary(workspace_slug) do
    with  true                            <- get_session(conn, :signed_in),
          ^workspace_slug                 <- get_session(conn, :workspace_slug),
          {:ok, %Workspace{} = workspace} <- Accounts.get_workspace(workspace_slug) do
      conn
      |> json(%{
        slug:       workspace.slug,
        name:       workspace.name,
        logoUrl:    workspace.logo_url,
        updatedAt:  workspace.updated_at
      })
    else
      false ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Not signed in"})

      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "No workspace in session or slug mismatch"})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Workspace not found"})

      _ ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Forbidden"})
    end
  end

  def get_workspace_users(conn, %{"workspaceSlug" => workspace_slug}) when is_binary(workspace_slug) do
    with  true                              <- get_session(conn, :signed_in),
          ^workspace_slug                   <- get_session(conn, :workspace_slug),
          {:ok, users} when is_list(users)  <- Accounts.get_workspace_users(workspace_slug),
          true                              <- Enum.all?(users, &match?(%User{}, &1)) do

      formatted_users = Enum.map(users, fn %User{} = user ->
        %{
          id: user.id,
          firstName: user.first_name,
          lastName: user.last_name,
          handle: user.handle,
          avatarUrl: user.avatar_url,
          isGuest: user.is_guest,
          isDeleted: user.is_deleted,
          updatedAt: user.updated_at
        }
      end)

      json(conn, formatted_users)
    else
      false ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Not signed in"})

      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "No workspace in session or slug mismatch"})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Workspace not found"})

      _ ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Forbidden"})
    end
  end

  def get_workspace_me(conn, %{"workspaceSlug" => workspace_slug}) when is_binary(workspace_slug) do
    with  true            <- get_session(conn, :signed_in),
          ^workspace_slug <- get_session(conn, :workspace_slug),
          user_id         <- get_session(conn, :user_id) do

      json(conn, %{
        myUserId: user_id
      })
    else
      false ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Not signed in"})

      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "No workspace in session or slug mismatch"})

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Workspace not found"})

      _ ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Forbidden"})
    end
  end
end
