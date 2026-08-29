defmodule Legato.Chat.Schemas.Zap do
  use Legato.Schema
  import Ecto.Changeset

  schema "zaps" do
    field :is_acked, :boolean, default: false
    field :is_deleted, :boolean, default: false
    field :inserted_by, :string
    field :updated_by, :string
    belongs_to :workspace, Legato.Chat.Schemas.Workspace, type: :binary_id
    belongs_to :thread, Legato.Chat.Schemas.Thread, type: :binary_id
    belongs_to :thread_message, Legato.Chat.Schemas.ThreadMessage, type: :binary_id
    belongs_to :from_user, Legato.Chat.Schemas.User, type: :binary_id, foreign_key: :from_user_id
    belongs_to :to_user, Legato.Chat.Schemas.User, type: :binary_id, foreign_key: :to_user_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(zap, attrs) do
    zap
    |> cast(attrs, [:workspace_id, :thread_id, :thread_message_id, :from_user_id, :to_user_id, :is_acked, :is_deleted, :inserted_by, :updated_by])
    |> validate_required([:workspace_id, :thread_id, :thread_message_id, :from_user_id, :to_user_id, :inserted_by, :updated_by])
    |> unique_constraint([:thread_message_id, :from_user_id, :to_user_id])
    |> foreign_key_constraint(:workspace_id)
    |> foreign_key_constraint(:thread_id)
    |> foreign_key_constraint(:thread_message_id)
    |> foreign_key_constraint(:from_user_id)
    |> foreign_key_constraint(:to_user_id)
  end
end
