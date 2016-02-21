defmodule Proxy.CachePlug do
  import Plug.Conn
  alias Proxy.{Cache, Utils}
  require Logger

  def init(opts), do: opts

  def call(%Plug.Conn{method: "GET"} = conn, _opts) do
    url = Utils.build_url(conn)
    case Cache.lookup(Utils.build_url(conn)) do
      {:ok, resp} ->
        Logger.info("HIT #{url}")
        %{conn | resp_headers: resp.headers}
        |> send_resp(resp.status_code, resp.body)
        |> halt
      :error ->
        Logger.info("MISS #{url}")
        conn
    end
  end
  def call(conn, _opts), do: conn

end
