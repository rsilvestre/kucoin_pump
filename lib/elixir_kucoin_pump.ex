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
  def hello do
    :world
  end

  def test do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get "https://api-futures.kucoin.com/api/v1/contracts/active"
    body |> Poison.decode! |> Map.get("data") |> Enum.map(fn x -> x["symbol"] end)
  end

  def start() do
    {:ok, server} = get_token()
    {:ok, pid} = EchoClient.start_link(server)

    {:ok, pid}
  end

  def get_token do
    options = [] #[ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.post("https://api.kucoin.com/api/v1/bullet-public", [], options)
    data = body |> Poison.decode! |> Map.get("data") #|> Map.get("token")
    {:ok, {data |> Map.get("instanceServers") |> Enum.at(0) |> Map.get("endpoint"), data |> Map.get("token"), DateTime.to_unix(DateTime.utc_now(), :millisecond)}}
  end
end
