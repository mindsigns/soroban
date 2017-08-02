defmodule Slingbag do
@moduledoc """
Soroban.Slingbag module
Global temporary value storage
"""

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add(item) do
    Agent.update(__MODULE__,
                 fn list ->
                   [item|list]
                 end)
  end

  def show do
    Agent.get(__MODULE__, fn list -> list end)
  end

  def empty do
    Agent.update(__MODULE__,
                 fn list ->
                   []
                 end)
  end

end
