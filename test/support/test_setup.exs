defmodule KucoinPump.TestSupport do
  # Helper for setting up test processes
  def setup_test_processes do
    # Start processes needed for tests
    {:ok, _} = Application.ensure_all_started(:ecto)
    
    # Return empty map as context
    %{}
  end
  
  # Helper for mocking GenServer calls
  def mock_genserver_call(module, fun, args, result) do
    Mox.expect(GenServerMock, :call, fn ^module, ^fun, ^args -> result end)
  end
  
  # Helper for mocking GenServer.cast
  def mock_genserver_cast(module, fun, args, result \\ :ok) do
    Mox.expect(GenServerMock, :cast, fn ^module, ^fun, ^args -> result end)
  end
  
  # Helper for mocking Repo functions
  def mock_repo_get(id, result) do
    Mox.expect(KucoinPump.RepoMock, :get, fn _module, ^id -> result end)
  end
  
  def mock_repo_insert(_changeset_pattern, result) do
    Mox.expect(KucoinPump.RepoMock, :insert, fn _changeset -> result end)
  end
  
  # Helper for creating test data structures
  def create_test_price_change(opts \\ []) do
    defaults = [
      symbol: "TEST-USDT",
      prev_price: 100.0,
      price: 105.0,
      total_trades: 10,
      is_printed: false,
      event_time: DateTime.utc_now()
    ]
    
    merged_opts = Keyword.merge(defaults, opts)
    
    struct(Models.PriceChange, merged_opts)
  end
  
  def create_test_price_group(opts \\ []) do
    defaults = [
      symbol: "TEST-USDT",
      tick_count: 10,
      total_price_change: 50.0,
      relative_price_change: 5.0,
      last_price: 105.0,
      last_event_time: DateTime.utc_now(),
      is_printed: false
    ]
    
    merged_opts = Keyword.merge(defaults, opts)
    
    struct(Models.PriceGroup, merged_opts)
  end
end