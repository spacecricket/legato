defmodule Legato.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :first_name, :string
      add :last_name, :string
      add :handle, :string, null: false
      add :phone_number, :string
      add :avatar_url, :string
      add :is_guest, :boolean, default: false, null: false
      add :is_deleted, :boolean, default: false, null: false
      add :inserted_by, :string, null: false
      add :updated_by, :string, null: false
      add :workspace_id, references(:workspaces), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:workspace_id, :handle, :is_deleted])
    create index(:users, [:workspace_id])
  end
end
