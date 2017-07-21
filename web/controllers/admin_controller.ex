defmodule Soroban.AdminController do
  use Soroban.Web, :controller

  import Soroban.Authorize
  import Ecto.Query

  alias Soroban.{Repo, Job}

  plug :user_check when action in [:index]

  def index(conn, _params) do
    res = Job
            |> group_by([e], fragment("date_part('month', ?)", e.date))
            |> select([e], {fragment("date_part('month', ?)", e.date), count(e.id)})
            |> Repo.all

    list = Enum.sort(res)

    dates = for {x, y} <- list, do:
              {assign_month(x), y}
    

    months = for {x, _} <- dates, do: x
    jobs = for {_, y} <- dates, do: y

    render(conn, "index.html", months: months, jobs: jobs)
  end

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
