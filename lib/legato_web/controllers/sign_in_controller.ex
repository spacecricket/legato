defmodule LegatoWeb.SignInController do
  use LegatoWeb, :controller
  require Logger
  alias Legato.{Accounts, SignInCode, User}

  def start(conn, %{"email" => email}) when is_binary(email) do
    with  :not_signed_in                      <- check_auth(conn, email),
          code                                <- Enum.random(100_000..999_999),
          code_key                            <- Ecto.UUID.generate(),
          {:ok, %User{} = user}               <- Accounts.get_user_by_email(email),
          device_fingerprint                  <- generate_device_fingerprint(conn),
          {:ok, %SignInCode{} = sign_in_code} <- Accounts.insert_sign_in_code(code, code_key, device_fingerprint, user),
          :ok                                 <- send_sign_in_email(email, sign_in_code)
    do
      conn
      |> put_session("email", email)
      |> put_session("code_key", code_key)
      |> put_session("signed-in", false)
      |> json(%{status: "pending-verification"})
    else
      # User is already authenticated
      :already_signed_in ->
        workspace_slug = get_session(conn, "workspace-slug")

        conn
        |> json(%{status: "signed-in", workspaceSlug: workspace_slug})

      # We lie to the client to prevent user-enumeration attacks, but log it internally.
      {:error, reason} when reason == :not_found ->
        Logger.warning("Sign-in blocked for #{email}: #{inspect(reason)}")

        # We generate a fake token hash so the response structure doesn't leak information.
        decoy_code_key = Ecto.UUID.generate()
        conn
        |> put_session("email", email)
        |> put_session("code_key", decoy_code_key)
        |> put_session("signed-in", false)
        |> json(%{status: "pending-verification"})

      # Database Failure
      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("Database constraint failed while storing token for #{email}: #{inspect(changeset.errors)}")
        handle_sign_in_error(conn, email, :internal_server_error, "Unable to process request at this time.")

      # Email Delivery Failure
      {:error, :delivery_failed} ->
        Logger.error("Failed to dispatch sign-in verification link email to #{email}.")
        handle_sign_in_error(conn, email, :service_unavailable, "Sign-in verification email delivery failed. Please try again shortly.")

      # Catch-all
      {:error, reason} ->
        Logger.error("Unexpected error starting sign-in for #{email}: #{inspect(reason)}")
        handle_sign_in_error(conn, email, :internal_server_error, "An unexpected error occurred.")
    end
  end

  def verify(conn, %{"email" => email, "code" => code}) do
    with  code_key                            <- get_session(conn, "code_key"),
          device_fingerprint                  <- generate_device_fingerprint(conn),
          {:ok, %SignInCode{} = sign_in_code} <- Accounts.get_active_sign_in_code(code_key, device_fingerprint),
          {:ok, _}                            <- Accounts.verify_sign_in_code(sign_in_code)
    do
      Logger.info(inspect(sign_in_code))
      workspace_slug = sign_in_code.workspace.slug

      conn
      |> put_session("signed-in", true)
      |> put_session("workspace-slug", workspace_slug)
      |> json(%{status: "verified", workspaceSlug: workspace_slug})
    else
      {:error, reason} ->
        Logger.error("Unexpected error verifying sign-in code #{code} for email #{email}: #{inspect(reason)}")
        conn
        |> json(%{status: "error", error: "An unexpected error occurred."})
    end
  end

  defp check_auth(conn, email) do
    if get_session(conn, "email") == email and get_session(conn, "signed-in") do
      :already_signed_in
    else
      :not_signed_in
    end
  end


  defp send_sign_in_email(email, %SignInCode{} = sign_in_code) do
    Logger.info("to: #{email}: Your code is #{sign_in_code.code}")
    :ok
  end

  defp generate_device_fingerprint(conn) do
    # 1. Determine the real IP, looking behind proxies first
    ip_string =
      case get_req_header(conn, "x-forwarded-for") do
        [forwarded_ips | _] ->
          # The header can contain a comma-separated list (e.g., "client, proxy1, proxy2")
          # The first IP in the list is the original client
          forwarded_ips
          |> String.split(",")
          |> List.first()
          |> String.trim()

        _empty_or_missing ->
          # Fallback to direct connection IP if no proxy header exists
          conn.remote_ip |> :inet.ntoa() |> to_string()
      end

    # 2. Extract key identifying headers
    user_agent = get_req_header(conn, "user-agent") |> List.first() || "unknown"
    accept_lang = get_req_header(conn, "accept-language") |> List.first() || "unknown"

    # 3. Combine elements into a single deterministic string
    fingerprint_raw = "#{ip_string}||#{user_agent}||#{accept_lang}"
    Logger.info("Raw fingerprint: #{fingerprint_raw}")

    # 4. Hash using SHA256 and output as hex digits
    :crypto.hash(:sha256, fingerprint_raw) |> Base.encode16()
  end

  defp handle_sign_in_error(conn, email, status, client_message) do
    conn
    |> put_session("email", email)
    |> put_session("signed-in", false)
    |> put_status(status)
    |> json(%{status: "error", error: client_message})
  end
end
