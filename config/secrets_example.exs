import Config

config :kucoin_pump,
  # set to true to enable Telegram notifications
  telegram_enabled: false,
  telegram_bot_token: "5552398:YourToken-H3r3",
  telegram_chat_id: -123_456_789

config :kucoin_pump, KucoinPump.Repo,
  database: "kucoin_pump_repo",
  username: "postgres",
  password: "",
  hostname: "localhost",
  port: 5432,
  log: false
