defmodule LegatoWeb.SignInController do
  use LegatoWeb, :controller
  require Logger

  def start(conn, %{"email" => email}) do
    if get_session(conn, "email") == email && get_session(conn, "signed-in") do
      # Already signed in
      Logger.info("already signed in")
      conn
      |> json(%{
        status: "signed-in"
      })
    else
      # look up the user in the db
      # create a new sign-in token, and store it in the db
      token = Ecto.UUID.generate()
      token_hash = :crypto.hash(:sha256, token) |> Base.encode16
      # email the user
      Logger.info(token)
      Logger.info(token_hash)

      conn
      |> put_session("email", email)
      |> put_session("signed-in", false)
      |> json(%{
        status: "verifying",
        tokenHash: token_hash
      })
    end
  end

  def verify(conn, %{"token" => token}) do
    token_hash = :crypto.hash(:sha256, token) |> Base.encode16
    # updated verified and verified_at in db
    LegatoWeb.Endpoint.broadcast("sign-in:" <> token_hash, "verified", %{}) # only broadcast if token was legit and previously unverified
    conn |> json(%{status: "ok"})
  end

  def finish(conn, params) do
    Logger.info(params)
    # update used_at of params.signInTokenId, params.emailAddress
    conn
    |> put_session("signed-in", true)
    |> json(%{status: :ok})
  end
end
