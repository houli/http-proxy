defmodule Proxy.ProxyPlug do
  use Plug.Builder

  @port Application.get_env :proxy, :port

  # Main pipeline of the application
  # Request -> Logger -> Check if blocked ->
  # Check cache -> Handle HTTPS -> Handle HTTP
  # If host is not blocked, pass through, otherwise block and halt
  # If URL is not cached, pass through, otherwise serve with cache and halt
  # If connection is not HTTPS, pass through, otherwise tunnel encrypted data
  # If at the end of the pipeline we do a regular HTTP proxy and cache results
  plug Plug.Logger
  plug Proxy.BlockPlug
  plug Proxy.CachePlug
  plug Proxy.HttpsProxyPlug
  plug Proxy.HttpProxyPlug

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http __MODULE__, [], port: @port
  end
end
