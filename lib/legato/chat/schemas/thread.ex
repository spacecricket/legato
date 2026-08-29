defmodule Legato.Chat.Schemas.Thread do
  use Legato.Schema
  import Ecto.Changeset

  schema "threads" do
    field :name, :string
    field :is_private, :boolean, default: false
    field :is_deleted, :boolean, default: false
    field :message_count, :integer, default: 0
    field :last_message_at, :utc_datetime
    field :inserted_by, :string
    field :updated_by, :string
    belongs_to :workspace, Legato.Chat.Schemas.Workspace, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(thread, attrs) do
    thread
    |> cast(attrs, [:workspace_id, :name, :is_private, :is_deleted, :message_count, :last_message_at, :inserted_by, :updated_by])
    |> validate_required([:workspace_id, :name, :inserted_by, :updated_by])
    |> foreign_key_constraint(:workspace_id)
  end
end
