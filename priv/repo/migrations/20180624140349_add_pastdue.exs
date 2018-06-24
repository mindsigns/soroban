defmodule Soroban.Repo.Migrations.AddPastdue do
  use Ecto.Migration

  def change do
    alter table(:settings) do
      add :days_pastdue, :integer
    end
  end
end
