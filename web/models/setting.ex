defmodule Soroban.Setting do
@moduledoc """
Soroban.Setting model
"""

  use Soroban.Web, :model

  schema "settings" do
    field :company_name, :string
    field :company_address, :string
    field :company_email, :string
    field :note, :string
    field :invoice_image, :string
    field :days_pastdue, :integer
    field :outstanding_note, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:company_name, :company_address, :company_email, :note, :invoice_image, :days_pastdue, :outstanding_note])
    |> validate_required([:company_name, :company_address, :company_email, :days_pastdue, :outstanding_note])
  end
end
