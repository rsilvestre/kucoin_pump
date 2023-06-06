defmodule KucoinPump.PriceGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "price_groups" do
    field(:symbol, :string)
    field(:tick_count, :integer)
    field(:relative_price_change, :float)
    field(:last_price, :float)
    field(:last_event_time, :utc_datetime)
    field(:total_price_change, :float)

    timestamps()
  end

  @doc false
  def changeset(price_group, attrs) do
    price_group
    |> cast(attrs, [
      :symbol,
      :tick_count,
      :relative_price_change,
      :last_price,
      :last_event_time,
      :total_price_change
    ])
    |> validate_required([
      :symbol,
      :tick_count,
      :relative_price_change,
      :last_price,
      :last_event_time,
      :total_price_change
    ])
  end
end
