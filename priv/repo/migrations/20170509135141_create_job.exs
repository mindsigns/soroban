defmodule Soroban.Repo.Migrations.CreateJob do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :reference, :string
      add :job_date, :date
      add :caller, :string
      add :job_type, :string
      add :description, :text
      add :zone, :string
      add :service, :string
      add :charge_details, :string
      add :job_total, :float
      add :invoice_number, :string

      timestamps()
    end

  end
end
