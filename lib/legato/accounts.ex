defmodule Legato.Accounts do
  require Logger
  import Ecto.Query
  alias Legato.{Repo, User, SignInCode, Workspace}

  def get_user_by_email(email) when is_binary(email) do
    User
    # 1. Join the workspace table on the foreign key relationship
    |> join(:inner, [u], w in assoc(u, :workspace))
    # 2. Check both the user email/status AND the workspace status
    |> where([u, w], u.email == ^email and not u.is_deleted and w.status == :active)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      user ->
        Logger.info(user)
        {:ok, user}
    end
  end

  def insert_sign_in_code(code, code_key, device_fingerprint, %User{} = user) do
    expires_at = DateTime.utc_now() |> DateTime.shift(minute: 5)

    params = %{
      "workspace_id" => user.workspace_id,
      "user_id" => user.id,
      "code" => code,
      "code_key" => code_key,
      "device_fingerprint" => device_fingerprint,
      "expires_at" => expires_at
    }

    SignInCode.changeset(%SignInCode{}, params)
    |> Repo.insert()
    |> case do
      {:ok, sign_in_code} ->
        {:ok, Repo.preload(sign_in_code, [:workspace, :user])}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def get_active_sign_in_code(code_key, code, device_fingerprint) do
    now = DateTime.utc_now()
    code_int = String.to_integer(code)

    SignInCode
    |> where(
        [s],
        s.code_key == ^code_key
          and s.code == ^code_int
          and is_nil(s.verified_at)
          and s.expires_at > ^now
          and s.device_fingerprint == ^device_fingerprint
      )
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      sign_in_code -> {:ok, Repo.preload(sign_in_code, [:workspace, :user])}
    end
  end

  def verify_sign_in_code(%SignInCode{} = sign_in_code) do
    now = DateTime.utc_now()

    attrs = %{
      "verified_at" => now
    }

    SignInCode.verification_changeset(sign_in_code, attrs)
    |> Repo.update()
  end

  @spec get_workspace(binary()) :: {:error, :not_found} | {:ok, any()}
  def get_workspace(workspace_id) when is_binary(workspace_id) do
    case Repo.get_by(Workspace, id: workspace_id, status: :active) do
      nil -> {:error, :not_found}
      workspace -> {:ok, workspace}
    end
  end

  def get_workspace_users(workspace_id) when is_binary(workspace_id) do
    users =
      User
      |> join(:inner, [u], w in Workspace, on: u.workspace_id == w.id)
      |> where([u, w], w.id == ^workspace_id and w.status == :active)
      |> Repo.all()

    {:ok, users}
  end
end
