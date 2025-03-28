defmodule Models.PriceGroup do
  @moduledoc """
  Defines a struct for grouping price changes for a trading symbol.
  Tracks tick counts, price changes, and provides string formatting functionality.
  """
  use TypeCheck

  @enforce_keys [
    :symbol,
    :tick_count,
    :total_price_change,
    :relative_price_change,
    :last_price,
    :last_event_time,
    :is_printed
  ]
  defstruct symbol: nil,
            tick_count: nil,
            total_price_change: nil,
            relative_price_change: nil,
            last_price: nil,
            last_event_time: nil,
            is_printed: nil

  @type! t() :: %__MODULE__{
           symbol: String.t(),
           tick_count: integer(),
           total_price_change: float(),
           relative_price_change: float(),
           last_price: float(),
           last_event_time: DateTime.t(),
           is_printed: boolean()
         }

  def to_string(%__MODULE__{
        symbol: symbol,
        last_event_time: last_event_time,
        tick_count: tick_count,
        relative_price_change: relative_price_change,
        total_price_change: total_price_change,
        last_price: last_price
      }) do
    "Symbol:#{symbol}\t Time:#{last_event_time}\t Ticks:#{tick_count}\t RPCh:#{:io_lib.format("~.2f", [relative_price_change])}\t TPCh:#{:io_lib.format("~.2f", [total_price_change])}\t LP:#{last_price}"

    # "Symbol:[#{symbol}](https://www.tradingview.com/chart/?symbol=KUCOIN:#{String.replace(symbol, "-", "")}&interval=1440)\t Time:#{last_event_time}\t Ticks:#{tick_count}\t RPCh:#{:io_lib.format("~.2f", [relative_price_change])}\t TPCh:#{:io_lib.format("~.2f", [total_price_change])}\t LP:#{last_price}"
  end

  defimpl Inspect do
    def inspect(
          %Models.PriceGroup{
            symbol: symbol,
            last_event_time: last_event_time,
            tick_count: tick_count,
            relative_price_change: relative_price_change,
            total_price_change: total_price_change,
            last_price: last_price
          },
          isColored
        ) do
      ret_val =
        "Symbol:#{symbol}\t Time:#{last_event_time}\t Ticks:#{tick_count}\t RPCh:#{:io_lib.format("~.2f", [relative_price_change])}\t TPCh:#{:io_lib.format("~.2f", [total_price_change])}\t LP:#{last_price}"

      if isColored do
        if relative_price_change < 0 do
          "\e[1;31m" <> ret_val <> "\e[0m"
        else
          "\e[1;32m" <> ret_val <> "\e[0m"
        end
      else
        ret_val
      end
    end
  end
end
