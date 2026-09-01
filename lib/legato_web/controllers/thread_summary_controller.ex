defmodule LegatoWeb.ThreadSummaryController do
  use LegatoWeb, :controller
  require Logger
  import Ecto.Query
  alias Legato.Repo
  # alias Legato.Chat.Chat
  alias Legato.Chat.Schemas.{Thread, ThreadMember, Zap}

  def get_active_thread_summaries(
    conn,
    %{"workspace_id" => workspace_id, "user_id" => user_id}
  ) when is_binary(workspace_id) and is_binary(user_id) do

    with true <- get_session(conn, :signed_in),
      ^workspace_id <- get_session(conn, :workspace_id),
      ^user_id <- get_session(conn, :user_id) do

      unread_thread_ids_query =
        from tm in ThreadMember,
          join: t in assoc(tm, :thread),
          where: tm.user_id == ^user_id and t.message_count >= tm.watermark and not t.is_deleted and not tm.is_deleted,
          select: tm.thread_id

      zapped_thread_ids_query =
        from z in Zap,
          where: z.to_user_id == ^user_id and not z.is_acked and not z.is_deleted,
          select: z.thread_id

      thread_ids_query = Ecto.Query.union(unread_thread_ids_query, ^zapped_thread_ids_query)

      query =
        from t in Thread,
          where: t.id in subquery(thread_ids_query),
          preload: [:thread_members, :unacked_zaps]

      render(conn, :index, threads: Repo.all(query), user_id: user_id)
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
