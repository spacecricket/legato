defmodule Legato.Repo.Migrations.CreateWorkspaces do
  use Ecto.Migration

  def change do
    create table(:workspaces) do
      add :slug, :string, null: false
      add :name, :string, null: false
      add :logo_url, :string, null: false
      add :status, :string, null: false
      add :inserted_by, :string, null: false
      add :updated_by, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:workspaces, [:name])
    create unique_index(:workspaces, [:slug])
  end
end
