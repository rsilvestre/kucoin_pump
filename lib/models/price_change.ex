defmodule Models.PriceChange do
  @moduledoc """
  Defines a struct for tracking price changes in trading symbols over time.
  Includes functions to calculate percentage changes and identify pumps/dumps.
  """
  use TypeCheck

  @enforce_keys [:symbol, :prev_price, :price, :total_trades, :is_printed, :event_time]
  defstruct [:symbol, :prev_price, :price, :total_trades, :is_printed, :event_time]

  @type! t() :: %__MODULE__{
           symbol: String.t(),
           prev_price: float(),
           price: float(),
           total_trades: integer(),
           is_printed: boolean(),
           event_time: DateTime.t()
         }

  @spec! get_price_change_perc(%__MODULE__{}) :: float()
  def get_price_change_perc(%__MODULE__{price: price, prev_price: prev_price}) do
    case {price, prev_price} do
      {price, prev_price} when price != 0 and prev_price != 0.0 ->
        # Add a small epsilon to prevent division by very small numbers
        epsilon = 0.000001
        abs_prev_price = abs(prev_price)

        calculate_percentage(price, prev_price, abs_prev_price, epsilon)

      _ ->
        0.0
    end
  end

  @spec! calculate_percentage(float(), float(), float(), float()) :: float()
  defp calculate_percentage(price, prev_price, abs_prev_price, epsilon)
       when abs_prev_price < epsilon do
    # If previous price is extremely small, use sign to determine direction
    # but cap the percentage to avoid unrealistic values
    if price > prev_price, do: 100.0, else: -100.0
  end

  defp calculate_percentage(price, prev_price, _abs_prev_price, _epsilon) do
    (price - prev_price) / prev_price * 100
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
            is_printed: is_printed,
            event_time: event_time
          },
          _
        ) do
      "Symbol:#{symbol}\t Time:#{event_time}\t PP:#{prev_price}\t P:#{price}\t TP:#{total_trades} is_printed:#{is_printed}\t"
    end
  end
end
