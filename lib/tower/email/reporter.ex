defmodule Tower.Email.Reporter do
  @behaviour Tower.Reporter

  @impl true
  def report_event(%Tower.Event{kind: :error, reason: exception, stacktrace: stacktrace}) do
    send_email(inspect(exception.__struct__), Exception.message(exception), stacktrace)
  end

  def report_event(%Tower.Event{kind: :throw, reason: reason, stacktrace: stacktrace}) do
    send_email("Uncaught throw", reason, stacktrace)
  end

  def report_event(%Tower.Event{kind: :exit, reason: reason, stacktrace: stacktrace}) do
    send_email("Exit", reason, stacktrace)
  end

  def report_event(%Tower.Event{kind: :message, level: level, reason: message}) do
    m =
      if is_binary(message) do
        message
      else
        inspect(message)
      end

    send_email("[#{level}] #{m}", "")
  end

  defp send_email(kind, reason, stacktrace \\ nil) do
    {:ok, _} =
      Tower.Email.Message.new(kind, reason, stacktrace)
      |> Tower.Email.Mailer.deliver()

    :ok
  end
end
