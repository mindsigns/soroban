defmodule Soroban.Repo.Migrations.AddInvoicePaidDate do
  use Ecto.Migration

  def change do
      alter table(:invoices) do
          add :paid_on, :date
      end
  end
end
