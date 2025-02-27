defmodule Models.PriceChange do
  use TypeCheck

  @enforce_keys [:symbol, :prev_price, :price, :total_trades, :isPrinted, :event_time]
  defstruct [:symbol, :prev_price, :price, :total_trades, :isPrinted, :event_time]

  @type! t() :: %__MODULE__{
           symbol: String.t(),
           prev_price: float(),
           price: float(),
           total_trades: integer(),
           isPrinted: boolean(),
           event_time: DateTime.t()
         }

  @spec! get_price_change_perc(%__MODULE__{}) :: float()
  def get_price_change_perc(%__MODULE__{price: price, prev_price: prev_price}) do
    case {price, prev_price} do
      {price, prev_price} when price != 0 and prev_price != 0.0 ->
        (price - prev_price) / prev_price * 100

      _ ->
        0.0
    end
  end

  @doc """
  Returns if the price change is a pump
  """
  @spec! is_pump(%__MODULE__{}, float()) :: boolean()
  def is_pump(%__MODULE__{} = price_change, lim_perc) when is_float(lim_perc) do
    get_price_change_perc(price_change) >= lim_perc
  end

  @doc """
  Returns if the price change is a dump
  """
  @spec! is_dump(%__MODULE__{}, float()) :: boolean()
  def is_dump(%__MODULE__{} = price_change, lim_perc) when is_float(lim_perc) do
    get_price_change_perc(price_change) <= -abs(lim_perc)
  end

  defimpl Inspect do
    def inspect(
          %Models.PriceChange{
            symbol: symbol,
            prev_price: prev_price,
            price: price,
            total_trades: total_trades,
            isPrinted: isPrinted,
            event_time: event_time
          },
          _
        ) do
      "Symbol:#{symbol}\t Time:#{event_time}\t PP:#{prev_price}\t P:#{price}\t TP:#{total_trades} IsPrinted:#{isPrinted}\t"
    end
  end
end
