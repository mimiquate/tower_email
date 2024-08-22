defmodule TowerEmail.Reporter do
  @behaviour Tower.Reporter

  @default_level :error

  @impl true
  def report_event(%Tower.Event{level: level} = event) do
    if Tower.equal_or_greater_level?(level, level()) do
      do_report_event(event)
    end
  end

  defp do_report_event(%Tower.Event{
         kind: :error,
         id: id,
         reason: exception,
         stacktrace: stacktrace
       }) do
    send_email(id, inspect(exception.__struct__), Exception.message(exception), stacktrace)
  end

  defp do_report_event(%Tower.Event{kind: :throw, id: id, reason: reason, stacktrace: stacktrace}) do
    send_email(id, "Uncaught throw", reason, stacktrace)
  end

  defp do_report_event(%Tower.Event{kind: :exit, id: id, reason: reason, stacktrace: stacktrace}) do
    send_email(id, "Exit", reason, stacktrace)
  end

  defp do_report_event(%Tower.Event{kind: :message, id: id, level: level, reason: message}) do
    m =
      if is_binary(message) do
        message
      else
        inspect(message)
      end

    send_email(id, "[#{level}] #{m}", "")
  end

  defp send_email(id, kind, reason, stacktrace \\ nil) do
    {:ok, _} =
      TowerEmail.Message.new(id, kind, reason, stacktrace)
      |> TowerEmail.Mailer.deliver()

    :ok
  end

  defp level do
    # This config env can be to any of the 8 levels in https://www.erlang.org/doc/apps/kernel/logger#t:level/0,
    # or special values :all and :none.
    Application.get_env(:tower_email, :level, @default_level)
  end
end
