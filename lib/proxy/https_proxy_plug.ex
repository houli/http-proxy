defmodule Proxy.HttpsProxyPlug do
  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(%Plug.Conn{method: "CONNECT"} = conn, _opts) do
    conn
    |> establish_connection
    |> ssl_task_handle
    |> Map.put(:state, :sent)
    |> halt
  end
  def call(conn, _opts), do: conn

  defp parse_connect(conn) do
    [host, port] = String.split(conn.request_path, ":")
    {host, String.to_integer(port)}
  end

  defp establish_connection(conn) do
    # Open up the tunnel and send 200 back to the browser
    {host, port} = parse_connect conn
    Logger.info "Tunnel #{host}:#{port} opened"
    conn
    |> assign(:client_sock, conn.adapter |> elem(1) |> elem(1))
    |> assign(:host, host)
    |> assign(:port, port)
    |> assign(:remote_sock, Socket.TCP.connect!(host, port))
    |> send_chunked(200)
  end

  defp ssl_task_handle(conn) do
    client = conn.assigns.client_sock
    remote = conn.assigns.remote_sock
    # Stream encrypted data from client->remote and remote->client
    tasks = Task.yield_many([
      Task.async(fn -> ssl_stream(client, remote) end),
      Task.async(fn -> ssl_stream(remote, client) end)
    ])
    Enum.map(tasks, fn {task, _res} ->
      Task.shutdown(task, :brutal_kill)
    end)
    Logger.info "Tunnel #{conn.assigns.host}:#{conn.assigns.port} closed"
    conn
  end

  defp ssl_stream(sock1, sock2) do
    sock1 |> Socket.Stream.send!(Socket.Stream.recv!(sock2))
    ssl_stream(sock1, sock2)
  end

end
