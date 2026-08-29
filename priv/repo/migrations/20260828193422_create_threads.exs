defmodule Legato.Repo.Migrations.CreateThreads do
  use Ecto.Migration

  def change do
    create table(:threads) do
      add :name, :string
      add :is_private, :boolean, default: false, null: false
      add :is_deleted, :boolean, default: false, null: false
      add :message_count, :integer, default: 0, null: false
      add :last_message_at, :utc_datetime
      add :inserted_by, :string, null: false
      add :updated_by, :string, null: false
      add :workspace_id, references(:workspaces), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:threads, [:workspace_id, :last_message_at])
    create index(:threads, [:workspace_id])
  end
end
