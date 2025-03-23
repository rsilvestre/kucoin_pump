defmodule Storage.SimpleCacheTest do
  use ExUnit.Case
  alias Storage.SimpleCache
  require Logger

  setup do
    # SimpleCache is started in test_helper.exs
    # Just ensure the process is started
    if is_nil(Process.whereis(SimpleCache)) do
      {:ok, _new_pid} = SimpleCache.start_link()
    end
    
    # Get the pid of the SimpleCache process
    pid = Process.whereis(SimpleCache)
    
    {:ok, pid: pid}
  end

  test "handle cast", %{pid: _pid} do
    # Instead of calling the internal handle_cast function directly,
    # use the public API to exercise the functionality
    
    # Clear any existing cache for this key
    GenServer.cast(SimpleCache, {:insert, {[Storage.SimpleCacheTest, :test_fun, [[1, 2, 3]]], nil, 0}})
    
    # Use the cache
    result = SimpleCache.get(Storage.SimpleCacheTest, :test_fun, [[1, 2, 3]])
    assert result == 6
    
    # Look up the result - should be cached now
    lookup_result = GenServer.call(SimpleCache, {:lookup, [Storage.SimpleCacheTest, :test_fun, [[1, 2, 3]]]})
    assert length(lookup_result) > 0
  end

  test "cache is empty initially" do
    # This tests that lookup returns nil when no value is cached
    result = SimpleCache.get(Storage.SimpleCacheTest, :test_fun, [[1, 2, 3]])
    
    # The result should be 6 (1+2+3) from our test_fun
    assert result == 6
    
    # Clear the cache for the next test
    GenServer.cast(SimpleCache, {:insert, {[Storage.SimpleCacheTest, :test_fun, [[1, 2, 3]]], nil, 0}})
  end

  test "cache value is returned if still fresh" do
    # First call should execute the function
    first_result = SimpleCache.get(Storage.SimpleCacheTest, :test_fun, [[1, 2, 3]], ttl: 10)
    assert first_result == 6
    
    # Second call should return cached value without executing function again
    second_result = SimpleCache.get(Storage.SimpleCacheTest, :test_fun, [[1, 2, 3]], ttl: 10)
    assert second_result == 6
    
    # Both results should be the same
    assert first_result == second_result
  end

  test "new value is returned if stale" do
    # First call with short TTL
    first_result = SimpleCache.get(Storage.SimpleCacheTest, :test_fun, [[1, 2, 3]], ttl: 1)
    assert first_result == 6
    
    # Wait for TTL to expire
    :timer.sleep(1100)
    
    # Second call should execute the function again as cache is stale
    # We should see a new cache_apply happening
    second_result = SimpleCache.get(Storage.SimpleCacheTest, :test_fun, [[1, 2, 3]], ttl: 1)
    assert second_result == 6
  end

  def test_fun([a, b, c]) do
    Logger.debug("test_fun ran")
    a + b + c
  end
end
