defmodule Storage.SimpleCache do
  @moduledoc """
  A simple ETS based cache for expensive function calls.
  """

  @doc """
  Retrieve a cached value or apply the given function caching and returning
  the result.
  """

  use TypeCheck
  use GenServer

  @table_name :simple_cache

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_init_state) do
    auth_table_pid = :ets.new(@table_name, [:set, read_concurrency: true])
    {:ok, auth_table_pid}
  end

  @spec! get(mod :: module, fun :: atom, args :: list, opts :: Keyword.t) :: any
  def get(mod, fun, args, opts \\ []) do
    case lookup(mod, fun, args) do
      nil ->
        ttl = Keyword.get(opts, :ttl, 3600)
        cache_apply(mod, fun, args, ttl)

      result ->
        result
    end
  end

  @spec! lookup(mod :: module, fun :: atom, args :: list) :: any
  defp lookup(mod, fun, args) do
    case GenServer.call(__MODULE__, {:lookup, [mod, fun, args]}) do
      [result | _] -> check_freshness(result)
      [] -> nil
    end
  end

  @spec! check_freshness({mfa :: list, result :: any, expiration :: integer}) :: any
  defp check_freshness({_mfa, result, expiration}) do
    cond do
      expiration > :os.system_time(:seconds) -> result
      :else -> nil
    end
  end

  @spec! cache_apply(mod :: module, fun :: atom, args :: list, ttl :: integer) :: any
  defp cache_apply(mod, fun, args, ttl) do
    result = apply(mod, fun, args)
    expiration = :os.system_time(:seconds) + ttl
    GenServer.cast(__MODULE__, {:insert, {[mod, fun, args], result, expiration}})
    result
  end

  @impl true
  def handle_call({:lookup, [mod, fun, args]}, _from, pid) do
    {:reply, :ets.lookup(pid, [mod, fun, args]), pid}
  end

  @impl true
  def handle_cast({:insert, {[mod, fun, args], result, expiration}}, pid) do
    :ets.insert(pid, {[mod, fun, args], result, expiration})
    {:noreply, pid}
  end
end
