defmodule Storage.ListStorage do
  @moduledoc """
  A GenServer implementation of a simple list storage.
  Provides basic operations for storing and retrieving lists of items.
  """
  use TypeCheck
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec! init(state :: list) :: {:ok, state :: list}
  def init(state) do
    {:ok, state}
  end

  @spec! push(val :: any) :: :ok
  def push(val) do
    GenServer.cast(__MODULE__, {:push_item, val})
  end

  @spec! all() :: list
  def all() do
    GenServer.call(__MODULE__, :all)
  end

  @spec! length() :: integer
  def length() do
    GenServer.call(__MODULE__, :length)
  end

  @impl true
  def handle_cast({:push_item, val}, store) do
    {:noreply, [val | store]}
  end

  @impl true
  def handle_call(:all, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:length, _from, state) do
    {:reply, length(state), state}
  end
end
