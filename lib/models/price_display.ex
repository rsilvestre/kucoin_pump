defmodule Models.PriceDisplay do
  @moduledoc """
  Defines a struct for displaying price data with various metrics like RSI, price changes, trend analysis.
  Includes formatting functions for displaying price data in the terminal.
  """
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
            is_printed: false

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
           is_printed: boolean()
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

  def to_display_string(%__MODULE__{
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
    "Symbol:#{symbol}\t Time:#{last_event_time}\t RSI:#{format_float(rsi)}\t RPCh:#{format_float(relative_price_change)}\t NOE:#{nomber_of_event}\t LP:#{format_float(last_price)}\t LTPCh:#{format_float(last_total_price_change)}\t LRPCh:#{format_float(last_relative_price_change)}\t Slope:#{format_float(reg_slope, "~.5f")}\t Intercept:#{format_float(reg_intercept)}\t Trend:#{trend || "unknown"}"
  end

  @spec! format_float(any(), String.t()) :: String.t()
  def format_float(value, format \\ "~.2f")
  def format_float(nil, _format), do: "N/A"

  def format_float(value, format) when is_float(value),
    do: to_string(:io_lib.format(format, [value]))

  def format_float(value, _format) when is_integer(value), do: to_string(value)
  def format_float(_value, _format), do: "N/A"

  def to_table(%__MODULE__{} = price_display) do
    [
      price_display.symbol,
      price_display.last_event_time,
      format_float(price_display.rsi),
      format_float(price_display.relative_price_change),
      price_display.nomber_of_event,
      format_float(price_display.last_price),
      format_float(price_display.last_total_price_change),
      format_float(price_display.last_relative_price_change),
      format_float(price_display.reg_slope),
      format_float(price_display.reg_intercept),
      price_display.trend || "unknown"
    ]
  end

  defimpl Inspect do
    def inspect(price_display, isColored) do
      # Simply delegate to to_display_string
      display_string = Models.PriceDisplay.to_display_string(price_display)

      if isColored do
        cond do
          is_nil(price_display.relative_price_change) ->
            # Yellow for unknown/nil values
            "\e[1;33m" <> display_string <> "\e[0m"

          price_display.relative_price_change < 0 ->
            # Red for negative
            "\e[1;31m" <> display_string <> "\e[0m"

          true ->
            # Green for positive
            "\e[1;32m" <> display_string <> "\e[0m"
        end
      else
        display_string
      end
    end
  end
end
