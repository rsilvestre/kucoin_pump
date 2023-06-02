defmodule Storage.Stack do
  @moduledoc """
  https://elixir-lang.org/getting-started/mix-otp/genserver.html
  """

  use TypeCheck
  use GenServer

  # Client

  def start_link(default) when is_binary(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @spec! push(pid :: pid, element :: any) :: :ok
  def push(pid, element) do
    GenServer.cast(pid, {:push, element})
  end

  @spec! pop(pid :: pid) :: any
  def pop(pid) do
    GenServer.call(pid, :pop)
  end

  # Server (callbacks)

  @impl true
  def init(elements) do
    initial_state = String.split(elements, ",", trim: true)
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:pop, _from, state) do
    [to_caller | new_state] = state
    {:reply, to_caller, new_state}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    new_state = [element | state]
    {:noreply, new_state}
  end
end
