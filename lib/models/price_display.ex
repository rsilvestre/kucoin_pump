defmodule Models.PriceDisplay do
  use TypeCheck

  @enforce_keys [
    :symbol,
    :rsi,
    :relative_price_change,
    :nomber_of_event,
    :last_price,
    :last_total_price_change,
    :last_relative_price_change,
    :last_event_time
  ]
  defstruct symbol: nil,
        rsi: nil,
        relative_price_change: nil,
        nomber_of_event: nil,
        last_price: nil,
        last_total_price_change: nil,
        last_relative_price_change: nil,
        last_event_time: nil,
        isPrinted: false

  @type! t() :: %__MODULE__{
           symbol: String.t(),
           rsi: float(),
           relative_price_change: float(),
           nomber_of_event: integer(),
           last_price: float(),
           last_total_price_change: float(),
           last_relative_price_change: float(),
           last_event_time: DateTime.t()
         }

  @spec! new(map()) :: %__MODULE__{}
  def new(%{
        symbol: symbol,
        rsi: rsi,
        relative_price_change: relative_price_change,
        nomber_of_event: nomber_of_event,
        last_price: last_price,
        last_total_price_change: last_total_price_change,
        last_relative_price_change: last_relative_price_change,
        last_event_time: last_event_time
  }) do
    %__MODULE__{
        symbol: symbol,
        rsi: rsi,
        relative_price_change: relative_price_change,
        nomber_of_event: nomber_of_event,
        last_price: last_price,
        last_total_price_change: last_total_price_change,
        last_relative_price_change: last_relative_price_change,
        last_event_time: last_event_time
    }
  end

  @spec! from_result_to_message(map()) :: %__MODULE__{}
  def from_result_to_message(event) do
    %{}
    |> Map.put(:symbol, Map.get(event, "sym"))
    |> Map.put(:rsi, Map.get(event, "rsi"))
    |> Map.put(:relative_price_change, Map.get(event, "pch"))
    |> Map.put(:nomber_of_event, Map.get(event, "np"))
    |> Map.put(:last_price, Map.get(event, "lp"))
    |> Map.put(:last_total_price_change, Map.get(event, "tpch"))
    |> Map.put(:last_relative_price_change, Map.get(event, "rpch"))
    |> Map.put(:last_event_time, Map.get(event, "t"))
    |> __MODULE__.new()
  end

  def to_string(%__MODULE__{
        symbol: symbol,
        rsi: rsi,
        relative_price_change: relative_price_change,
        nomber_of_event: nomber_of_event,
        last_price: last_price,
        last_total_price_change: last_total_price_change,
        last_relative_price_change: last_relative_price_change,
        last_event_time: last_event_time
      }) do
    "Symbol:#{symbol}\t Time:#{last_event_time}\t RSI:#{:io_lib.format("~.2f", [rsi])}\t RPCh:#{:io_lib.format("~.2f", [relative_price_change])}\t NOE:#{nomber_of_event}\t LP:#{:io_lib.format("~.2f", [last_price])}\t LTPCh:#{:io_lib.format("~.2f", [last_total_price_change])}\t LRPCh:#{:io_lib.format("~.2f", [last_relative_price_change])}"
  end

  defimpl Inspect do
    def inspect(
          %Models.PriceDisplay{
            symbol: symbol,
            rsi: rsi,
            relative_price_change: relative_price_change,
            nomber_of_event: nomber_of_event,
            last_price: last_price,
            last_total_price_change: last_total_price_change,
            last_relative_price_change: last_relative_price_change,
            last_event_time: last_event_time
          },
          isColored
        ) do
      ret_val = "Symbol:#{symbol}\t Time:#{last_event_time}\t RSI:#{:io_lib.format("~.2f", [rsi])}\t RPCh:#{:io_lib.format("~.2f", [relative_price_change])}\t NOE:#{nomber_of_event}\t LP:#{:io_lib.format("~.2f", [last_price])}\t LTPCh:#{:io_lib.format("~.2f", [last_total_price_change])}\t LRPCh:#{:io_lib.format("~.2f", [last_relative_price_change])}"

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
