defmodule Legato.Repo.Migrations.DropSignInTokens do
  use Ecto.Migration

  def change do
    drop_if_exists table(:sign_in_tokens)
  end
end
