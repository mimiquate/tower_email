if Code.ensure_loaded?(Tower.Igniter) do
  defmodule Mix.Tasks.TowerEmail.Task.InstallTest do
    use ExUnit.Case, async: true
    import Igniter.Test

    test "generates everything from scratch" do
      test_project()
      |> Igniter.compose_task("tower_email.install", [])
      |> assert_creates("config/config.exs", """
      import Config
      config :tower, reporters: [TowerEmail]
      config :tower_email, from: {"Tower", "tower@<YOUR_DOMAIN>"}, to: "<RECIPIENT EMAIL ADDRESS>"
      import_config "\#\{config_env()\}.exs"
      """)
      |> assert_creates("config/runtime.exs", """
      import Config

      config :tower_email,
        otp_app: :test,
        environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))

      # Uncomment this line to use configure Postmark's API key, or configure your providers env variables
      # config :tower_email, TowerEmail.Mailer, api_key: System.fetch_env!("POSTMARK_API_KEY")
      """)
    end

    test "modifies existing tower configs if available" do
      test_project(
        files: %{
          "config/config.exs" => """
          import Config

          config :tower, reporters: [TowerSlack]
          """,
          "config/runtime.exs" => """
          import Config
          """
        }
      )
      |> Igniter.compose_task("tower_email.install", [])
      |> assert_has_patch("config/config.exs", """
       1 1   |import Config
       2 2   |
       3   - |config :tower, reporters: [TowerSlack]
       3 + |config :tower, reporters: [TowerSlack, TowerEmail]
       4 + |config :tower_email, from: {"Tower", "tower@<YOUR_DOMAIN>"}, to: "<RECIPIENT EMAIL ADDRESS>"

      """)
      |> assert_has_patch("config/runtime.exs", """
      |import Config
      |
      + |config :tower_email,
      + |  otp_app: :test,
      + |  environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
      + |
      + |# Uncomment this line to use configure Postmark's API key, or configure your providers env variables
      + |# config :tower_email, TowerEmail.Mailer, api_key: System.fetch_env!("POSTMARK_API_KEY")
      """)
    end

    test "is idempotent" do
      test_project()
      |> Igniter.compose_task("tower_email.install", [])
      |> apply_igniter!()
      |> Igniter.compose_task("tower_email.install", [])
      |> assert_unchanged()
    end

    test "does not add commented configs when actual configs exist" do
      test_project(
        files: %{
          "config/config.exs" => """
          import Config
          """,
          "config/prod.exs" => """
          import Config

          config :tower_email, TowerEmail.Mailer, adapter: Swoosh.Adapter.SMTP
          """,
          "config/runtime.exs" => """
          import Config

          config :tower_email, TowerEmail.Mailer, api_key: System.fetch_env!("SMTP_PASSWORD")
          """
        }
      )
      |> Igniter.compose_task("tower_email.install", [])
      |> apply_igniter!()
      |> assert_unchanged()
    end
  end
end
