defmodule Storage.MapStorage do
  @moduledoc """
  https://gist.github.com/alanpeabody/0802e6051d141e2043c3
  """

  use TypeCheck
  use GenServer

  # API

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec! init(state :: map) :: {:ok, state :: map}
  def init(state) do
    {:ok, state}
  end

  @spec! set_item(key :: any, val :: any) :: :ok
  def set_item(key, val) do
    GenServer.cast(__MODULE__, {:set_item, key, val})
  end

  @spec! get_item(key :: any) :: any
  def get_item(key) do
    GenServer.call(__MODULE__, {:get_item, key})
  end

  @spec! get_keys() :: list
  def get_keys() do
    GenServer.call(__MODULE__, :get_keys)
  end

  @spec! has_key?(key :: any) :: boolean
  def has_key?(key) do
    GenServer.call(__MODULE__, {:has_key, key}) != nil
  end

  @spec! remove_item(key :: any) :: :ok
  def remove_item(key) do
    GenServer.cast(__MODULE__, {:remove_item, key})
  end

  @spec! clear() :: :ok
  def clear() do
    GenServer.cast(__MODULE__, :clear)
  end

  @spec! all() :: map
  def all() do
    GenServer.call(__MODULE__, :all)
  end

  @spec! length() :: integer
  def length() do
    GenServer.call(__MODULE__, :length)
  end

  # GenServer Callbacks

  @impl true
  def handle_cast({:set_item, key, val}, store) do
    {:noreply, Map.put(store, key, val)}
  end

  @impl true
  def handle_cast({:remove_item, key}, store) do
    {:noreply, Map.drop(store, key)}
  end

  @impl true
  def handle_cast(:clear, _store) do
    {:noreply, %{}}
  end

  @impl true
  def handle_call({:get_item, key}, _from, store) do
    {:reply, Map.get(store, key), store}
  end

  @impl true
  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:length, _from, store) do
    {:reply, length(Map.keys(store)), store}
  end

  @impl true
  def handle_call({:has_key, key}, _from, store) do
    {:reply, Map.has_key?(store, key), store}
  end

  @impl true
  def handle_call(:get_keys, _from, store) do
    {:reply, Map.keys(store), store}
  end
end
