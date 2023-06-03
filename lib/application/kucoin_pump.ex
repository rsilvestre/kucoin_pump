defmodule Application.KucoinPump do
  @moduledoc """
  Documentation for `KucoinPump`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> KucoinPump.hello()
      :world

  """

  use TypeCheck

  @futures_api_base_url Application.compile_env(:kucoin_pump, :futures_api_base_url)

  @spec! get_futures() :: MapSet.t()
  def get_futures do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} =
      HTTPoison.get("#{@futures_api_base_url}/api/v1/contracts/active")

    body
    |> Jason.decode!()
    |> Map.get("data")
    |> Enum.map(fn x -> x["symbol"] end)
    |> Enum.map(&String.slice(&1, 0..-2))
    |> MapSet.new()
  end
end
