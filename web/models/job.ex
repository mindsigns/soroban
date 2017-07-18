defmodule Soroban.Job do
    @moduledoc """
+   Soroban.Job model
+   """

  use Soroban.Web, :model
  use Rummage.Ecto

  alias Money

  schema "jobs" do
    field :date, Ecto.Date
    field :reference, :string
    field :caller, :string
    field :type, :string
    field :description, :string
    field :zone, :string
    field :service, :string
    field :details, :string
    field :total, Money.Ecto.Type

    belongs_to :client, Soroban.Client

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date, :reference, :caller, :type, :description, :zone, :service, :details, :total, :client_id])
    |> validate_required([:date, :caller, :type, :description, :zone, :service, :total, :client_id])
  end
end
