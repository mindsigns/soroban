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
    get "/help", AdminController, :help

    resources "/jobs", JobController
    get "/joblist", JobController, :archive
    get "/joblist/:year", JobController, :list_by_year
    get "/joblist/:year/:month", JobController, :list_by_month
    resources "/service", ServiceController
    resources "/jobtypes", JobtypeController
    resources "/clients", ClientController do
      get "/warning", ClientController, :client_delete
    end
    resources "/invoices", InvoiceController do
      get "/send_email", InvoiceController, :send_email
      get "/show", InvoiceController, :show_invoice
    end
    get "/invoices/sendpdf/:id", InvoiceController, :send_pdf
    get "/clear_cache/:type", InvoiceController, :clear_cache
    get "/invoices/view/:id", InvoiceController, :view
    post "/invoices/paid", InvoiceController, :paid
    post "/invoices/multipay", InvoiceController, :multipay

    get "/outstanding", OutstandingController, :index

    get "/invoice/batch", BatchController, :index
    post "/invoice/generate_all", BatchController, :generate_all
    get "/invoice/delete/:id", BatchController, :delete
    get "/invoice/sendzip/:invoice", BatchController, :send_zip
    get "/invoice/email_all/:invoice", BatchController, :email_all

    resources "/settings", SettingController
    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/sessions/confirm_email", SessionController, :confirm_email
    resources "/password_resets", PasswordResetController, only: [:new, :create]
    get "/password_resets/edit", PasswordResetController, :edit
    put "/password_resets/update", PasswordResetController, :update
  end
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
end
