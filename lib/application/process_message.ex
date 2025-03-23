defmodule Application.ProcessMessage do
  @moduledoc """
  Handles the processing of incoming market data messages.
  Manages price changes, computes statistics, and formats data for display.
  Provides functionality for detecting significant price movements and trends.
  """
  alias KucoinPump.Repo
  alias Ecto.Adapters.SQL
  alias Models.{Message, PriceChange, PriceDisplay, PriceGroup}

  use TypeCheck
  require Logger

  import Ecto.Query, only: [from: 2]

  # Select nothing for all, only selected currency will be shown
  @show_only_pair Application.compile_env(:kucoin_pump, :show_only_pair)
  # minimum top query limit
  @show_limit Application.compile_env(:kucoin_pump, :show_limit)
  # min percentage change
  @min_perc Application.compile_env(:kucoin_pump, :min_perc)
  @data_window_in_minutes Application.compile_env(:kucoin_pump, :data_window_in_minutes)
  
  # These values will be accessed at runtime instead of compile time
  defp telegram_chat_id, do: Application.get_env(:kucoin_pump, :telegram_chat_id)
  defp telegram_bot_token, do: Application.get_env(:kucoin_pump, :telegram_bot_token)
  defp telegram_enabled, do: Application.get_env(:kucoin_pump, :telegram_enabled, false)

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
        is_printed: false,
        event_time: event_time
      }

      GenServer.cast(PriceChanges, {:set_item, symbol, price_change})
    else
      price_change = %PriceChange{
        symbol: symbol,
        prev_price: price,
        price: price,
        total_trades: total_trades,
        is_printed: false,
        event_time: event_time
      }

      GenServer.cast(PriceChanges, {:set_item, symbol, price_change})
    end

    :ok
  end

  @spec! compute_price_changes() :: :ok
  def compute_price_changes() do
    for {symbol, price_change} <- GenServer.call(PriceChanges, :all) do
      price_change_perc = PriceChange.get_price_change_perc(price_change)

      # Handle significant price changes
      if should_process_price_change?(price_change, price_change_perc) do
        # Mark as printed
        price_change = %PriceChange{price_change | is_printed: true}

        # Get or create price group
        price_group = get_or_create_price_group(symbol, price_change, price_change_perc)

        # Store in database
        save_price_group(price_group)

        # Update in-memory cache
        GenServer.cast(PriceGroups, {:set_item, symbol, price_group})
      end

      # Always update the prev_price for next comparison
      update_price_change(symbol, price_change)
    end

    :ok
  end

  @spec! should_process_price_change?(PriceChange.t(), float()) :: boolean()
  defp should_process_price_change?(price_change, price_change_perc) do
    price_change.is_printed == false and abs(price_change_perc) >= @min_perc
  end

  @spec! get_or_create_price_group(String.t(), PriceChange.t(), float()) :: PriceGroup.t()
  defp get_or_create_price_group(symbol, price_change, price_change_perc) do
    if GenServer.call(PriceGroups, {:has_key, symbol}) do
      get_existing_price_group(symbol, price_change, price_change_perc)
    else
      create_new_price_group(symbol, price_change, price_change_perc)
    end
  end

  @spec! get_existing_price_group(String.t(), PriceChange.t(), float()) :: PriceGroup.t()
  defp get_existing_price_group(symbol, price_change, price_change_perc) do
    # Get existing price group from cache
    %PriceGroup{
      tick_count: tick_count,
      total_price_change: total_price_change,
      relative_price_change: relative_price_change
    } = GenServer.call(PriceGroups, {:get_item, symbol})

    # Update with new values
    %PriceGroup{
      symbol: symbol,
      tick_count: tick_count + 1,
      total_price_change: total_price_change + abs(price_change_perc),
      relative_price_change: relative_price_change + price_change_perc,
      last_price: price_change.price,
      last_event_time: price_change.event_time,
      is_printed: false
    }
  end

  @spec! create_new_price_group(String.t(), PriceChange.t(), float()) :: PriceGroup.t()
  defp create_new_price_group(symbol, price_change, price_change_perc) do
    # Query for existing data from database
    data_price_change = query_existing_price_group(symbol, price_change_perc)

    # Create new price group with fetched or default data
    %PriceGroup{
      symbol: symbol,
      tick_count: data_price_change.tick_count,
      total_price_change: data_price_change.total_price_change,
      relative_price_change: data_price_change.relative_price_change,
      last_price: price_change.price,
      last_event_time: price_change.event_time,
      is_printed: false
    }
  end

  @spec! query_existing_price_group(String.t(), float()) :: map()
  defp query_existing_price_group(symbol, price_change_perc) do
    query_result =
      Repo.one(
        from(p in KucoinPump.PriceGroup,
          select: %{
            tick_count: p.tick_count,
            relative_price_change: p.relative_price_change,
            total_price_change: p.total_price_change
          },
          where: p.symbol == ^symbol,
          order_by: [desc: p.last_event_time],
          limit: 1
        )
      )

    process_query_result(query_result, price_change_perc)
  end

  @spec! process_query_result(map() | nil, float()) :: map()
  defp process_query_result(nil, price_change_perc) do
    # No previous data found, create new entry
    %{
      tick_count: 1,
      relative_price_change: price_change_perc,
      total_price_change: abs(price_change_perc)
    }
  end

  defp process_query_result(
         %{
           tick_count: tick_count,
           relative_price_change: relative_price_change,
           total_price_change: total_price_change
         },
         price_change_perc
       ) do
    # Update existing data with new change
    %{
      tick_count: tick_count + 1,
      relative_price_change: relative_price_change + price_change_perc,
      total_price_change: total_price_change + abs(price_change_perc)
    }
  end

  @spec! save_price_group(PriceGroup.t()) :: String.t() | nil
  defp save_price_group(price_group) do
    case %KucoinPump.PriceGroup{}
         |> KucoinPump.PriceGroup.changeset(Map.from_struct(price_group))
         |> KucoinPump.Repo.insert() do
      {:ok, _} ->
        "Inserted"

      {:error, changeset} ->
        Logger.error("Error inserting price group: #{inspect(changeset.errors)}")
    end
  end

  @spec! update_price_change(String.t(), PriceChange.t()) :: :ok
  defp update_price_change(symbol, price_change) do
    price_change = %PriceChange{price_change | prev_price: price_change.price}
    GenServer.cast(PriceChanges, {:set_item, symbol, price_change})
  end

  @spec! extract_message_from_query_result(map()) :: list()
  def extract_message_from_query_result(result) do
    Enum.map(result.rows, fn [
                               sym,
                               rsi,
                               pch,
                               np,
                               lp,
                               tpch,
                               rpch,
                               t,
                               reg_slope,
                               reg_intercept,
                               trend
                             ] ->
      Models.PriceDisplay.from_result_to_message(%{
        "sym" => sym,
        "rsi" => rsi,
        "pch" => pch,
        "np" => np,
        "lp" => lp,
        "tpch" => tpch,
        "rpch" => rpch,
        "t" => t,
        "reg_slope" => reg_slope,
        "reg_intercept" => reg_intercept,
        "trend" => trend
      })
    end)
  end

  @spec! query_compute_price_diff(integer()) :: list()
  def query_compute_price_diff(time_interval_in_minutes) do
    SQL.query!(
      Repo,
      "select * from compute_price_diff(#{time_interval_in_minutes})"
    )
    |> extract_message_from_query_result
  end

  @spec! display_table_price_change() :: :ok
  def display_table_price_change() do
    Application.ProcessMessage.query_compute_price_diff(60)
    |> Enum.map(&Models.PriceDisplay.to_table(&1))
    |> Helpers.TableFormatter.print_table()

    :ok
  end

  @spec! display_price_changes() :: :ok
  def display_price_changes() do
    # sorted_price_groups = Enum.sort_by(GenServer.call(PriceGroups, :all), &PriceGroup.get_relative_price_change(&1))
    # price_groups = GenServer.call(PriceGroups, :all)
    # list_price_groups = Enum.map(price_groups, fn {_key, value} -> value end)

    # sorted_price_groups = Enum.sort_by(list_price_groups, & &1.tick_count) |> Enum.reverse()

    # any_printed = print_result(sorted_price_groups, "Top ticks:")

    compute_price_diff = query_compute_price_diff(@data_window_in_minutes)

    print_result(compute_price_diff, "Top:")

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
    # Skip processing if index is out of bounds
    if head >= length(sorted_price_groups) do
      print_result_recursive(tail, sorted_price_groups, msg, any_printed, header_printed)
    else
      # Get the price group at the current index
      max_price_group = Enum.at(sorted_price_groups, head)

      # Process only if not printed yet
      {new_any_printed, new_header_printed} =
        process_price_group(max_price_group, msg, any_printed, header_printed)

      # Continue with the next item
      print_result_recursive(tail, sorted_price_groups, msg, new_any_printed, new_header_printed)
    end
  end

  def print_result_recursive([], _sorted_price_groups, _msg, any_printed, _header_printed) do
    any_printed
  end

  @spec! process_price_group(map(), String.t(), boolean(), boolean()) :: {boolean(), boolean()}
  defp process_price_group(price_group, msg, any_printed, header_printed) do
    # Skip if already printed
    if price_group.is_printed do
      {any_printed, header_printed}
    else
      # Print header if needed
      updated_header_printed = maybe_print_header(msg, header_printed)

      # Log and send message
      Logger.debug("Processing price group: #{inspect(price_group)}")
      send_message("#{msg} #{PriceDisplay.to_display_string(price_group)}", price_group.symbol)

      # Mark as printed and return updated state
      {true, updated_header_printed}
    end
  end

  @spec! maybe_print_header(String.t(), boolean()) :: boolean()
  defp maybe_print_header(msg, false) do
    IO.puts(msg)
    true
  end

  defp maybe_print_header(_msg, true), do: true

  @spec! send_message(String.t(), String.t()) :: :ok
  def send_message(message, symbol) do
    if telegram_enabled() do
      case Telegram.Api.request(telegram_bot_token(), "sendMessage",
             chat_id: telegram_chat_id(),
             text: message,
             disable_notification: true,
             parse_mode: "markdown",
             reply_markup: %{
               inline_keyboard: [
                 [
                   %{
                     text: "📈",
                     url:
                       "https://www.tradingview.com/chart/?symbol=KUCOIN:#{String.replace(symbol, "-", "")}&interval=1440"
                   }
                 ]
               ]
             }
           ) do
        {:ok, _} -> :ok
        {:error, reason} -> Logger.error("Error sending Telegram message: #{inspect(reason)}")
      end
    else
      # Telegram notifications are disabled
      :ok
    end

    :ok
  end
end
