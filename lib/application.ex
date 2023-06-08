defmodule KucoinPump.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # {Storage.EtsService, []},
      # {Storage.MapStorage, []},
      KucoinPump.Repo,
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

    opts = [strategy: :one_for_one, name: KucoinPump.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
