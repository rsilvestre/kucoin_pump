defmodule Helpers.SchedulerDisplay do
  @moduledoc """
  GenServer that schedules periodic display of price changes.
  Runs at intervals defined by the application's display_refresh_rate setting.
  """
  use TypeCheck
  use GenServer

  @refresh_rate Application.compile_env(:kucoin_pump, :display_refresh_rate)

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    # Schedule work to be performed on start
    schedule_work()

    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    Application.ProcessMessage.display_price_changes()

    # Reschedule once more
    schedule_work()

    {:noreply, state}
  end

  @spec! schedule_work() :: :ok
  defp schedule_work do
    # We schedule the work to happen in 2 hours (written in milliseconds).
    # Alternatively, one might write :timer.hours(2)
    # Process.send_after(self(), :work, 2 * 60 * 60 * 1000)
    Process.send_after(self(), :work, @refresh_rate)

    :ok
  end
end
