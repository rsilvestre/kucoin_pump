import Config

config :kucoin_pump,
  futures_api_base_url: "https://api-futures.kucoin.com",
  api_base_url: "https://api.kucoin.com",
  show_only_pair: "USDT",
  # minimum top query limit
  show_limit: 10,
  # min percentage change
  min_perc: 0.05,
  compute_refresh_rate: 1_000,
  display_refresh_rate: 10_000,
  data_window_in_minutes: 60,
  # enable or disable Telegram notifications
  telegram_enabled: false

config :kucoin_pump,
  ecto_repos: [KucoinPump.Repo]

for config <- "./secrets.exs" |> Path.expand(__DIR__) |> Path.wildcard() do
  import_config config
end

config :elixir, :time_zone_database, Tz.TimeZoneDatabase
