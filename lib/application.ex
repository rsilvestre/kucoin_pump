defmodule ElixirKucoinPump.Application do

  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      #{Storage.EtsService, []},
      #{Storage.MapStorage, []},
      %{
        id: PriceChanges,
        start: {ProcessMessage, :start_link_price_changes, []}
      },
      %{
        id: PriceGroups,
        start: {ProcessMessage, :start_link_price_groups, []}
      },
    ]

    opts = [strategy: :one_for_one, name: ElixirKucoinPump.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
