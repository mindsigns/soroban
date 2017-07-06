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
    post "/jobs/search", JobController, :search
    resources "/service", ServiceController
    resources "/jobtypes", JobtypeController
    resources "/clients", ClientController
    resources "/invoices", InvoiceController do
      get "/generate", InvoiceController, :generate
      get "/show", InvoiceController, :show_invoice
    end
    get "/invoice/batch", InvoiceController, :batch
    post "/invoice/generate_all", InvoiceController, :generate_all

    resources "/settings", SettingController
    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/sessions/confirm_email", SessionController, :confirm_email
    resources "/password_resets", PasswordResetController, only: [:new, :create]
    get "/password_resets/edit", PasswordResetController, :edit
    put "/password_resets/update", PasswordResetController, :update
  end
    forward "/sent_emails", Bamboo.EmailPreviewPlug
end
