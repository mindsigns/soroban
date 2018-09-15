defmodule Soroban.Repo.Migrations.AddAdvTotalToInvoice do
  use Ecto.Migration

  def change do
      alter table(:invoices) do
          add :fees_advanced, :integer
      end
  end
end
