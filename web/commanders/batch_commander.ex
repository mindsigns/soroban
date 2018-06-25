defmodule Soroban.BatchCommander do
  @moduledoc """
  Drab commander module
  """
  use Drab.Commander

  import Ecto.Query
  alias Soroban.{Repo, Client, InvoiceUtils}

  defhandler invoice(socket, params) do
    number = socket |> Drab.Query.select(:val, from: "input[id=invoice_number]")

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

  # unused since Drab update
  def repack(params) do
    repacked = %{
				"invoice" => %{
        			"date" => %{"day" => Map.get(params, "invoice[date][day]"),
        						"month" => Map.get(params, "invoice[date][month]"),
        						"year" => Map.get(params, "invoice[date][year]")},
        			"end"  => %{"day" => Map.get(params, "invoice[end][day]"),
        						"month" => Map.get(params, "invoice[end][month]"),
        						"year" => Map.get(params, "invoice[end][year]")},
        			"number" => Map.get(params, "invoice[number]"),
        			"start" => %{"day" => Map.get(params, "invoice[start][day]"),
        						 "month" => Map.get(params, "invoice[start][month]"),
        						 "year" => Map.get(params, "invoice[start][year]")}
    }
  }
	repacked
  end
end
