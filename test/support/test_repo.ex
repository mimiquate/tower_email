defmodule TowerEmail.TestRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :tower_email,
    adapter: Ecto.Adapters.Postgres
end
