# TODO: Remove this conditonal once we only run tests against tower v0.8+
if Code.ensure_loaded?(Tower.Igniter) do
  defmodule Mix.Tasks.TowerEmail.InstallTest do
    use ExUnit.Case, async: true
    import Igniter.Test

    test "generates everything from scratch" do
      test_project()
      |> Igniter.compose_task("tower_email.install", [])
      |> assert_creates(
        "config/config.exs",
        """
        import Config

        config :tower_email,
          otp_app: :test,
          from: {"Tower", "tower@<YOUR_DOMAIN>"},
          to: "<RECIPIENT_EMAIL_ADDRESS>"

        config :tower, reporters: [TowerEmail]
        import_config \"\#{config_env()}.exs\"
        """
      )
      |> assert_creates(
        "config/test.exs",
        """
        import Config
        config :tower_email, TowerEmail.Mailer, adapter: Swoosh.Adapters.Test
        """
      )
      |> assert_creates(
        "config/dev.exs",
        """
        import Config
        config :tower_email, TowerEmail.Mailer, adapter: Swoosh.Adapters.Local
        """
      )
      |> assert_creates(
        "config/runtime.exs",
        """
        import Config
        config :tower_email, environment: System.get_env("DEPLOYMENT_ENV", to_string(config_env()))
        """
      )
    end

    test "is idempotent" do
      test_project()
      |> Igniter.compose_task("tower_email.install", [])
      |> apply_igniter!()
      |> Igniter.compose_task("tower_email.install", [])
      |> assert_unchanged()
    end
  end
end
