defmodule Helpers.SD do
  use TypeCheck

  import Enum, only: [sum: 1]
  import :math, only: [sqrt: 1, pow: 2]

  @spec! standard_deviation(data :: list) :: float
  def standard_deviation(data) do
    m = mean(data)
    data |> variance(m) |> mean |> sqrt
  end

  @spec! mean(data :: list) :: float
  def mean(data) do
    sum(data) / length(data)
  end

  @spec! variance(data :: list, mean :: float) :: list
  def variance(data, mean) do
    for n <- data, do: pow(n - mean, 2)
  end
end
