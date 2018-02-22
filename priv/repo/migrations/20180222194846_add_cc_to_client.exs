defmodule Soroban.Repo.Migrations.AddCcToClient do
  use Ecto.Migration

  def change do
    alter table(:clients) do
      add :cc_email, :string
    end
  end
end
