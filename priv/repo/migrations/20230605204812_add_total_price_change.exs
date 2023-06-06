defmodule KucoinPump.Repo.Migrations.AddTotalPriceChange do
  use Ecto.Migration

  def change do
    alter table(:price_groups) do
      add :total_price_change, :float
    end
  end
end
