defmodule Soroban.Client do
  @moduledoc """
  Soroban.Client model
  """

  use Soroban.Web, :model

  schema "clients" do
    field :name, :string
    field :contact, :string
    field :address, :string
    field :email, :string
    field :cc_email, :string

    has_many :jobs, Soroban.Job, on_delete: :delete_all
    has_many :invoices, Soroban.Invoice, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :contact, :address, :email, :cc_email])
    |> cast_assoc(:jobs)
    |> cast_assoc(:invoices)
    |> validate_required([:name, :contact, :address])
  end

end
