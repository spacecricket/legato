defmodule LegatoWeb.ThreadMessageJSON do
  alias Legato.Chat.Schemas.{ThreadMessage}

  @doc """
  Renders a list of thread summaries.
  """
  def index(%{messages: messages}) do
    for %ThreadMessage{} = message <- messages do
      %{
        id: message.id,
        workspace_id: message.workspace_id,
        user_id: message.user_id,
        sequence_number: message.sequence_number,
        version: message.version,
        content: message.content,
        content_format_version: message.content_format_version,
        is_deleted: message.is_deleted,
        inserted_by: message.inserted_by,
        updated_by: message.updated_by,
        inserted_at: message.inserted_at,
        updated_at: message.updated_at
      }
    end
  end
end
