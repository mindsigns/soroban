defmodule Soroban.Invoice do
@moduledoc """
Soroban.Invoice model
"""

  use Soroban.Web, :model

  alias Money

  schema "invoices" do
    field :number, :string
    field :date, :date
    field :start, :date
    field :end, :date
    field :total, Money.Ecto.Type
    field :fees_advanced, Money.Ecto.Type
    field :paid, :boolean, default: false, null: false
    field :paid_on, :date
    belongs_to :client, Soroban.Client

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:number, :date, :start, :end, :total, :fees_advanced, :client_id, :paid, :paid_on])
    |> validate_required([:number, :client_id, :date, :start, :end])
  end
end
