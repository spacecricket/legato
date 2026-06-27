defmodule LegatoWeb.WorkspaceChannel do
  use LegatoWeb, :channel

  @impl true
  def join("workspace:" <> workspace_id, _payload, socket) do
    if workspace_id == socket.assigns.workspace_id do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def join(_topic, _payload, _socket) do
    {:error, %{reason: "invalid topic"}}
  end
end
