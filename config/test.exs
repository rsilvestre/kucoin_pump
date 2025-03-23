import Config

# Configure the database for testing - use a dummy database configuration
# that won't actually connect to reduce error logs
config :kucoin_pump, KucoinPump.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "kucoin_pump_test",
  hostname: "localhost",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 1,
  ownership_timeout: 60_000,
  # Set the queue target to 5000ms to reduce connection attempts
  queue_target: 5000,
  queue_interval: 10000,
  # Disable reconnect attempts
  backoff_type: :stop

# Don't actually connect to database in most tests
config :kucoin_pump, 
  ecto_repos: [],  # Use this to disable automatic repo startup
  skip_db_connection: true  # Custom flag we can check in our test helper

# Configure database to use a mock pool handler to prevent connection attempts
config :kucoin_pump, KucoinPump.Repo,
  pool: Ecto.Adapters.SQL.Sandbox

# Configure test-specific application settings
config :kucoin_pump,
  show_only_pair: "USDT",
  show_limit: 5,
  min_perc: 2.0,
  telegram_enabled: false,
  telegram_bot_token: "test_token",
  telegram_chat_id: 12345,
  data_window_in_minutes: 60,
  display_refresh_rate: 1000,
  compute_refresh_rate: 500,
  futures_api_base_url: "https://test-futures.kucoin.com",
  api_base_url: "https://test-api.kucoin.com"
  
# Configure the mocking system for tests
config :kucoin_pump, :telegram_api, TelegramMock

# Reduce log output during tests
config :logger, level: :warning