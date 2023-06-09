defmodule Application.KucoinPumpTest do
  use ExUnit.Case
  doctest Application.KucoinPump

  # test "greets the world" do
  #  assert KucoinPump.hello() == :world
  # end

  test "get_futures" do
    result = Application.KucoinPump.get_futures()
    assert is_map(result)
  end
end
