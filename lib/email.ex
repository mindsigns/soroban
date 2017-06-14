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
    new_email()
    |> to(email)
    |> from("welcome@example.com")
    |> subject("Confirm your account - Welcome Soroban")
    |> text_body("Confirm your Soroban email here http://localhost:4000/sessions/confirm_email?#{link}")
    |> Mailer.deliver_now
  end

  @doc """
  An with a link to reset the password.
  """
  def ask_reset(email, link) do
    new_email()
    |> to(email)
    |> from("welcome@example.com")
    |> subject("Reset your password - Soroban")
    |> text_body("Reset your password at http://localhost:4000/password_resets/edit?#{link}")
    |> Mailer.deliver_now
  end

  @doc """
  An email acknowledging that the account has been successfully confirmed.
  """
  def receipt_confirm(email) do
    new_email()
    |> to(email)
    |> from("welcome@example.com")
    |> subject("Confirmed account - Soroban")
    |> text_body("Your account has been confirmed!")
    |> Mailer.deliver_now
  end

  def invoice_html_email(email_address, invoice, jobs, total) do
    new_email()
    |> to(email_address)
    |> from("us@example.com")
    |> subject("Welcome!")
    |> put_html_layout({Soroban.LayoutView, "email.html"})
    |> render("invoice.html", email_address: email_address, invoice: invoice, jobs: jobs, total: total)
  end

end
