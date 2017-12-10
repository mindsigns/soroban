defmodule Soroban.Repo.Migrations.AddInvoicePaid do
  use Ecto.Migration

  def change do
      alter table(:invoices) do
          add :paid, :boolean, default: false, null: false
      end
  end
end
