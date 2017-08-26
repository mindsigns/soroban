defmodule Soroban.Repo.Migrations.AddFieldToSettings do
  use Ecto.Migration

  def change do
    alter table(:settings) do
      add :invoice_image, :string
    end
  end
end
