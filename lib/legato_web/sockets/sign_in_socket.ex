defmodule LegatoWeb.SignInSocket do
  use Phoenix.Socket

  channel "sign-in:*", LegatoWeb.SignInChannel

  @impl true
  def connect(%{"tokenHash" => token_hash}, socket, _connect_info) do
    {
      :ok,
      socket
      |> assign(:token_hash, token_hash)
    }
  end

  @impl true
  def connect(_params, _socket, _connect_info) do
    :error
  end

  @impl true
  def id(_socket), do: nil
end
