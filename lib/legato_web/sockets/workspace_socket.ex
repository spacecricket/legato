defmodule LegatoWeb.WorkspaceSocket do
  use Phoenix.Socket
  # require Logger

  channel "workspace:*", LegatoWeb.WorkspaceChannel
  channel "user:*", LegatoWeb.UserChannel
  # Need to join user channel too

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case Phoenix.Token.verify(socket, "workspace socket", token, max_age: 604_800) do
      {:ok, %{user_id: user_id, workspace_slug: workspace_slug}} ->
        {
          :ok,
          socket
          |> assign(:user_id, user_id)
          |> assign(:workspace_slug, workspace_slug)
        }
      {:error, _} ->
        :error
    end
  end

  @impl true
  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(socket), do: "workspace_socket:#{socket.assigns.user_id}"
end
