defmodule Proxy.Utils do
  import Plug.Conn

  def build_body(conn), do: build_body(conn, "")
  def build_body(conn, passed_body) do
    case read_body(conn) do
      {:ok, body, _} ->
        passed_body <> body
      {:more, body, conn} ->
        build_body conn, passed_body <> body
    end
  end

  def build_url(%Plug.Conn{host: host, request_path: path, query_string: qs}) do
    url = host <> path
    case qs do
      "" -> url
      _ -> url <> "?" <> qs
    end
  end

  def header_value(header, headers) do
    case Enum.find(headers, fn({key, _}) -> String.downcase(key) == header end) do
      nil -> nil
      header -> elem(header, 1)
    end
  end

end
