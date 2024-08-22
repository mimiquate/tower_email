defmodule TowerEmail.Mailer do
  @moduledoc """
  A `Swoosh.Mailer` for `TowerEmail`.
  """

  use Swoosh.Mailer, otp_app: :tower_email
end
