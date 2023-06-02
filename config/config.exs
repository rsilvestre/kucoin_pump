import Config

config :kucoin_pump,
  futures_api_base_url: "https://api-futures.kucoin.com",
  api_base_url: "https://api.kucoin.com",
  show_only_pair: "USDT",
  # minimum top query limit
  show_limit: 1,
  # min percentage change
  min_perc: 0.05
