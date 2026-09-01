defmodule LegatoWeb.SignInJSON do

  def status(%{status: status}) do
    %{status: status}
  end

  def status_and_slug(%{status: status, workspace_slug: workspace_slug}) do
    %{status: status, workspace_slug: workspace_slug}
  end

  def token(%{token: token, workspace_id: workspace_id, user_id: user_id}) do
    %{token: token, workspace_id: workspace_id, user_id: user_id}
  end

end
