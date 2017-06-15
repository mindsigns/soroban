defmodule Soroban.Repo.Migrations.CreateSetting do
  use Ecto.Migration

  def change do
    create table(:settings) do
      add :company_name, :string
      add :company_address, :text
      add :company_email, :string

      timestamps()
    end

  end
end
