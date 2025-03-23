defmodule KucoinPump.Repo do
  @moduledoc """
  Ecto repository for database operations.
  Configured to use PostgreSQL as the database backend.
  """
  use Ecto.Repo,
    otp_app: :kucoin_pump,
    adapter: Ecto.Adapters.Postgres
end
