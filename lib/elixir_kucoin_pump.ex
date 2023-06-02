defmodule ElixirKucoinPump do
  @moduledoc """
  Documentation for `ElixirKucoinPump`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ElixirKucoinPump.hello()
      :world

  """

  use TypeCheck

  def hello do
    :world
  end

  @spec! get_futures() :: MapSet.t()
  def get_futures do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get "https://api-futures.kucoin.com/api/v1/contracts/active"
    body |> Poison.decode! |> Map.get("data") |> Enum.map(fn x -> x["symbol"] end) |> Enum.map(&String.slice(&1, 0..-2)) |> MapSet.new()
  end

  def start() do
    #{:ok, server} = get_token()
    {:ok, _pid} = EchoClient.start_link()
    {:ok, _pid} = Helpers.Scheduler.start_link()

    :ok
  end

  def get_token do
    options = [] #[ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.post("https://api.kucoin.com/api/v1/bullet-public", [], options)
    data = body |> Poison.decode! |> Map.get("data") #|> Map.get("token")
    {:ok, {
      data |> Map.get("instanceServers") |> Enum.at(0) |> Map.get("endpoint"),
      data |> Map.get("token"),
      DateTime.to_unix(DateTime.utc_now(), :millisecond)
    }}
  end
end
