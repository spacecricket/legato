defmodule LegatoWeb.ThreadSummaryJSON do
  alias Legato.Chat.Schemas.{Thread, ThreadMember, Zap}

  @doc """
  Renders a list of thread summaries.
  """
  def index(%{threads: threads, user_id: user_id}) do
    for %Thread{} = thread <- threads do
      %{
        id: thread.id,
        workspace_id: thread.workspace_id,
        name: thread.name,
        is_private: thread.is_private,
        is_deleted: thread.is_deleted,
        message_count: thread.message_count,
        last_message_at: thread.last_message_at,
        inserted_by: thread.inserted_by,
        updated_by: thread.updated_by,
        inserted_at: thread.inserted_at,
        updated_at: thread.updated_at,
        thread_members: get_thread_members(thread.thread_members),
        unacked_zaps: get_unacked_zaps(thread.unacked_zaps, user_id)
      }
    end
  end

  defp get_thread_members(thread_members) when is_list(thread_members) do
    for %ThreadMember{} = thread_member <- thread_members do
      %{
        id: thread_member.id,
        workspace_id: thread_member.workspace_id,
        thread_id: thread_member.thread_id,
        user_id: thread_member.user_id,
        watermark: thread_member.watermark,
        watermark_updated_at: thread_member.watermark_updated_at,
        is_deleted: thread_member.is_deleted,
        inserted_by: thread_member.inserted_by,
        updated_by: thread_member.updated_by,
        inserted_at: thread_member.inserted_at,
        updated_at: thread_member.updated_at
      }
    end
  end

  defp get_unacked_zaps(unacked_zaps, user_id) when is_list(unacked_zaps) and is_binary(user_id) do
    for %Zap{to_user_id: ^user_id} = zap <- unacked_zaps do
      %{
        id: zap.id,
        workspace_id: zap.workspace_id,
        thread_id: zap.thread_id,
        thread_message_id: zap.thread_message_id,
        from_user_id: zap.from_user_id,
        to_user_id: zap.to_user_id,
        is_acked: zap.is_acked,
        is_deleted: zap.is_deleted,
        inserted_by: zap.inserted_by,
        updated_by: zap.updated_by,
        inserted_at: zap.inserted_at,
        updated_at: zap.updated_at
      }
    end
  end
end
