defmodule LegatoWeb.WorkspaceController do
  use LegatoWeb, :controller
  require Logger
  alias Legato.Chat.Chat
  alias Legato.Chat.Schemas.{Workspace, User}

  def get_workspace(conn, %{"workspaceId" => workspace_id}) when is_binary(workspace_id) do
    with  true                            <- get_session(conn, :signed_in),
          ^workspace_id                   <- get_session(conn, :workspace_id),
          {:ok, %Workspace{} = workspace} <- Chat.get_workspace(workspace_id) do

      json(conn, workspace)
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

  def get_workspace_users(conn, %{"workspaceId" => workspace_id}) when is_binary(workspace_id) do
    with  true                              <- get_session(conn, :signed_in),
          ^workspace_id                     <- get_session(conn, :workspace_id),
          {:ok, users} when is_list(users)  <- Chat.get_all_users(workspace_id) do

      json(conn, users)
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
