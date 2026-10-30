defmodule Legato.Repo.Migrations.AddThreadSummaryPaginationIndex do
  use Ecto.Migration

  def change do
    # Matches the thread-summaries ordering and its `NOT is_deleted` filter.
    # This subsumes the broader (workspace_id, last_message_at) index below.
    create index(
             :threads,
             ["workspace_id", "last_message_at DESC NULLS LAST", "id DESC"],
             name: :threads_thread_summary_pagination_index,
             where: "NOT is_deleted"
           )

    drop index(:threads, [:workspace_id, :last_message_at])
  end
end
