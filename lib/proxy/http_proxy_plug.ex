defmodule Proxy.HttpProxyPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    url = build_url conn
    body = build_body conn, ""
    method = String.to_atom(conn.method)
    {:ok, resp} = HTTPoison.request method, url, body, conn.req_headers

    headers = List.keydelete resp.headers, "Transfer-Encoding", 0

    %{conn | resp_headers: headers}
    |> send_resp(resp.status_code, resp.body)
  end

  defp build_body(conn, passed_body) do
    case read_body(conn) do
      {:ok, body, _} ->
        passed_body <> body
      {:more, body, conn} ->
        build_body conn, passed_body <> body
    end
  end

  defp build_url(%Plug.Conn{host: host, request_path: path, query_string: qs}) do
    url = host <> path
    case qs do
      "" -> url
      _ -> url <> "?" <> qs
    end
  end

end
