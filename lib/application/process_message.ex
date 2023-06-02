defmodule Application.ProcessMessage do
  alias Models.{PriceChange, PriceGroup, Message}

  use TypeCheck

  # Select nothing for all, only selected currency will be shown
  @show_only_pair Application.compile_env(:kucoin_pump, :show_only_pair)
  # minimum top query limit
  @show_limit Application.compile_env(:kucoin_pump, :show_limit)
  # min percentage change
  @min_perc Application.compile_env(:kucoin_pump, :min_perc)
  # @chat_ids ['-510655586']

  def start_link_price_changes() do
    GenServer.start_link(Storage.MapStorage, %{}, name: PriceChanges)
  end

  def start_link_price_groups() do
    GenServer.start_link(Storage.MapStorage, %{}, name: PriceGroups)
  end

  @spec! process_message(Message.t()) :: :ok
  def process_message(%Message{
        subject: symbol,
        time: event_time,
        size: total_trades,
        price: price
      }) do
    if String.contains?(symbol, @show_only_pair) do
      :ok = handle_message(symbol, event_time, total_trades, price)
    end

    :ok
  end

  @spec! handle_message(String.t(), DateTime.t(), integer(), float()) :: :ok
  defp handle_message(symbol, event_time, total_trades, price) do
    # IO.puts("Symbol: #{symbol}\t Time: #{time}\t Size: #{size}\t Price: #{price}")
    if GenServer.call(PriceChanges, {:has_key, symbol}) do
      %PriceChange{prev_price: prev_price} = GenServer.call(PriceChanges, {:get_item, symbol})

      price_change = %PriceChange{
        symbol: symbol,
        prev_price: prev_price,
        price: price,
        total_trades: total_trades,
        isPrinted: false,
        event_time: event_time
      }

      GenServer.cast(PriceChanges, {:set_item, symbol, price_change})
    else
      price_change = %PriceChange{
        symbol: symbol,
        prev_price: price,
        price: price,
        total_trades: total_trades,
        isPrinted: false,
        event_time: event_time
      }

      GenServer.cast(PriceChanges, {:set_item, symbol, price_change})
    end

    :ok
  end

  def compute_price_changes() do
    for {symbol, price_change} <- GenServer.call(PriceChanges, :all) do
      price_change_perc = PriceChange.get_price_change_perc(price_change)

      if not price_change.isPrinted and abs(price_change_perc) >= @min_perc do
        price_change = %PriceChange{price_change | isPrinted: true}

        if GenServer.call(PriceGroups, {:has_key, symbol}) do
          %PriceGroup{
            tick_count: tick_count,
            total_price_change: total_price_change,
            relative_price_change: relative_price_change
          } = GenServer.call(PriceGroups, {:get_item, symbol})

          price_group = %PriceGroup{
            symbol: symbol,
            tick_count: tick_count + 1,
            total_price_change: total_price_change + abs(price_change_perc),
            relative_price_change: relative_price_change + price_change_perc,
            last_price: price_change.price,
            last_event_time: price_change.event_time,
            isPrinted: false
          }

          GenServer.cast(PriceGroups, {:set_item, symbol, price_group})
        else
          price_group = %PriceGroup{
            symbol: symbol,
            tick_count: 1,
            total_price_change: abs(price_change_perc),
            relative_price_change: price_change_perc,
            last_price: price_change.price,
            last_event_time: price_change.event_time,
            isPrinted: false
          }

          GenServer.cast(PriceGroups, {:set_item, symbol, price_group})
        end
      end

      price_change = %PriceChange{price_change | prev_price: price_change.price}
      GenServer.cast(PriceChanges, {:set_item, symbol, price_change})
    end

    if GenServer.call(PriceGroups, :length) > 0 do
      # sorted_price_groups = Enum.sort_by(GenServer.call(PriceGroups, :all), &PriceGroup.get_relative_price_change(&1))
      price_groups = GenServer.call(PriceGroups, :all)
      list_price_groups = Enum.map(price_groups, fn {_key, value} -> value end)

      sorted_price_groups =
        Enum.sort_by(list_price_groups, & &1.total_price_change) |> Enum.reverse()

      any_printed = print_result(sorted_price_groups, "Top ticks:")

      any_printed =
        if not any_printed do
          sorted_price_groups =
            Enum.sort_by(list_price_groups, & &1.total_price_change) |> Enum.reverse()

          print_result(sorted_price_groups, "Top Total Price Change")
        else
          any_printed
        end

      any_printed =
        if not any_printed do
          sorted_price_groups =
            Enum.sort_by(list_price_groups, & &1.relative_price_change) |> Enum.reverse()

          print_result(sorted_price_groups, "Top Relative Price Change")
        else
          any_printed
        end

      if any_printed do
        IO.puts("\n")
      end
    end

    :ok
  end

  @spec! print_result(list(), String.t()) :: boolean()
  def print_result(sorted_price_groups, msg) do
    any_printed =
      print_result_recursive(
        Enum.to_list(0..(@show_limit - 1)),
        sorted_price_groups,
        msg,
        false,
        false
      )

    any_printed
  end

  @spec! print_result_recursive(list(), list(), String.t(), boolean(), boolean()) :: boolean()
  def print_result_recursive([head | tail], sorted_price_groups, msg, any_printed, header_printed) do
    {any_printed, header_printed} =
      if head < length(sorted_price_groups) do
        max_price_group = Enum.at(sorted_price_groups, head)

        {any_printed, header_printed} =
          if not max_price_group.isPrinted do
            header_printed =
              if not header_printed do
                IO.puts(msg)
                header_printed = true
                header_printed
              else
                header_printed
              end

            IO.inspect(max_price_group)
            max_price_group = %PriceGroup{max_price_group | isPrinted: true}
            GenServer.cast(PriceGroups, {:set_item, max_price_group.symbol, max_price_group})
            any_printed = true

            {any_printed, header_printed}
          else
            {any_printed, header_printed}
          end

        {any_printed, header_printed}
      else
        {any_printed, header_printed}
      end

    print_result_recursive(tail, sorted_price_groups, msg, any_printed, header_printed)
  end

  @spec! print_result_recursive(list(), list(), String.t(), boolean(), boolean()) :: boolean()
  def print_result_recursive([], _sorted_price_groups, _msg, any_printed, _header_printed) do
    any_printed
  end
end