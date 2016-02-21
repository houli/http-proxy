defmodule Proxy.Mixfile do
  use Mix.Project

  def project do
    [app: :proxy,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger,
                    :cowboy,
                    :plug,
                    :httpoison,
                    :socket,
                    :timex,
                    :observer,
                    :wx,
                    :runtime_tools],
     mod: {Proxy, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:cowboy, "~> 1.0.0"},
     {:plug, "~> 1.0"},
     {:exrm, "~> 0.19.0"},
     {:httpoison, "~> 0.8.0"},
     {:socket, github: "bitwalker/elixir-socket"},
     {:timex, "~> 1.0.0"}]
  end
end
