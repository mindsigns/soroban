defmodule Soroban.AdminController do
  @moduledoc """
  Admin controller
  Route: /admin
  """
  use Soroban.Web, :controller

  import Soroban.Authorize
  import Ecto.Query

  alias Soroban.{Repo, Job, Invoice}

  plug :user_check when action in [:index]

  @doc """
  Route: GET /admin
  Main index page for admin
  """
  def index(conn, _params) do
    date = Date.utc_today()
    {:ok, this} = Ecto.Date.cast(date)

    res = Job
            |> group_by([e], fragment("date_part('month', ?)", e.date))
            |> select([e], {fragment("date_part('month', ?)", e.date), count(e.id)})
            |> where([e], fragment("date_part('year', ?)", e.date) == ^this.year)
            |> Repo.all

    list = Enum.sort(res)

    dates = for {x, y} <- list, do:
              {assign_month(x), y}


    months = for {x, _} <- dates, do: x
    jobs = for {_, y} <- dates, do: y

    {zipcount, pdfcount} = Soroban.Utils.cache_count
    jobcount          = Enum.count(Repo.all(Job))
    invoicecount      = Enum.count(Repo.all(Invoice))
    outstandingcount  = Soroban.Outstanding.total_count

    render(conn, "index.html", months: months, jobs: jobs, zipcount: zipcount,
           pdfcount: pdfcount, jobcount: jobcount, invoicecount: invoicecount, 
           outstandingcount: outstandingcount, year: this.year)
  end

  @doc """
  Route: GET /help
  Static Help page
  """
  def help(conn, _params) do
    render(conn, "help.html")
  end

  #
  # Private functions
  #

  # Convert dates for charting
   defp assign_month(x) do
      case round(x) do
        1  -> "Jan"
        2  -> "Feb"
        3  -> "Mar"
        4  -> "Apr"
        5  -> "May"
        6  -> "Jun"
        7  -> "Jul"
        8  -> "Aug"
        9  -> "Sep"
        10 -> "Oct"
        11 -> "Nov"
        12 -> "Dec"
        _  -> "uhhh"
      end
   end

end
