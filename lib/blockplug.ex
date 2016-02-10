defmodule Proxy.BlockPlug do
  import Plug.Conn
  import Proxy.Blocklist
  require Logger

  def init(options) do
    options
  end

  def call(conn = %Plug.Conn{host: host}, _opts) do
    if host |> is_blocked? do
      Logger.info "Blocking access to host #{host}"
      conn |> send_resp(403, "") |> halt
    else
      conn
    end
  end
end
