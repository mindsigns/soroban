defmodule Soroban.BatchCommander do
  @moduledoc """
  Drab commander module
  """
  use Drab.Commander

  import Ecto.Query
  alias Soroban.{Repo, Client, InvoiceUtils}

  def invoice(socket, params) do
    clients = Repo.all from c in Client, select: c.id
    Task.async(InvoiceUtils, :batch_job, [socket, clients, params.params])
  end

  def textrepl(socket, _params) do
    poke socket, text: "sup"
  end

end