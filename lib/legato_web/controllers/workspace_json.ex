defmodule LegatoWeb.WorkspaceJSON do
  alias Legato.Chat.Schemas.{User, Workspace}

  @doc """
  Renders a workspace.
  """
  def show(%{workspace: %Workspace{} = workspace}) do
    %{
      id: workspace.id,
      name: workspace.name,
      slug: workspace.slug,
      logo_url: workspace.logo_url,
      status: workspace.status,
      inserted_by: workspace.inserted_by,
      updated_by: workspace.updated_by,
      inserted_at: workspace.inserted_at,
      updated_at: workspace.updated_at
    }
  end

  @doc """
  Renders a list of users.
  """
  def users(%{users: users}) when is_list(users) do
    for %User{} = user <- users do
      %{
        id: user.id,
        workspace_id: user.workspace_id,
        handle: user.handle,
        first_name: user.first_name,
        last_name: user.last_name,
        avatar_url: user.avatar_url,
        is_guest: user.is_guest,
        is_deleted: user.is_deleted,
        updated_by: user.updated_by,
        updated_at: user.updated_at
      }
    end
  end
end
