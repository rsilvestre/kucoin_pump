defmodule KucoinPump.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Skip database repo in test environment
    children = get_children()

    opts = [strategy: :one_for_one, name: KucoinPump.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Different child specs based on environment
  defp get_children do
    if Application.get_env(:kucoin_pump, :skip_db_connection, false) do
      # Skip database repo in test environment
      get_children_without_repo()
    else
      # Include database repo in non-test environments
      [KucoinPump.Repo | get_children_without_repo()]
    end
  end

  defp get_children_without_repo do
    [
      %{
        id: PriceChanges,
        start: {Application.ProcessMessage, :start_link_price_changes, []}
      },
      %{
        id: PriceGroups,
        start: {Application.ProcessMessage, :start_link_price_groups, []}
      },
      %{
        id: SimpleCache,
        start: {Storage.SimpleCache, :start_link, []}
      },
      %{
        id: EchoClient,
        start: {Application.EchoClient, :start_link, []}
      },
      %{
        id: SchedulerCompute,
        start: {Helpers.SchedulerCompute, :start_link, []}
      },
      %{
        id: SchedulerDisplay,
        start: {Helpers.SchedulerDisplay, :start_link, []}
      }
    ]
  end
end
