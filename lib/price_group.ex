defmodule PriceGroup do
  use TypeCheck

  @enforce_keys [:symbol, :tick_count, :total_price_change, :relative_price_change, :last_price, :last_event_time, :isPrinted]
  defstruct [
    symbol: nil,
    tick_count: nil,
    total_price_change: nil,
    relative_price_change: nil,
    last_price: nil,
    last_event_time: nil,
    isPrinted: nil
  ]
  @type! t() :: %__MODULE__{
          symbol: String.t(),
          tick_count: integer(),
          total_price_change: float(),
          relative_price_change: float(),
          last_price: float(),
          last_event_time: DateTime.t(),
          isPrinted: boolean(),
        }

  defimpl Inspect do
    def inspect(%PriceGroup{
      symbol: symbol,
      last_event_time: last_event_time,
      tick_count: tick_count,
      relative_price_change: relative_price_change,
      total_price_change: total_price_change,
      last_price: last_price,
    }, isColored) do
      ret_val = "Symbol:#{symbol}\t Time:#{last_event_time}\t Ticks:#{tick_count}\t RPCh:#{:io_lib.format("~.2f", [relative_price_change])}\t TPCh:#{:io_lib.format("~.2f", [total_price_change])}\t LP:#{last_price}\t"

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
