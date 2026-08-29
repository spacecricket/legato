defmodule Legato.Repo.Migrations.CreateThreadMessages do
  use Ecto.Migration

  def change do
    create table(:thread_messages) do
      add :sequence_number, :integer
      add :version, :integer, default: 1, null: false
      add :content, :text, null: false
      add :content_format_version, :integer, null: false
      add :is_deleted, :boolean, default: false, null: false
      add :inserted_by, :string
      add :updated_by, :string
      add :workspace_id, references(:workspaces), null: false
      add :thread_id, references(:threads), null: false
      add :user_id, references(:users), null: false

      timestamps(type: :utc_datetime)
    end

    # Add the tsvector generated column right after creating the table
    execute(
      """
      ALTER TABLE thread_messages
      ADD COLUMN content_search tsvector
      GENERATED ALWAYS AS (to_tsvector('english', coalesce(content, ''))) STORED;
      """,
      "ALTER TABLE thread_messages DROP COLUMN content_search;"
    )

    create unique_index(:thread_messages, [:thread_id, :sequence_number])
    # Recommended: Add a GIN index for fast full-text searching
    create index(:thread_messages, [:content_search], using: :gin)
    create index(:thread_messages, [:workspace_id, :thread_id, :sequence_number])
    create index(:thread_messages, [:workspace_id])
    create index(:thread_messages, [:thread_id])
    create index(:thread_messages, [:user_id])
  end
end
