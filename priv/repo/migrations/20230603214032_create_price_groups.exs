defmodule KucoinPump.Repo.Migrations.CreatePriceGroups do
  use Ecto.Migration

  def change do
    create table(:price_groups) do
      add :symbol, :string, null: false
      add :tick_count, :integer, null: false
      add :relative_price_change, :float, null: false
      add :last_price, :float, null: false
      add :last_event_time, :utc_datetime, null: false
      timestamps()
    end
  end
end
