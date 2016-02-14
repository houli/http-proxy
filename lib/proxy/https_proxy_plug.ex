defmodule Proxy.HttpsProxyPlug do
  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(%Plug.Conn{method: "CONNECT"} = conn, _opts) do
    client_sock = conn.adapter |> elem(1) |> elem(1)
    {host, port} = parse_connect conn
    sock = Socket.TCP.connect! host, port
    Logger.info "Tunnel connection to #{host}:#{port} opened"
    client_sock |> Socket.Stream.send!("HTTP/1.1 200 Connection established\r\n\r\n")
    t1 = Task.async(fn -> ssl_stream(client_sock, sock) end)
    t2 = Task.async(fn -> ssl_stream(sock, client_sock) end)
    tasks = Task.yield_many([t1, t2])
    Enum.map(tasks, fn {task, _res} ->
      Task.shutdown(task, :brutal_kill)
    end)
    Logger.info "Tunnel connection to #{host}:#{port} closed"
    %{conn | state: :sent}
    |> halt
  end

  def call(conn, _opts), do: conn

  defp parse_connect(conn) do
    [host, port] = String.split(conn.request_path, ":")
    {host, String.to_integer(port)}
  end

  defp ssl_stream(sock1, sock2) do
    sock1 |> Socket.Stream.send!(Socket.Stream.recv!(sock2))
    ssl_stream(sock1, sock2)
  end

end
