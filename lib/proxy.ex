defmodule Proxy do
  use Application

  @port Application.get_env :proxy, :port
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Proxy.Worker, [arg1, arg2, arg3]),
      worker(Proxy.ProxyPlug, []),
      worker(Proxy.BlockList, []),
      worker(Proxy.Cache, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Proxy.Supervisor]
    IO.puts "Proxy server running on localhost:#{@port}"
    Supervisor.start_link(children, opts)
  end
end
