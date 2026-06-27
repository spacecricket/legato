defmodule Legato.Repo.Migrations.CreateSignInTokens do
  use Ecto.Migration

  def change do
    create table(:sign_in_tokens) do
      add :token_hash, :string, null: false
      add :expires_at, :utc_datetime, null: false
      add :verified_at, :utc_datetime
      add :workspace_id, references(:workspaces), null: false
      add :user_id, references(:users), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:sign_in_tokens, [:workspace_id])
    create index(:sign_in_tokens, [:user_id])
    create unique_index(:sign_in_tokens, [:token_hash])
  end
end
