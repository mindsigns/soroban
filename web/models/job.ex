defmodule Soroban.Job do
  use Soroban.Web, :model

  schema "jobs" do
    field :reference, :string
    field :caller, :string
    field :job_type, :string
    field :description, :string
    field :zone, :string
    field :service, :string
    field :charge_details, :string
    field :job_total, :float
    field :invoice_number, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:reference, :caller, :job_type, :description, :zone, :service, :charge_details, :job_total, :invoice_number])
    |> validate_required([:reference, :caller, :job_type, :description, :zone, :service, :job_total, :invoice_number])
  end
end
