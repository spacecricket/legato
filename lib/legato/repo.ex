defmodule Legato.Repo do
  use Ecto.Repo,
    otp_app: :legato,
    adapter: Ecto.Adapters.Postgres
end
