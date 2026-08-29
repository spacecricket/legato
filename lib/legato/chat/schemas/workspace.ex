defmodule Legato.Chat.Schemas.Workspace do
  use Legato.Schema
  import Ecto.Changeset

  schema "workspaces" do
    field :slug, :string
    field :name, :string
    field :logo_url, :string
    field :status, Ecto.Enum, values: [:active, :inactive]
    field :inserted_by, :string
    field :updated_by, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(workspace, attrs) do
    workspace
    |> cast(attrs, [:slug, :name, :logo_url, :status, :inserted_by, :updated_by])
    |> validate_required([:slug, :name, :logo_url, :status, :inserted_by, :updated_by])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
  end
end
