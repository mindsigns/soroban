defmodule Soroban.Repo.Migrations.CreateInvoice do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :number, :string
      add :date, :date
      add :start, :date
      add :end, :date
      add :total, :integer
      add :client_id, references(:clients, on_delete: :nothing)

      timestamps()
    end
    create index(:invoices, [:client_id])

  end
end
