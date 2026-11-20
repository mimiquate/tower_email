defmodule TowerEmail.TestRepo.Migrations.CreateTowerWebDB do
  use Ecto.Migration

  def up, do: TowerWeb.DB.Migration.up(from: 0, to: 6)
  def down, do: TowerWeb.DB.Migration.down(from: 6, to: 0)
end
