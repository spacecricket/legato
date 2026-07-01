defmodule Legato.Repo.Migrations.CreateSignInCodes do
  use Ecto.Migration

  def change do
    create table(:sign_in_codes) do
      add :code, :integer, null: false
      add :code_key, :string, null: false
      add :device_fingerprint, :string, null: false
      add :expires_at, :utc_datetime, null: false
      add :verified_at, :utc_datetime
      add :workspace_id, references(:workspaces), null: false
      add :user_id, references(:users), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:sign_in_codes, [:code_key])
  end
end
