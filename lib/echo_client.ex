defmodule EchoClient do
  use WebSockex
  require Logger

  #@echo_server "wss://echo.websocket.org/?encoding=text"
  def start_link(server, product \\ "all", opts \\ []) do
    socket_opts = [
      ssl_options: [
        ciphers: :ssl.cipher_suites(:all, :"tlsv1.3")
      ]
    ]
    opts = Keyword.merge(opts, socket_opts)
    #WebSockex.start_link(@echo_server, __MODULE__, %{}, opts)
    {endpoint, token, now} = server
    {:ok, pid} = WebSockex.start_link("#{endpoint}?token=#{token}&connectId=#{now}", __MODULE__, %{}, opts)
    subscribe(pid, product)
    {:ok, pid}
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected to Echo server")
    #params = {:text, %{type: "subscribe", topic: "/market/ticker:all", response: true} |> Poison.encode! |> String.to_charlist}
    #Logger.info("Sending #{inspect params}")
    #WebSockex.Conn.socket_send(conn, params)
    {:ok, state}
  end

  def subscribtion_frame(product \\ "all") do

    subscription_msg = %{

      type: "subscribe",
      topic: "/market/ticker:#{product}",
      response: true,

    } |> Poison.encode!

      {:text, subscription_msg}
  end

  def subscribe(pid, product \\ "all") do
    WebSockex.send_frame pid, subscribtion_frame(product)
  end

  def handle_ping(_ping_frame, state) do
    Logger.info("Ping received")
    {:ok, state}
  end

  def handle_pong(_pong_frame, state) do
    Logger.info("Pong received")
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    Logger.info("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  def handle_frame({:text, %{id: _id, type: "welcome"} = msg}, state) do
    Logger.info("Toto server says, #{inspect msg}")
    {:ok, state}
  end

  def handle_frame({:text, "shut down"}, state) do
    Logger.info("shutting down...")
    {:close, state}
  end

  def handle_frame({:text, msg}, state) do
    handle_msg(Poison.decode!(msg), state)
  end

  def handle_msg(%{"type" => "message"} = body, state) do
    try do
      #Logger.info("Echo server says, #{inspect Types.type_of(body)}")
      #Logger.info("Echo server says, #{inspect(body)}")
      body
      |> Message.from_json_to_message()
      |> ProcessMessage.process_message()
      #|> Logger.info()
    rescue
      e ->
        Logger.error("Error parsing message: #{inspect body}")
        Logger.error("Error: #{inspect e}")
        exit(:normal)
    end

    #Logger.info("Echo server says, #{msg}")
    {:ok, state}
  end

  def handle_msg(msg, state) do
    Logger.info("Echo server says, #{inspect msg}")
    {:ok, state}
  end

  def handle_disconnect(%{reason: reason}, state) do
    Logger.info("Disconnect with reason: #{inspect reason}")
    {:ok, state}
  end

  def terminate(reason, state) do
    IO.puts("\nSocket Terminating:\n#{inspect reason}\n\n#{inspect state}\n")
    exit(:normal)
  end

end
