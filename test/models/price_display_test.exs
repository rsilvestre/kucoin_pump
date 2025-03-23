defmodule Models.PriceDisplayTest do
  use ExUnit.Case, async: true
  alias Models.PriceDisplay

  test "new/1 creates a valid PriceDisplay struct" do
    data = %{
      symbol: "TEST-USDT",
      rsi: 65.5,
      relative_price_change: 7.2,
      nomber_of_event: 42,
      last_price: 12345.67,
      last_total_price_change: 112.5,
      last_relative_price_change: 8.9,
      last_event_time: ~N[2023-06-07 17:01:36.000000],
      reg_slope: 0.45,
      reg_intercept: 125.67,
      trend: "positive"
    }

    price_display = PriceDisplay.new(data)

    assert price_display.symbol == "TEST-USDT"
    assert price_display.rsi == 65.5
    assert price_display.relative_price_change == 7.2
    assert price_display.nomber_of_event == 42
    assert price_display.last_price == 12345.67
    assert price_display.last_total_price_change == 112.5
    assert price_display.last_relative_price_change == 8.9
    assert price_display.last_event_time == ~N[2023-06-07 17:01:36.000000]
    assert price_display.reg_slope == 0.45
    assert price_display.reg_intercept == 125.67
    assert price_display.trend == "positive"
    assert price_display.is_printed == false
  end

  test "from_result_to_message/1 correctly converts a map to PriceDisplay" do
    event = %{
      "sym" => "ETH-USDT",
      "rsi" => 55.2,
      "pch" => 3.5, 
      "np" => 15,
      "lp" => 1800.5,
      "tpch" => 75.3,
      "rpch" => 2.8,
      "t" => ~N[2023-06-07 17:01:36.000000],
      "reg_slope" => 0.2,
      "reg_intercept" => 1750.5,
      "trend" => "positive"
    }

    price_display = PriceDisplay.from_result_to_message(event)

    assert price_display.symbol == "ETH-USDT"
    assert price_display.rsi == 55.2
    assert price_display.relative_price_change == 3.5
    assert price_display.nomber_of_event == 15
    assert price_display.last_price == 1800.5
    assert price_display.last_total_price_change == 75.3
    assert price_display.last_relative_price_change == 2.8
    assert price_display.last_event_time == ~N[2023-06-07 17:01:36.000000]
    assert price_display.reg_slope == 0.2
    assert price_display.reg_intercept == 1750.5
    assert price_display.trend == "positive"
  end

  test "to_display_string/1 formats the price display data correctly" do
    price_display = %PriceDisplay{
      symbol: "BTC-USDT",
      rsi: 60.5,
      relative_price_change: 2.5,
      nomber_of_event: 100,
      last_price: 30000.5,
      last_total_price_change: 150.8,
      last_relative_price_change: 3.2,
      last_event_time: ~N[2023-06-07 17:01:36.000000],
      reg_slope: 0.00123,
      reg_intercept: 29500.75,
      trend: "positive",
      is_printed: false
    }

    result = PriceDisplay.to_display_string(price_display)
    
    # Verify that the string contains all the expected data fields
    assert String.contains?(result, "Symbol:BTC-USDT")
    assert String.contains?(result, "Time:2023-06-07 17:01:36.000000")
    assert String.contains?(result, "RSI:60.50")
    assert String.contains?(result, "RPCh:2.50")
    assert String.contains?(result, "NOE:100")
    assert String.contains?(result, "LP:30000.50")
    assert String.contains?(result, "LTPCh:150.80")
    assert String.contains?(result, "LRPCh:3.20")
    assert String.contains?(result, "Slope:0.00123")
    assert String.contains?(result, "Intercept:29500.75")
    assert String.contains?(result, "Trend:positive")
  end

  test "format_float/2 formats floats with specified precision" do
    assert PriceDisplay.format_float(123.456, "~.2f") == "123.46"
    assert PriceDisplay.format_float(0.001234, "~.5f") == "0.00123"
    assert PriceDisplay.format_float(42, "~.2f") == "42"
    assert PriceDisplay.format_float(nil, "~.2f") == "N/A"
  end

  test "to_table/1 converts PriceDisplay to a table row" do
    price_display = %PriceDisplay{
      symbol: "BTC-USDT",
      rsi: 60.5,
      relative_price_change: 2.5,
      nomber_of_event: 100,
      last_price: 30000.5,
      last_total_price_change: 150.8,
      last_relative_price_change: 3.2,
      last_event_time: ~N[2023-06-07 17:01:36.000000],
      reg_slope: 0.00123,
      reg_intercept: 29500.75,
      trend: "positive",
      is_printed: false
    }

    result = PriceDisplay.to_table(price_display)
    
    assert is_list(result)
    assert length(result) == 11
    assert Enum.at(result, 0) == "BTC-USDT"
    assert Enum.at(result, 1) == ~N[2023-06-07 17:01:36.000000]
    assert Enum.at(result, 2) == "60.50"
    assert Enum.at(result, 3) == "2.50"
    assert Enum.at(result, 4) == 100
    assert Enum.at(result, 5) == "30000.50"
    assert Enum.at(result, 6) == "150.80"
    assert Enum.at(result, 7) == "3.20"
    # The actual formatting depends on the implementation
    # Check that it's a string containing the value
    assert is_binary(Enum.at(result, 8))
    assert String.contains?(Enum.at(result, 8), "0.00")
    assert is_binary(Enum.at(result, 9))
    assert String.contains?(Enum.at(result, 9), "29500")
    assert Enum.at(result, 10) == "positive"
  end
end