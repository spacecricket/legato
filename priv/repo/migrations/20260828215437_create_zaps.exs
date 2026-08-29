defmodule Legato.Repo.Migrations.CreateZaps do
  use Ecto.Migration

  def change do
    create table(:zaps) do
      add :is_acked, :boolean, default: false, null: false
      add :is_deleted, :boolean, default: false, null: false
      add :inserted_by, :string
      add :updated_by, :string
      add :workspace_id, references(:workspaces), null: false
      add :thread_id, references(:threads), null: false
      add :thread_message_id, references(:thread_messages), null: false
      add :from_user_id, references(:users), null: false
      add :to_user_id, references(:users), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:zaps, [:thread_id, :to_user_id, :is_acked])
    create index(:zaps, [:thread_message_id])
    create index(:zaps, [:from_user_id, :updated_at])
    create index(:zaps, [:to_user_id, :updated_at])
    create index(:zaps, [:workspace_id])
  end
end
