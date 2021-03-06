defmodule Proxy.Cache do
  use GenServer
  use Timex
  alias Proxy.Utils
  require Logger

  @name __MODULE__
  @default_cache_time Time.to_secs(10, :mins)

  def start_link do
    GenServer.start_link(@name, [], name: @name)
  end

  def init(_opts) do
    # Create a new ETS table to store the cached items
    {:ok, :ets.new(@name, [:named_table, read_concurrency: true])}
  end

  def insert(url, resp) do
    GenServer.call(@name, {:cache, url, resp})
  end

  def lookup(url) do
    # Lookup the cached entry
    case :ets.lookup(@name, url) do
      [{_, resp}] -> {:ok, resp}
      [] -> :error
    end
  end

  def handle_call({:cache, url, resp}, _from, cache) do
    cache_entry(url, resp, cache)
    {:reply, :ok, cache}
  end

  def handle_info({:expire, url}, cache) do
    Logger.info "Cache entry #{url} expired"
    :ets.delete(cache, url)
    {:noreply, cache}
  end
  def handle_info(_, cache), do: {:noreply, cache}

  defp cache_entry(url, resp, cache) do
    # If finished after cache_control do nothing otherwise use expires header
    cached = cache_control_handler(url, resp, cache)
    if !cached do
      expires_handler(url, resp, cache)
    end
  end

  defp cache_control_handler(url, resp, cache) do
    case Utils.header_value("cache-control", resp.headers) do
      nil -> false
      control ->
        if Regex.match?(~r/no-store/i, control) do
          Logger.info "Not caching #{url}. no-store header found"
          true
        else
          case Regex.run(~r/max-age=(\d+)/, control) do
            [_, seconds] ->
              cache_for(String.to_integer(seconds), url, resp, cache)
              true
            _ ->
              false
          end
        end
    end
  end

  defp expires_handler(url, resp, cache) do
    case Utils.header_value("expires", resp.headers) do
      nil ->
        # No caching headers found, cache for set amount of time
        cache_for(@default_cache_time, url, resp, cache)
      date ->
        # Expires header found, parse date and cache until expiry time
        (date
        |> DateFormat.parse("{RFC1123}")
        |> elem(1)
        |> Date.to_secs) - Date.now(:secs)
        |> cache_for(url, resp, cache)
    end
  end

  defp cache_for(seconds, url, resp, cache) do
    Logger.info "Caching #{url} for #{seconds} seconds"
    :ets.insert(cache, {url, resp})
    Process.send_after(self, {:expire, url}, seconds * 1000)
  end

end
