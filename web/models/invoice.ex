defmodule Soroban.Invoice do
  use Soroban.Web, :model

  schema "invoices" do
    field :number, :string
    field :date, Ecto.Date
    field :start, Ecto.Date
    field :end, Ecto.Date
    field :total, :float
    belongs_to :client, Soroban.Client

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:number, :date, :start, :end, :total, :client_id])
    |> validate_required([:number, :date, :start, :end])
  end
end