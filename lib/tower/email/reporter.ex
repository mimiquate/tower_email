defmodule Tower.Email.Reporter do
  @behaviour Tower.Reporter

  @impl true
  def report_event(%Tower.Event{kind: :error, id: id, reason: exception, stacktrace: stacktrace}) do
    send_email(id, inspect(exception.__struct__), Exception.message(exception), stacktrace)
  end

  def report_event(%Tower.Event{kind: :throw, id: id, reason: reason, stacktrace: stacktrace}) do
    send_email(id, "Uncaught throw", reason, stacktrace)
  end

  def report_event(%Tower.Event{kind: :exit, id: id, reason: reason, stacktrace: stacktrace}) do
    send_email(id, "Exit", reason, stacktrace)
  end

  def report_event(%Tower.Event{kind: :message, id: id, level: level, reason: message}) do
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
      Tower.Email.Message.new(id, kind, reason, stacktrace)
      |> Tower.Email.Mailer.deliver()

    :ok
  end
end
