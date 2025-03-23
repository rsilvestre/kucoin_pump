defmodule Helpers.SD do
  @moduledoc """
  Provides statistical functions for calculating standard deviation, mean, variance,
  and other statistical measures of numeric datasets.
  """
  use TypeCheck

  import Enum, only: [sum: 1, reduce: 3, count: 1]
  import :math, only: [sqrt: 1, pow: 2]

  @doc """
  Calculates standard deviation using a numerically stable one-pass algorithm.
  This implementation is based on Welford's online algorithm.
  """
  @spec! standard_deviation(data :: list) :: float
  def standard_deviation([]), do: 0.0
  def standard_deviation([_single]), do: 0.0

  def standard_deviation(data) do
    {n, _mean, m2} =
      data
      |> reduce({0, 0.0, 0.0}, fn x, {count, mean, m2} ->
        count = count + 1
        delta = x - mean
        new_mean = mean + delta / count
        delta2 = x - new_mean
        m2 = m2 + delta * delta2
        {count, new_mean, m2}
      end)

    if n < 2, do: 0.0, else: sqrt(m2 / n)
  end

  @doc """
  Calculates the mean of a list of numbers.
  Returns 0.0 for empty lists to avoid errors.
  """
  @spec! mean(data :: list) :: float
  def mean([]), do: 0.0

  def mean(data) do
    sum(data) / count(data)
  end

  @doc """
  Calculates the variance of a list of numbers.
  This is the traditional implementation, used for compatibility.
  """
  @spec! variance(data :: list, mean :: float) :: list
  def variance(data, mean) do
    for n <- data, do: pow(n - mean, 2)
  end

  @doc """
  Calculates the population variance as a single value.
  """
  @spec! population_variance(data :: list) :: float
  def population_variance([]), do: 0.0
  def population_variance([_single]), do: 0.0

  def population_variance(data) do
    m = mean(data)
    data |> variance(m) |> mean
  end
end
