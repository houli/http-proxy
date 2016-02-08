defmodule Proxy do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Proxy.Worker, [arg1, arg2, arg3]),
      worker(__MODULE__, [], function: :run)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Proxy.Supervisor]
    port = Application.get_env(:proxy, :port)
    IO.puts "Proxy server running on http://localhost:#{port}"
    Supervisor.start_link(children, opts)
  end

  def run do
    {:ok, _} = Plug.Adapters.Cowboy.http Proxy.Router, [], port: Application.get_env(:proxy, :port)
  end
end
