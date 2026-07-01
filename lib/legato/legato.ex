defmodule Legato.Legato do
  import Ecto.Query
  alias Legato.Repo
  # alias Legato.Workspace
  alias Legato.User
  # alias Legato.SignInToken

  def get_user_by_email(email) when is_binary(email) do
    User
    |> where([u], u.email == ^email and not u.is_deleted)
    |> preload(:workspace)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

end
