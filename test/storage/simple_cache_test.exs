defmodule Storage.SimpleCacheTest do
  use ExUnit.Case
  alias Storage.SimpleCache
  require Logger

  setup do
    {:ok, pid} = SimpleCache.start_link()
    {:ok, pid: pid}
  end

  @tag :skip
  test "handle cast", %{pid: pid} do
    assert Storage.SimpleCache.handle_cast(
             {:insert, {[Storage.SimpleCacheTest, :test_fun, [[1, 2, 3]]], 6, 2}},
             pid
           ) == :noreply

    assert :ets.lookup(Storage.SimpleCacheTest, :test_fun, [1, 2, 3]) == [[1, 2, 3], 6, 2]
  end

  @tag :skip
  test "cache is empty initially", %{pid: _pid} do
    assert SimpleCache.lookup(Storage.SimpleCache, :test_fun, [1, 2, 3]) == nil
  end

  @tag :skip
  test "cache value is returned if still fresh", %{pid: _pid} do
    result = SimpleCache.get(Storage.SimpleCache, :test_fun, [1, 2, 3])
    assert SimpleCache.lookup(Storage.SimpleCache, :test_fun, [1, 2, 3]) == result
  end

  @tag :skip
  test "new value is returned if stale", %{pid: _pid} do
    result = SimpleCache.get(Storage.SimpleCache, :test_fun, [1, 2, 3], ttl: 1)
    assert SimpleCache.lookup(Storage.SimpleCache, :test_fun, [1, 2, 3]) == result
    :timer.sleep(2000)
    assert SimpleCache.lookup(Storage.SimpleCache, :test_fun, [1, 2, 3]) == nil
  end

  def test_fun([a, b, c]) do
    Logger.debug("test_fun ran")
    a + b + c
  end
end
