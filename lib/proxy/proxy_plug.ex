defmodule Proxy.ProxyPlug do
  use Plug.Builder

  @port Application.get_env :proxy, :port

  plug Plug.Logger
  plug Proxy.BlockPlug
  plug Proxy.CachePlug
  plug Proxy.HttpsProxyPlug
  plug Proxy.HttpProxyPlug

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http __MODULE__, [], port: @port
  end
end
