defmodule LegatoWeb.SignInChannel do
  use LegatoWeb, :channel
  require Logger

  @impl true
  def join("sign-in:" <> token_hash, _payload, socket) do
    if token_hash == socket.assigns.token_hash do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def join(topic, _payload, _socket) do
    Logger.info(topic)

    {:error, %{reason: "invalid topic"}}
  end
end
