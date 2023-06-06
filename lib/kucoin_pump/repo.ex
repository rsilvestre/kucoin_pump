defmodule KucoinPump.Repo do
  use Ecto.Repo,
    otp_app: :kucoin_pump,
    adapter: Ecto.Adapters.Postgres
end
