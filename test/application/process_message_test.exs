defmodule Application.ProcessMessageTest do
  use ExUnit.Case
  doctest Application.ProcessMessage

  test "extract message from query result" do
    result = %Postgrex.Result{
      command: :select,
      columns: ["sym", "rsi", "pch", "np", "lp", "tpch", "rpch", "t"],
      rows: [
        ["BOB-USDT", 58.91472868217049, 1.0757717492984233, 22, 2.161e-5,
         1535.6734993555503, -54.02952679094189, ~N[2023-06-07 17:01:57.000000]],
        ["STORJ-USDT", 51.288056206088996, 0.34515218073422965, 26, 0.3198,
         185.73015262602357, 14.333039747077144, ~N[2023-06-07 17:02:00.000000]],
        ["ICP-USDT", 42.857142857142854, -0.23866348448686844, 7, 4.18,
         211.7736339222215, -0.9358530826792144, ~N[2023-06-07 17:02:00.000000]],
        ["MTL-USDT", 38.70967741935481, -1.3165814023472817, 18, 1.3117,
         1414.2567808700487, -5.544317904243292, ~N[2023-06-07 17:01:58.000000]],
        ["KAS-USDT", 36.36363636363622, -0.20519835841313622, 4, 0.01459,
         397.11296777137335, 0.16654367009143417, ~N[2023-06-07 17:01:36.000000]]
      ],
      num_rows: 5,
      connection_id: 3602,
      messages: []
    }

    excpected = [
      %Models.PriceDisplay{
        last_event_time: ~N[2023-06-07 17:01:57.000000],
        last_price: 2.161e-5,
        last_relative_price_change: -54.02952679094189,
        last_total_price_change: 1535.6734993555503,
        nomber_of_event: 22,
        relative_price_change: 1.0757717492984233,
        rsi: 58.91472868217049,
        symbol: "BOB-USDT"
      },
      %Models.PriceDisplay{
        last_event_time: ~N[2023-06-07 17:02:00.000000],
        last_price: 0.3198,
        last_relative_price_change: 14.333039747077144,
        last_total_price_change: 185.73015262602357,
        nomber_of_event: 26,
        relative_price_change: 0.34515218073422965,
        rsi: 51.288056206088996,
        symbol: "STORJ-USDT"
      },
      %Models.PriceDisplay{
        last_event_time: ~N[2023-06-07 17:02:00.000000],
        last_price: 4.18,
        last_relative_price_change: -0.9358530826792144,
        last_total_price_change: 211.7736339222215,
        nomber_of_event: 7,
        relative_price_change: -0.23866348448686844,
        rsi: 42.857142857142854,
        symbol: "ICP-USDT"
      },
      %Models.PriceDisplay{
        last_event_time: ~N[2023-06-07 17:01:58.000000],
        last_price: 1.3117,
        last_relative_price_change: -5.544317904243292,
        last_total_price_change: 1414.2567808700487,
        nomber_of_event: 18,
        relative_price_change: -1.3165814023472817,
        rsi: 38.70967741935481,
        symbol: "MTL-USDT"
      },
      %Models.PriceDisplay{
        last_event_time: ~N[2023-06-07 17:01:36.000000],
        last_price: 0.01459,
        last_relative_price_change: 0.16654367009143417,
        last_total_price_change: 397.11296777137335,
        nomber_of_event: 4,
        relative_price_change: -0.20519835841313622,
        rsi: 36.36363636363622,
        symbol: "KAS-USDT"
      }
    ]

    assert Application.ProcessMessage.extract_message_from_query_result(result) == excpected
  end

  # test "greets the world" do
  #  assert KucoinPump.hello() == :world
  # end
end
