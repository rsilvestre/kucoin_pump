defmodule Storage.EtsService do
  @moduledoc """
  https://prograils.com/elixir-erlang-term-storage
  """

  use GenServer

  @table_name :my_first_ets_table

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_init_state) do
    auth_table_pid = :ets.new(@table_name, [:set, read_concurrency: true])
    {:ok, auth_table_pid}
  end

  def insert_data(key, value) do
    GenServer.cast(__MODULE__, {:insert, {key, value}})
  end

  def find_data(key) do
    GenServer.call(__MODULE__, {:find, key})
  end

  def match_data(pattern) do
    GenServer.call(__MODULE__, {:match, pattern})
  end

  def match_object_data(pattern) do
    GenServer.call(__MODULE__, {:match_object, pattern})
  end

  def delete_data(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  def handle_cast({:insert, {key, value}}, pid) do
    :ets.insert(pid, {key, value})
    {:noreply, pid}
  end

  def handle_cast({:delete, key}, pid) do
    :ets.delete(pid, key)
    {:noreply, pid}
  end

  def handle_call({:find, key}, _from, pid) do
    result = :ets.lookup(pid, key)
    {:reply, result, pid}
  end

  def handle_call({:match, pattern}, _from, pid) do
    result = :ets.match(pid, pattern)
    {:reply, result, pid}
  end

  def handle_call({:match_object, pattern}, _from, pid) do
    result = :ets.match_object(pid, pattern)
    {:reply, result, pid}
  end
end
