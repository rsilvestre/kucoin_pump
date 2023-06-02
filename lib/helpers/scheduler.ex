defmodule Helpers.Scheduler do

  use TypeCheck
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  @spec! init(state :: map) :: {:ok, state :: map}
  def init(state) do
    # Schedule work to be performed on start
    schedule_work()

    {:ok, state}
  end

  @impl true
  @spec! handle_info(any(), state :: map) :: {:noreply, state :: map}
  def handle_info(:work, state) do
    ProcessMessage.compute_price_changes()

    # Reschedule once more
    schedule_work()

    {:noreply, state}
  end

  @spec! schedule_work() :: :ok
  defp schedule_work do
    # We schedule the work to happen in 2 hours (written in milliseconds).
    # Alternatively, one might write :timer.hours(2)
    #Process.send_after(self(), :work, 2 * 60 * 60 * 1000)
    Process.send_after(self(), :work, 1000)

    :ok
  end
end
