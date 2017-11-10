defmodule Soroban.Email do
  use Bamboo.Phoenix, view: Soroban.EmailView

  alias Soroban.Mailer

  @moduledoc """
  A module for sending emails

  Our emails can be sent as pure text, HTML or even as an application view, but
  to keep it simple we will use text only in the examples below.
  Check the Phoenix Framework docs (http://www.phoenixframework.org/docs/sending-email)
  for more details on how to send other types of emails
  """

  @doc """
  An email with a confirmation link in it.
  """
  def ask_confirm(email, link) do
    sender = Soroban.Utils.get_sender()
    new_email()
    |> to(email)
    |> from(sender)
    |> subject("Confirm your account - Welcome to Soroban")
    |> text_body("Confirm yoursoroban email here http://soroban.sh/sessions/confirm_email?#{link}")
    |> Mailer.deliver_now
  end

  @doc """
  An with a link to reset the password.
  """
  def ask_reset(email, link) do
    sender = Soroban.Utils.get_sender()
    new_email()
    |> to(email)
    |> from(sender)
    |> subject("Reset your password - Soroban")
    |> text_body("Reset your password at http://soroban.sh/password_resets/edit?#{link}")
    |> Mailer.deliver_now
  end

  @doc """
  An email acknowledging that the account has been successfully confirmed.
  """
  def receipt_confirm(email) do
    sender = Soroban.Utils.get_sender()
    new_email()
    |> to(email)
    |> from(sender)
    |> subject("Confirmed account - Soroban")
    |> text_body("Your account has been confirmed!")
    |> Mailer.deliver_now
  end

  def invoice_html_email(email_address, invoice, jobs, total, company) do
    sender = Soroban.Utils.get_sender()
    new_email()
    |> to(email_address)
    |> from(sender)
    |> subject("Invoice")
    |> put_html_layout({Soroban.LayoutView, "email.html"})
    |> render("invoice.html", email_address: email_address, 
              invoice: invoice, jobs: jobs, 
              total: total, company: company)
  end

end
