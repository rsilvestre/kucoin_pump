ExUnit.start(exclude: [:integration, :db, :websocket])

# Create necessary test directories if they don't exist
File.mkdir_p!("test/support")

# Load test support files
Code.require_file("support/test_setup.exs", __DIR__)

# Define an Ecto.Repo behavior to be mocked
defmodule KucoinPump.RepoCallbacks do
  @callback insert(changeset :: Ecto.Changeset.t()) :: {:ok, map()} | {:error, any()}
  @callback one(query :: term()) :: map() | nil
  @callback all(query :: term()) :: [map()]
  @callback get(module :: atom(), id :: term()) :: map() | nil
end

# Define mocks for testing
Mox.defmock(KucoinPump.RepoMock, for: KucoinPump.RepoCallbacks)

# Define a GenServer behavior to be mocked
defmodule GenServerBehavior do
  @callback call(pid(), term(), timeout()) :: term()
  @callback cast(pid(), term()) :: :ok
end

Mox.defmock(GenServerMock, for: GenServerBehavior)

# Define a behavior for Telegram API
defmodule Telegram.TestBehavior do
  @callback request(binary(), binary(), keyword()) :: {:ok, map()} | {:error, any()}
end

Mox.defmock(TelegramMock, for: Telegram.TestBehavior)

# Configure application tests to avoid database connections
Application.put_env(:kucoin_pump, :ecto_repos, [])

# This is already mocked elsewhere or doesn't need to be mocked
# We'll handle Repo database connection issues differently

# Create GenServer processes for MapStorage and SimpleCache
# but handle if already started (which can happen in test reloads)
case GenServer.start_link(Storage.MapStorage, %{}, name: PriceChanges) do
  {:ok, _} -> :ok
  {:error, {:already_started, _}} -> :ok
end

case GenServer.start_link(Storage.MapStorage, %{}, name: PriceGroups) do
  {:ok, _} -> :ok
  {:error, {:already_started, _}} -> :ok
end

case Storage.SimpleCache.start_link() do
  {:ok, _} -> :ok
  {:error, {:already_started, _}} -> :ok
end

# Define a module to mock Ecto.Adapters.SQL functionality
defmodule Ecto.Adapters.SQL do
  def query!(_repo, _query, _args) do
    %Postgrex.Result{
      command: :select,
      columns: ["sym", "rsi", "pch", "np", "lp", "tpch", "rpch", "t", "reg_slope", "reg_intercept", "trend"],
      rows: [
        [
          "BTC-USDT",
          60.5,
          2.3,
          15,
          35000.0,
          120.5,
          5.7,
          ~N[2023-06-07 17:01:36.000000],
          0.25,
          34500.0,
          "positive"
        ]
      ],
      num_rows: 1
    }
  end
end

# Mock methods directly in KucoinPump.Repo module
defmodule KucoinPump.Repo do
  def one(_query), do: nil
  def insert(_changeset), do: {:ok, %{}}
  def query!(_sql, _args) do
    %Postgrex.Result{
      command: :select,
      columns: ["sym", "rsi", "pch", "np", "lp", "tpch", "rpch", "t", "reg_slope", "reg_intercept", "trend"],
      rows: [
        [
          "BTC-USDT",
          60.5,
          2.3,
          15,
          35000.0,
          120.5,
          5.7,
          ~N[2023-06-07 17:01:36.000000],
          0.25,
          34500.0,
          "positive"
        ]
      ],
      num_rows: 1
    }
  end
  def start_link(_), do: {:ok, self()}
end

# Set environment variables for tests
# These will be used by tests instead of trying to mock Application.compile_env
Application.put_env(:kucoin_pump, :show_only_pair, "USDT")
Application.put_env(:kucoin_pump, :show_limit, 5)
Application.put_env(:kucoin_pump, :min_perc, 2.0)
Application.put_env(:kucoin_pump, :telegram_bot_token, "test_token")
Application.put_env(:kucoin_pump, :telegram_chat_id, 12345)
Application.put_env(:kucoin_pump, :data_window_in_minutes, 60)
Application.put_env(:kucoin_pump, :telegram_enabled, false)
