defmodule Soroban.BatchCommander do
  use Drab.Commander

  import Ecto.Query
  alias Soroban.{Repo, Client, InvoiceUtils}

  def invoice(socket, params) do
    IO.inspect params
    clients = Repo.all from c in Client, select: c.id
    Task.async(InvoiceUtils, :batch_job, [socket, clients, params.params])
  end

  def textrepl(socket, _params) do
    poke socket, text: "sup"
  end
  # place your event handlers here
  #
  # def button_clicked(socket, sender) do
  #   set_prop socket, "#output_div", innerHTML: "Clicked the button!"
  # end
  #
  # place you callbacks here
  #
  # onload :page_loaded 
  #
  # def page_loaded(socket) do
  #   set_prop socket, "div.jumbotron h2", innerText: "This page has been drabbed"
  # end
end
