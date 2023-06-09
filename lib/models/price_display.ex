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
    :reg_slope,
    :reg_intercept,
    :trend,
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
            reg_slope: nil,
            reg_intercept: nil,
            trend: nil,
            isPrinted: false

  @type! t() :: %__MODULE__{
           symbol: String.t(),
           rsi: float(),
           relative_price_change: float(),
           nomber_of_event: integer(),
           last_price: float(),
           last_total_price_change: float(),
           last_relative_price_change: float(),
           last_event_time: DateTime.t(),
           reg_slope: float(),
           reg_intercept: float(),
           trend: String.t(),
           isPrinted: boolean()
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
        last_event_time: last_event_time,
        reg_slope: reg_slope,
        reg_intercept: reg_intercept,
        trend: trend
      }) do
    %__MODULE__{
      symbol: symbol,
      rsi: rsi,
      relative_price_change: relative_price_change,
      nomber_of_event: nomber_of_event,
      last_price: last_price,
      last_total_price_change: last_total_price_change,
      last_relative_price_change: last_relative_price_change,
      last_event_time: last_event_time,
      reg_slope: reg_slope,
      reg_intercept: reg_intercept,
      trend: trend
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
    |> Map.put(:reg_slope, Map.get(event, "reg_slope"))
    |> Map.put(:reg_intercept, Map.get(event, "reg_intercept"))
    |> Map.put(:trend, Map.get(event, "trend"))
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
        last_event_time: last_event_time,
        reg_slope: reg_slope,
        reg_intercept: reg_intercept,
        trend: trend
      }) do
    "Symbol:#{symbol}\t Time:#{last_event_time}\t RSI:#{:io_lib.format("~.2f", [rsi])}\t RPCh:#{:io_lib.format("~.2f", [relative_price_change])}\t NOE:#{nomber_of_event}\t LP:#{:io_lib.format("~.2f", [last_price])}\t LTPCh:#{:io_lib.format("~.2f", [last_total_price_change])}\t LRPCh:#{:io_lib.format("~.2f", [last_relative_price_change])}\t Slope:#{:io_lib.format("~.5f", [reg_slope])}\t Intercept:#{:io_lib.format("~.2f", [reg_intercept])}\t Trend:#{trend}"
  end

  def to_table(%__MODULE__{} = price_display) do
    [
      price_display.symbol,
      price_display.last_event_time,
      :io_lib.format("~.2f", [price_display.rsi]),
      :io_lib.format("~.2f", [price_display.relative_price_change]),
      price_display.nomber_of_event,
      :io_lib.format("~.2f", [price_display.last_price]),
      :io_lib.format("~.2f", [price_display.last_total_price_change]),
      :io_lib.format("~.2f", [price_display.last_relative_price_change]),
      :io_lib.format("~.2f", [price_display.reg_slope]),
      :io_lib.format("~.2f", [price_display.reg_intercept]),
      price_display.trend
    ]
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
            last_event_time: last_event_time,
            reg_slope: reg_slope,
            reg_intercept: reg_intercept,
            trend: trend
          },
          isColored
        ) do
      ret_val =
        "Symbol:#{symbol}\t Time:#{last_event_time}\t RSI:#{:io_lib.format("~.2f", [rsi])}\t RPCh:#{:io_lib.format("~.2f", [relative_price_change])}\t NOE:#{nomber_of_event}\t LP:#{:io_lib.format("~.2f", [last_price])}\t LTPCh:#{:io_lib.format("~.2f", [last_total_price_change])}\t LRPCh:#{:io_lib.format("~.2f", [last_relative_price_change])}\t Slope:#{:io_lib.format("~.2f", [reg_slope])}\t Intercept:#{:io_lib.format("~.2f", [reg_intercept])}\t Trend:#{trend}"

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
