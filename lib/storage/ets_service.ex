defmodule Storage.EtsService do
  @moduledoc """
  https://prograils.com/elixir-erlang-term-storage
  """

  use TypeCheck
  use GenServer

  @table_name :my_first_ets_table

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_init_state) do
    auth_table_pid = :ets.new(@table_name, [:set, read_concurrency: true])
    {:ok, auth_table_pid}
  end

  @spec! insert_data(key :: any, value :: any) :: :ok
  def insert_data(key, value) do
    GenServer.cast(__MODULE__, {:insert, {key, value}})
  end

  @spec! find_data(key :: any) :: any
  def find_data(key) do
    GenServer.call(__MODULE__, {:find, key})
  end

  @spec! match_data(pattern :: any) :: any
  def match_data(pattern) do
    GenServer.call(__MODULE__, {:match, pattern})
  end

  @spec! match_object_data(pattern :: any) :: any
  def match_object_data(pattern) do
    GenServer.call(__MODULE__, {:match_object, pattern})
  end

  @spec! delete_data(key :: any) :: :ok
  def delete_data(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  @impl true
  def handle_cast({:insert, {key, value}}, pid) do
    :ets.insert(pid, {key, value})
    {:noreply, pid}
  end

  @impl true
  def handle_cast({:delete, key}, pid) do
    :ets.delete(pid, key)
    {:noreply, pid}
  end

  @impl true
  def handle_call({:find, key}, _from, pid) do
    result = :ets.lookup(pid, key)
    {:reply, result, pid}
  end

  @impl true
  def handle_call({:match, pattern}, _from, pid) do
    result = :ets.match(pid, pattern)
    {:reply, result, pid}
  end

  @impl true
  def handle_call({:match_object, pattern}, _from, pid) do
    result = :ets.match_object(pid, pattern)
    {:reply, result, pid}
  end
end
