defmodule Legato.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :handle, :string
    field :phone_number, :string
    field :avatar_url, :string
    field :is_guest, :boolean, default: false
    field :is_deleted, :boolean, default: false
    field :inserted_by, :string
    field :updated_by, :string
    belongs_to :workspace, Legato.Workspace

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:workspace_id, :email, :first_name, :last_name, :handle, :phone_number, :avatar_url, :inserted_by, :updated_by])
    |> validate_required([:workspace_id, :email, :first_name, :last_name, :handle, :phone_number, :avatar_url, :inserted_by, :updated_by])
    |> unique_constraint(:email)
    |> foreign_key_constraint(:workspace_id)
  end
end
