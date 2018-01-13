defmodule Soroban.Repo.Migrations.AddFeeAdavances do
  use Ecto.Migration

  def change do
      alter table(:jobs) do
          add :fees_advanced, :integer
      end
  end
end
