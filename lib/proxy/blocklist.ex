defmodule Proxy.Blocklist do

  @name __MODULE__

  def start_link do
    Agent.start_link(fn -> MapSet.new end, name: @name)
  end

  def is_blocked?(host) do
    Agent.get(@name, &MapSet.member?(&1, host))
  end

  def block(host) do
    Agent.update(@name, &MapSet.put(&1, host))
  end

  def unblock(host) do
    Agent.update(@name, &MapSet.delete(&1, host))
  end

  def unblock_all do
    Agent.update(@name, fn _ -> MapSet.new end)
  end

  def get_all do
    Agent.get(@name, &MapSet.to_list(&1))
  end

  def size do
    Agent.get(@name, &MapSet.size(&1))
  end
end
