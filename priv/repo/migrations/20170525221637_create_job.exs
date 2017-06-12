defmodule Soroban.Repo.Migrations.CreateJob do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :date, :date
      add :reference, :string
      add :caller, :string
      add :type, :string
      add :description, :text
      add :zone, :string
      add :service, :string
      add :details, :text
      add :total, :integer
      add :client_id, references(:clients, on_delete: :nothing)

      timestamps()
    end
    create index(:jobs, [:client_id])

  end
end
