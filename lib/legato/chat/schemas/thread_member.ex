defmodule Legato.Chat.Schemas.ThreadMember do
  use Legato.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__, :workspace, :thread, :user]}
  schema "thread_members" do
    field :is_deleted, :boolean, default: false
    field :watermark, :integer, default: 0
    field :watermark_updated_at, :utc_datetime
    field :inserted_by, :string
    field :updated_by, :string
    belongs_to :workspace, Legato.Chat.Schemas.Workspace, type: :binary_id
    belongs_to :thread, Legato.Chat.Schemas.Thread, type: :binary_id
    belongs_to :user, Legato.Chat.Schemas.User, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(thread_member, attrs) do
    thread_member
    |> cast(attrs, [:workspace_id, :thread_id, :user_id, :is_deleted, :watermark, :watermark_updated_at, :inserted_by, :updated_by])
    |> validate_required([:workspace_id, :thread_id, :user_id, :inserted_by, :updated_by])
    |> unique_constraint([:thread_id, :user_id])
    |> foreign_key_constraint(:workspace_id)
    |> foreign_key_constraint(:thread_id)
    |> foreign_key_constraint(:user_id)
  end

  @doc false
  def watermark_changeset(thread_member, attrs) do
    thread_member
    |> cast(attrs, [:workspace_id, :thread_id, :user_id, :watermark, :watermark_updated_at])
    |> validate_required([:workspace_id, :thread_id, :user_id, :watermark, :watermark_updated_at])
    |> unique_constraint([:thread_id, :user_id])
    |> foreign_key_constraint(:workspace_id)
    |> foreign_key_constraint(:thread_id)
    |> foreign_key_constraint(:user_id)
  end
end
