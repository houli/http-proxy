defmodule Proxy.BlockPlug do
  import Plug.Conn
  import Proxy.BlockList
  require Logger

  def init(opts), do: opts

  def call(conn = %Plug.Conn{host: host}, _opts) do
    if host |> is_blocked? do
      Logger.info "Blocking access to host #{host}"
      conn |> send_resp(403, "Host blocked by proxy server") |> halt
    else
      conn
    end
  end
end
