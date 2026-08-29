defmodule Legato.Chat.Schemas.SignInCode do
  use Legato.Schema
  import Ecto.Changeset

  schema "sign_in_codes" do
    field :code, :integer
    field :code_key, :string
    field :device_fingerprint, :string
    field :expires_at, :utc_datetime
    field :verified_at, :utc_datetime
    belongs_to :workspace, Legato.Chat.Schemas.Workspace
    belongs_to :user, Legato.Chat.Schemas.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(sign_in_code, attrs) do
    sign_in_code
    |> cast(attrs, [:workspace_id, :user_id, :code, :code_key, :device_fingerprint, :expires_at])
    |> validate_required([:workspace_id, :user_id, :code, :code_key, :device_fingerprint, :expires_at])
    |> unique_constraint(:code_key)
    |> foreign_key_constraint(:workspace_id)
    |> foreign_key_constraint(:user_id)
  end

  def verification_changeset(sign_in_code, attrs) do
    sign_in_code
    |> cast(attrs, [:verified_at])
    |> validate_required([:verified_at])
  end
end
