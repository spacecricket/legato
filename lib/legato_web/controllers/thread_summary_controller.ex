defmodule LegatoWeb.ThreadSummaryController do
  use LegatoWeb, :controller
  require Logger
  import Ecto.Query
  alias Legato.Repo
  # alias Legato.Chat.Chat
  alias Legato.Chat.Schemas.{Thread, ThreadMember, Zap}

  @default_limit 50
  @max_limit 100

  def get_active_thread_summaries(
        conn,
        %{"workspace_id" => workspace_id, "user_id" => user_id}
      )
      when is_binary(workspace_id) and is_binary(user_id) do
    with true <- get_session(conn, :signed_in),
         ^workspace_id <- get_session(conn, :workspace_id),
         ^user_id <- get_session(conn, :user_id) do
      unread_thread_ids_query =
        from tm in ThreadMember,
          join: t in assoc(tm, :thread),
          where:
            tm.user_id == ^user_id and tm.workspace_id == ^workspace_id and
              t.workspace_id == ^workspace_id and t.message_count > tm.watermark and
              not t.is_deleted and not tm.is_deleted,
          select: tm.thread_id

      zapped_thread_ids_query =
        from z in Zap,
          where:
            z.to_user_id == ^user_id and z.workspace_id == ^workspace_id and
              not z.is_acked and not z.is_deleted,
          select: z.thread_id

      thread_ids_query = Ecto.Query.union(unread_thread_ids_query, ^zapped_thread_ids_query)

      query =
        from t in Thread,
          where: t.id in subquery(thread_ids_query) and t.workspace_id == ^workspace_id,
          preload: [:thread_members, :unacked_zaps, latest_message: ^latest_message_query()]

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

  def get_thread_summaries(
        conn,
        %{"workspace_id" => workspace_id, "user_id" => user_id} = params
      )
      when is_binary(workspace_id) and is_binary(user_id) do
    with :ok <- check_session(conn, workspace_id, user_id),
         {:ok, limit} <- fetch_limit(params),
         {:ok, cursor} <- fetch_cursor(params) do
      query =
        from t in Thread,
          join: tm in assoc(t, :thread_members),
          where:
            tm.user_id == ^user_id and tm.workspace_id == ^workspace_id and
              t.workspace_id == ^workspace_id and not tm.is_deleted and not t.is_deleted,
          order_by: [desc_nulls_last: t.last_message_at, desc: t.id],
          limit: ^(limit + 1),
          preload: [:thread_members, latest_message: ^latest_message_query()]

      {threads, next_cursor} =
        query
        |> apply_cursor(cursor)
        |> Repo.all()
        |> paginate(limit)

      render(conn, :index_paginated, threads: threads, user_id: user_id, next_cursor: next_cursor)
    else
      :unauthorized ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Not signed in"})

      {:error, :workspace_mismatch} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "No workspace in session or slug mismatch"})

      {:error, :invalid_limit} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid limit"})

      {:error, :invalid_cursor} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid cursor"})

      {:error, :user_mismatch} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "User mismatch"})
    end
  end

  defp check_session(conn, workspace_id, user_id) do
    cond do
      get_session(conn, :signed_in) != true -> :unauthorized
      get_session(conn, :workspace_id) != workspace_id -> {:error, :workspace_mismatch}
      get_session(conn, :user_id) != user_id -> {:error, :user_mismatch}
      true -> :ok
    end
  end

  defp latest_message_query do
    from m in Legato.Chat.Schemas.ThreadMessage,
      join: t in Legato.Chat.Schemas.Thread,
      on: t.id == m.thread_id and m.sequence_number == t.message_count
  end

  defp fetch_limit(%{"limit" => limit}) when is_integer(limit) and limit > 0 do
    {:ok, min(limit, @max_limit)}
  end

  defp fetch_limit(%{"limit" => limit}) when is_binary(limit) do
    case Integer.parse(limit) do
      {limit, ""} when limit > 0 -> {:ok, min(limit, @max_limit)}
      _ -> {:error, :invalid_limit}
    end
  end

  defp fetch_limit(_params), do: {:ok, @default_limit}

  defp fetch_cursor(%{"cursor" => cursor}) when is_binary(cursor) and cursor != "" do
    with {:ok, decoded} <- Base.url_decode64(cursor, padding: false),
         [timestamp, id] when id != "" <- String.split(decoded, "|", parts: 2),
         {:ok, id} <- Ecto.UUID.cast(id),
         {:ok, last_message_at} <- decode_timestamp(timestamp) do
      {:ok, {last_message_at, id}}
    else
      _ -> {:error, :invalid_cursor}
    end
  end

  defp fetch_cursor(_params), do: {:ok, nil}

  defp decode_timestamp(""), do: {:ok, nil}

  defp decode_timestamp(timestamp) do
    case DateTime.from_iso8601(timestamp) do
      {:ok, datetime, _offset} -> {:ok, datetime}
      {:error, _reason} -> {:error, :invalid_cursor}
    end
  end

  defp apply_cursor(query, nil), do: query

  defp apply_cursor(query, {nil, id}) do
    where(query, [t, _], is_nil(t.last_message_at) and t.id < ^id)
  end

  defp apply_cursor(query, {%DateTime{} = last_message_at, id}) do
    where(
      query,
      [t, _],
      t.last_message_at < ^last_message_at or
        (t.last_message_at == ^last_message_at and t.id < ^id) or
        is_nil(t.last_message_at)
    )
  end

  defp paginate(threads, limit) when length(threads) > limit do
    page = Enum.take(threads, limit)
    {page, encode_cursor(List.last(page))}
  end

  defp paginate(threads, _limit), do: {threads, nil}

  defp encode_cursor(%Thread{} = thread) do
    "#{encode_timestamp(thread.last_message_at)}|#{thread.id}"
    |> Base.url_encode64(padding: false)
  end

  defp encode_timestamp(nil), do: ""
  defp encode_timestamp(%DateTime{} = datetime), do: DateTime.to_iso8601(datetime)
end
