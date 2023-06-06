import Config

config :kucoin_pump,
  telegram_bot_token: System.get_env("TELEGRAM_BOT_TOKEN"),
  # telegram_chat_id: String.to_integer(System.get_env("TELEGRAM_CHAT_ID"))
  telegram_chat_id: System.get_env("TELEGRAM_CHAT_ID") |> String.to_integer()

config :kucoin_pump, KucoinPump.Repo,
  database: System.get_env("PGDATABASE"),
  username: System.get_env("PGUSER"),
  password: System.get_env("PGPASSWORD"),
  hostname: System.get_env("PGHOST"),
  port: System.get_env("PGPORT"),
  log: false
