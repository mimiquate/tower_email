ExUnit.start()

Application.put_env(:tower_email, Tower.Email.Mailer, adapter: Swoosh.Adapters.Test)
