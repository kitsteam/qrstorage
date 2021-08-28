defmodule Qrstorage.Repo do
  use Ecto.Repo,
    otp_app: :qrstorage,
    adapter: Ecto.Adapters.Postgres
end
