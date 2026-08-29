defmodule Legato.Chat.Schemas.Watermark do
  use Legato.Schema
  import Ecto.Changeset

  schema "watermarks" do
    field :sequence_number, :integer
    belongs_to :workspace, Legato.Chat.Schemas.Workspace, type: :binary_id
    belongs_to :thread, Legato.Chat.Schemas.Thread, type: :binary_id
    belongs_to :user, Legato.Chat.Schemas.User, type: :binary_id

    timestamps(type: :utc_datetime, inserted_at: false)
  end

  @doc false
  def changeset(watermark, attrs) do
    watermark
    |> cast(attrs, [:workspace_id, :thread_id, :user_id, :sequence_number])
    |> validate_required([:workspace_id, :thread_id, :user_id, :sequence_number])
    |> unique_constraint([:thread_id, :user_id])
  end
end
