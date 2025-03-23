defmodule Helpers.SDTest do
  use ExUnit.Case, async: true
  alias Helpers.SD

  test "standard_deviation returns 0 for empty list" do
    assert SD.standard_deviation([]) == 0.0
  end

  test "standard_deviation returns 0 for single element list" do
    assert SD.standard_deviation([5]) == 0.0
  end

  test "standard_deviation calculates correctly for sample data" do
    data = [2, 4, 4, 4, 5, 5, 7, 9]
    # Expected standard deviation ≈ 2.0
    result = SD.standard_deviation(data)
    assert_in_delta result, 2.0, 0.001
  end

  test "standard_deviation calculates correctly for negative values" do
    data = [-5, -3, -1, 1, 3, 5]
    # Expected standard deviation ≈ 3.42
    result = SD.standard_deviation(data)
    assert_in_delta result, 3.42, 0.01
  end

  test "mean calculates average correctly" do
    assert SD.mean([1, 2, 3, 4, 5]) == 3.0
    assert SD.mean([0, 100]) == 50.0
    assert SD.mean([-10, 10]) == 0.0
  end

  test "mean returns 0 for empty list" do
    assert SD.mean([]) == 0.0
  end

  test "variance calculates squared differences from mean" do
    data = [1, 2, 3, 4, 5]
    mean = 3.0
    result = SD.variance(data, mean)
    
    expected = [4.0, 1.0, 0.0, 1.0, 4.0]
    
    Enum.zip(result, expected)
    |> Enum.each(fn {actual, expected} ->
      assert_in_delta actual, expected, 0.001
    end)
  end

  test "population_variance calculates variance correctly" do
    data = [1, 2, 3, 4, 5]
    # Expected variance = 2.0
    result = SD.population_variance(data)
    assert_in_delta result, 2.0, 0.001
  end

  test "population_variance handles zero and single element cases" do
    assert SD.population_variance([]) == 0.0
    assert SD.population_variance([42]) == 0.0
  end
end