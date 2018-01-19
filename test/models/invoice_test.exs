defmodule Soroban.InvoiceTest do
  use Soroban.ModelCase

  alias Soroban.Invoice

  @valid_attrs %{
    date: %{day: 17, month: 4, year: 2010},
    end: %{day: 17, month: 4, year: 2010},
    number: "some content",
    start: %{day: 17, month: 4, year: 2010},
    total: "120.5"
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Invoice.changeset(%Invoice{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Invoice.changeset(%Invoice{}, @invalid_attrs)
    refute changeset.valid?
  end
end
