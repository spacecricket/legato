defmodule Legato.Chat.Schemas.ThreadMessage do
  use Legato.Schema
  import Ecto.Changeset

  schema "thread_messages" do
    field :sequence_number, :integer
    field :version, :integer, default: 1
    field :content, :string
    field :content_format_version, :integer
    field :is_deleted, :boolean, default: false
    field :inserted_by, :string
    field :updated_by, :string
    belongs_to :workspace, Legato.Chat.Schemas.Workspace, type: :binary_id
    belongs_to :thread, Legato.Chat.Schemas.Thread, type: :binary_id
    belongs_to :user, Legato.Chat.Schemas.User, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(thread_message, attrs) do
    thread_message
    |> cast(attrs, [:workspace_id, :thread_id, :user_id, :sequence_number, :version, :content, :content_format_version, :is_deleted, :inserted_by, :updated_by])
    |> validate_required([:workspace_id, :thread_id, :user_id, :sequence_number, :content, :content_format_version, :inserted_by, :updated_by])
    |> unique_constraint([:thread_id, :sequence_number])
    |> foreign_key_constraint(:workspace_id)
    |> foreign_key_constraint(:thread_id)
    |> foreign_key_constraint(:user_id)
  end
end
