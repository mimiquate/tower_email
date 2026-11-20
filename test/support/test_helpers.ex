defmodule TowerEmail.TestHelpers do
  @moduledoc false

  def run_db_migration(direction) do
    Ecto.Migrator.run(
      TowerEmail.TestRepo,
      [{1, TowerEmail.TestRepo.Migrations.CreateTowerWebDB}],
      direction,
      all: true
    )
  end
end
