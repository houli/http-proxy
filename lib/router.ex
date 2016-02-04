defmodule Proxy.Router do
  use Plug.Router

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

  match _ do
    body = build_body conn, ""
    url = build_url conn
    method = String.to_atom conn.method
    {:ok, resp} = HTTPoison.request method, url, body, conn.req_headers

    headers = List.keydelete resp.headers, "Transfer-Encoding", 0

    %{conn | resp_headers: headers}
    |> send_resp(resp.status_code, resp.body)
  end
end
