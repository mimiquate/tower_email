ExUnit.start()

Application.put_env(:tower_email, TowerEmail.Mailer, adapter: Swoosh.Adapters.Test)
Application.put_env(:tower_email, :otp_app, :tower_email)
Application.put_env(:tower_email, :environment, :test)
