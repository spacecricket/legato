defmodule Legato.Repo.Migrations.CreateThreadMembers do
  use Ecto.Migration

  def change do
    create table(:thread_members) do
      add :is_deleted, :boolean, default: false, null: false
      add :watermark, :integer, default: 0, null: false
      add :watermark_updated_at, :utc_datetime
      add :inserted_by, :string
      add :updated_by, :string
      add :workspace_id, references(:workspaces), null: false
      add :thread_id, references(:threads), null: false
      add :user_id, references(:users), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:thread_members, [:thread_id, :user_id])
    create index(:thread_members, [:workspace_id])
    create index(:thread_members, [:thread_id])
    create index(:thread_members, [:user_id])
  end
end
