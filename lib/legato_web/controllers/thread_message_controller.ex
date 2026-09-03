defmodule LegatoWeb.ThreadMessageController do
  use LegatoWeb, :controller
  require Logger
  import Ecto.Query
  alias Legato.Repo
  # alias Legato.Chat.Chat
  alias Legato.Chat.Schemas.{ThreadMessage}

  def get_messages(
    conn,
    %{"workspace_id" => workspace_id, "thread_id" => thread_id}
  ) when is_binary(workspace_id) and is_binary(thread_id) do

    with true <- get_session(conn, :signed_in),
      ^workspace_id <- get_session(conn, :workspace_id) do

      query =
        from tm in ThreadMessage,
          where: tm.thread_id == ^thread_id

      render(conn, :index, messages: Repo.all(query))
    else
      false ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Not signed in"})

      nil ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "No workspace in session or slug mismatch"})
    end
  end
end
