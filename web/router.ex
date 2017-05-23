defmodule Soroban.Router do
  use Soroban.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", Soroban do
    pipe_through :browser
    get "/", PageController, :index
    resources "/jobs", JobController
    resources "/service", ServiceController
    resources "/jobtypes", JobtypeController
  end

end
