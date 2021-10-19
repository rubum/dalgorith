defmodule Dalgorith.Repo do
  use Ecto.Repo,
    otp_app: :dalgorith,
    adapter: Ecto.Adapters.Postgres
end
