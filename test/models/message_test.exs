defmodule MessageTest do
  use ExUnit.Case, async: true
  doctest Models.Message

  test "From JSON to %Message{}" do
    message =
      Models.Message.from_json_to_message(%{
        "data" => %{
          "bestAsk" => "0.1731",
          "bestAskSize" => "200",
          "bestBid" => "0.1729",
          "bestBidSize" => "600",
          "price" => "0.1227",
          "sequence" => "64476933",
          "size" => "2.474",
          "time" => 1_685_653_861_363
        },
        "subject" => "FRONT-USDT",
        "topic" => "/market/ticker:all",
        "type" => "message"
      })

    assert message == %Models.Message{
             subject: "FRONT-USDT",
             time: ~U[2023-06-01 21:11:01.363Z],
             size: 2,
             price: 0.1227
           }
  end
end
