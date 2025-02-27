defmodule Application.EchoClient do
  alias Models.Message
  alias Application.ProcessMessage

  use TypeCheck
  use WebSockex
  require Logger

  @api_base_url Application.compile_env(:kucoin_pump, :api_base_url)

  # @echo_server "wss://echo.websocket.org/?encoding=text"
  def start_link(product \\ "all", opts \\ []) do
    # socket_opts = [
    #  ssl_options: [
    #    ciphers: :ssl.cipher_suites(:all, :"tlsv1.3")
    #  ]
    # ]

    socket_opts = []

    opts = Keyword.merge(opts, socket_opts)
    # WebSockex.start_link(@echo_server, __MODULE__, %{}, opts)
    {:ok, {endpoint, token, now}} = get_token()
    url = "#{endpoint}?token=#{token}&connectId=#{now}"
    # {:ok, pid} = WebSockex.start_link(url, __MODULE__, %{}, opts)
    {:ok, pid} =
      WebSockex.start_link(
        url,
        __MODULE__,
        %{most_recent_pong: System.system_time(:second)},
        opts
      )

    :timer.send_interval(15_000, pid, :send_ping)
    subscribe(pid, product)

    {:ok, pid}
  end

  @impl WebSockex
  def handle_connect(_conn, state) do
    Logger.info("Connected to Echo server")

    # params = {:text, %{type: "subscribe", topic: "/market/ticker:all", response: true} |> Jason.encode! |> String.to_charlist}
    # Logger.info("Sending #{inspect params}")
    # WebSockex.Conn.socket_send(conn, params)
    {:ok, state}
  end

  def subscribtion_frame(product \\ "all") do
    subscription_msg =
      %{
        type: "subscribe",
        topic: "/market/ticker:#{product}",
        response: true
      }
      |> Jason.encode!()

    {:text, subscription_msg}
  end

  def subscribe(pid, product \\ "all") do
    WebSockex.send_frame(pid, subscribtion_frame(product))
  end

  @impl WebSockex
  def handle_ping(:ping, state) do
    Logger.info("Ping received")
    {:ok, state}
  end

  @impl true
  def handle_info(:send_ping, state) do
    age = System.system_time(:second) - state.most_recent_pong

    if age > 20 do
      Logger.warning("No PONG for over 30 seconds. Restarting Websocket process.")
      {:close, state}
    else
      {:reply, :ping, state}
    end
  end

  @impl WebSockex
  def handle_pong(:pong, state) do
    # Logger.info("Pong received")
    {:ok, %{state | most_recent_pong: System.system_time(:second)}}
  end

  @impl WebSockex
  def handle_cast({:send, {type, msg} = frame}, state) do
    Logger.info("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  @impl WebSockex
  def handle_frame({:text, %{id: _id, type: "welcome"} = msg}, state) do
    Logger.info("Toto server says, #{inspect(msg)}")
    {:ok, state}
  end

  def handle_frame({:text, "shut down"}, state) do
    Logger.info("shutting down...")
    {:close, state}
  end

  def handle_frame({:text, msg}, state) do
    handle_msg(Jason.decode!(msg), state)
  end

  def handle_msg(%{"type" => "message"} = body, state) do
    try do
      # Logger.info("Echo server says, #{inspect Types.type_of(body)}")
      # Logger.info("Echo server says, #{inspect(body)}")
      if MapSet.member?(
           Storage.SimpleCache.get(Application.KucoinPump, :get_futures, []),
           String.replace(Map.get(body, "subject"), "-", "")
         ) do
        # Logger.info("In set: #{inspect Map.get(body, "subject")}")
        body
        |> Message.from_json_to_message()
        |> ProcessMessage.process_message()

        # |> Logger.info()
        # else
        # Logger.info("Not in set: #{inspect Map.get(body, "subject")}")
      end
    rescue
      e ->
        Logger.error("Error parsing message: #{inspect(body)}")
        Logger.error("Error: #{inspect(e)}")
        exit(:normal)
    end

    # Logger.info("Echo server says, #{msg}")
    {:ok, state}
  end

  def handle_msg(msg, state) do
    Logger.info("Echo server says, #{inspect(msg)}")
    {:ok, state}
  end

  @impl WebSockex
  def handle_disconnect(%{reason: reason}, state) do
    Logger.info("Disconnect with reason: #{inspect(reason)}")
    {:ok, state}
  end

  @impl WebSockex
  def terminate(reason, state) do
    IO.puts("\nSocket Terminating:\n#{inspect(reason)}\n\n#{inspect(state)}\n")
    exit(:normal)
  end

  @spec get_token() :: {:ok, {String.t(), String.t(), integer}}
  defp get_token do
    # options = [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 500]
    options = []

    {
      :ok,
      %HTTPoison.Response{status_code: 200, body: body}
    } = HTTPoison.post("#{@api_base_url}/api/v1/bullet-public", [], options)

    # |> Map.get("token")
    data = body |> Jason.decode!() |> Map.get("data")

    {
      :ok,
      {
        data |> Map.get("instanceServers") |> Enum.at(0) |> Map.get("endpoint"),
        data |> Map.get("token"),
        DateTime.to_unix(DateTime.utc_now(), :millisecond)
      }
    }
  end
end
