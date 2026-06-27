defmodule LegatoWeb.WorkspaceSocket do
  use Phoenix.Socket

  channel "workspace:*", LegatoWeb.WorkspaceChannel

  @impl true
  def connect(_params, socket, %{session: %{"user_id" => user_id, "workspace_id" => workspace_id}}) do
    {
      :ok,
      socket
      |> assign(:user_id, user_id)
      |> assign(:workspace_id, workspace_id)
    }
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(socket), do: "workspace_socket:#{socket.assigns.user_id}"
end
