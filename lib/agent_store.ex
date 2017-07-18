defmodule Slingbag do
@moduledoc """
Soroban.Slingbag module
Global temporary value storage
"""

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add_filename(filename) do
    Agent.update(__MODULE__,
                 fn list ->
                   [filename|list]
                 end)
  end

  def filenames do
    Agent.get(__MODULE__, fn list -> list end)
  end

  def empty do
    Agent.update(__MODULE__,
                 fn list ->
                   []
                 end)
  end

end
