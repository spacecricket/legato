defmodule Legato.Chat.Chat do
  alias Legato.Repo
  alias Legato.Chat.Schemas.{User, Workspace}

  def get_workspace(workspace_id) when is_binary(workspace_id) do
    case Repo.get_by(Workspace, id: workspace_id, status: :active) do
      nil ->
        {:error, :not_found}

      %Workspace{} = workspace ->
        {:ok, workspace}
    end
  end

  def get_user(workspace_id, user_id) when is_binary(workspace_id) and is_binary(user_id) do
    case Repo.get_by(User, id: user_id, workspace_id: workspace_id) do
      nil ->
        {:error, :not_found}

      %User{} = user ->
        {:ok, user}
    end
  end

  def get_all_users(workspace_id) when is_binary(workspace_id) do
    {:ok, Repo.all_by(User, workspace_id: workspace_id)}
  end


end
