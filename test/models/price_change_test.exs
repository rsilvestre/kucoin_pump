defmodule Models.PriceChangeTest do
  use ExUnit.Case, async: true
  alias Models.PriceChange

  test "get_price_change_perc calculates positive percentage change correctly" do
    price_change = %PriceChange{
      symbol: "TEST-USDT",
      prev_price: 100.0,
      price: 110.0,
      total_trades: 10,
      is_printed: false,
      event_time: DateTime.utc_now()
    }

    assert PriceChange.get_price_change_perc(price_change) == 10.0
  end

  test "get_price_change_perc calculates negative percentage change correctly" do
    price_change = %PriceChange{
      symbol: "TEST-USDT",
      prev_price: 100.0,
      price: 90.0,
      total_trades: 10,
      is_printed: false,
      event_time: DateTime.utc_now()
    }

    assert PriceChange.get_price_change_perc(price_change) == -10.0
  end

  test "get_price_change_perc handles zero previous price" do
    price_change = %PriceChange{
      symbol: "TEST-USDT",
      prev_price: 0.0,
      price: 10.0,
      total_trades: 10,
      is_printed: false,
      event_time: DateTime.utc_now()
    }

    assert PriceChange.get_price_change_perc(price_change) == 0.0
  end

  test "get_price_change_perc handles very small previous price (positive change)" do
    price_change = %PriceChange{
      symbol: "TEST-USDT",
      prev_price: 0.0000001,
      price: 0.0000002,
      total_trades: 10,
      is_printed: false,
      event_time: DateTime.utc_now()
    }

    assert PriceChange.get_price_change_perc(price_change) == 100.0
  end

  test "get_price_change_perc handles very small previous price (negative change)" do
    price_change = %PriceChange{
      symbol: "TEST-USDT",
      prev_price: 0.0000001,
      price: 0.00000005,
      total_trades: 10,
      is_printed: false,
      event_time: DateTime.utc_now()
    }

    assert PriceChange.get_price_change_perc(price_change) == -100.0
  end

  test "is_pump detects pump correctly" do
    price_change = %PriceChange{
      symbol: "TEST-USDT",
      prev_price: 100.0,
      price: 110.0,
      total_trades: 10,
      is_printed: false,
      event_time: DateTime.utc_now()
    }

    assert PriceChange.is_pump(price_change, 5.0) == true
    assert PriceChange.is_pump(price_change, 15.0) == false
  end

  test "is_dump detects dump correctly" do
    price_change = %PriceChange{
      symbol: "TEST-USDT",
      prev_price: 100.0,
      price: 85.0,
      total_trades: 10,
      is_printed: false,
      event_time: DateTime.utc_now()
    }

    assert PriceChange.is_dump(price_change, 10.0) == true
    assert PriceChange.is_dump(price_change, 20.0) == false
  end
end