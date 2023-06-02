defmodule SD do
  import Enum, only: [sum: 1]
  import :math, only: [sqrt: 1, pow: 2]

  def standard_deviation(data) do
    m = mean(data)
    data |> variance(m) |> mean |> sqrt
  end

  def mean(data) do
    sum(data) / length(data)
  end

  def variance(data, mean) do
    for n <- data, do: pow(n - mean, 2)
  end
end
