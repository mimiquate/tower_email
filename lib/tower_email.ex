defmodule TowerEmail do
  @moduledoc """
  Simple send-me-an-email reporter for `Tower` error handler.

  ## Example

      config :tower, :reporters, [TowerEmail]
  """

  @behaviour Tower.Reporter

  @impl true
  def report_event(event) do
    TowerEmail.Reporter.report_event(event)
  end
end
