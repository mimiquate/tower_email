import Config

config :tower_web, pruner: false, repo: TowerEmail.TestRepo

config :tower_email,
  ecto_repos: [TowerEmail.TestRepo]

config :tower_email, TowerEmail.TestRepo,
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/support/tower_web_db",
  url: System.get_env("POSTGRES_URL") || "postgres://localhost:5432/tower_email_test",
  log: false
