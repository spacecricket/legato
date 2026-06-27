defmodule Legato.SignInToken do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sign_in_tokens" do
    field :token_hash, :string
    field :expires_at, :utc_datetime
    field :verified_at, :utc_datetime
    field :workspace_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sign_in_token, attrs) do
    sign_in_token
    |> cast(attrs, [:token_hash, :expires_at])
    |> validate_required([:token_hash, :expires_at])
  end
end
