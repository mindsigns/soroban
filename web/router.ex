defmodule Soroban.Router do
  use Soroban.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Openmaize.Authenticate
  end

  scope "/", Soroban do
    pipe_through :browser

    get "/", PageController, :index
    get "/admin", AdminController, :index

    resources "/jobs", JobController
    resources "/service", ServiceController
    resources "/jobtypes", JobtypeController
    resources "/clients", ClientController

    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/sessions/confirm_email", SessionController, :confirm_email
    resources "/password_resets", PasswordResetController, only: [:new, :create]
    get "/password_resets/edit", PasswordResetController, :edit
    put "/password_resets/update", PasswordResetController, :update
  end
    forward "/sent_emails", Bamboo.EmailPreviewPlug
end
