defmodule Soroban.BatchCommander do
  @moduledoc """
  Drab commander module
  """
  use Drab.Commander

  import Ecto.Query
  alias Soroban.{Repo, Client, InvoiceUtils}

  def invoice(socket, params) do
    %{"invoice" => %{"date" => _, "end" => _, "start" => _, "number" => number}} =  params.params

    if number == "" do
      poke socket, text: "Enter an Invoice Number"
    else
      clients = Repo.all from c in Client, select: c.id
      Task.async(InvoiceUtils, :batch_job, [socket, clients, params.params])
    end
  end

  def textrepl(socket, _params) do
    poke socket, text: "sup"
  end

end
