defmodule LegatoWeb.ThreadSummaryController do
  use LegatoWeb, :controller
  # require Logger
  # alias Legato.{Accounts, Workspace, User}

  # def get_active_thread_summaries(
  #   conn,
  #   %{"workspaceId" => workspace_id, "userId" => user_id}
  # ) when is_binary(workspace_id) and is_binary(user_id) do

  #   with  true                            <- get_session(conn, :signed_in),
  #         ^workspace_id                   <- get_session(conn, :workspace_id),
  #         ^user_id                        <- get_session(conn, :user_id),
  #         {:ok, thread_summaries} when is_list(thread_summaries) <- Accounts.get_workspace_users(workspace_id),
  #         true                            <- Enum.all?(thread_summaries, &match?(%User{}, &1)) do

  #       formatted_users = Enum.map(users, fn %User{} = user ->
  #       %{
  #         id:         user.id,
  #         firstName:  user.first_name,
  #         lastName:   user.last_name,
  #         handle:     user.handle,
  #         avatarUrl:  user.avatar_url,
  #         isGuest:    user.is_guest,
  #         isDeleted:  user.is_deleted,
  #         updatedAt:  user.updated_at
  #       }
  #     end)

  #     json(conn, formatted_users)
  #   else
  #     false ->
  #       conn
  #       |> put_status(:unauthorized)
  #       |> json(%{error: "Not signed in"})

  #     nil ->
  #       conn
  #       |> put_status(:bad_request)
  #       |> json(%{error: "No workspace in session or slug mismatch"})

  #     {:error, :not_found} ->
  #       conn
  #       |> put_status(:not_found)
  #       |> json(%{error: "Workspace not found"})

  #     _ ->
  #       conn
  #       |> put_status(:forbidden)
  #       |> json(%{error: "Forbidden"})
  #   end
  # end
end
