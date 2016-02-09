defmodule Proxy.Router do
  use Plug.Router
  require Logger

  plug Plug.Logger
  plug :match
  plug :dispatch

  defp build_body(conn, passed_body) do
    case read_body(conn) do
      {:ok, body, _} ->
        passed_body <> body
      {:more, body, conn} ->
        build_body conn, passed_body <> body
    end
  end

  defp build_url(conn) do
    conn.host <> conn.request_path
  end

  defp parse_connect(conn) do
    [host, port] = String.split(conn.request_path, ":")
    {host, String.to_integer(port)}
  end

  defp ssl_stream(sock1, sock2) do
    sock1 |> Socket.Stream.send!(Socket.Stream.recv!(sock2))
    ssl_stream(sock1, sock2)
  end

  match _ do
    url = build_url conn

    case method = String.to_atom(conn.method) do
      :CONNECT ->
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
      _ ->
        body = build_body conn, ""
        {:ok, resp} = HTTPoison.request method, url, body, conn.req_headers

        headers = List.keydelete resp.headers, "Transfer-Encoding", 0

        %{conn | resp_headers: headers}
        |> send_resp(resp.status_code, resp.body)
    end
  end
end
