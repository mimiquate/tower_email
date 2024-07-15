defmodule Tower.Email.Reporter do
  @behaviour Tower.Reporter

  @impl true
  def report_exception(exception, stacktrace, _metadata \\ %{})
      when is_exception(exception) and is_list(stacktrace) do
    send_email(exception.__struct__, Exception.message(exception), stacktrace)
  end

  @impl true
  def report_throw(reason, stacktrace, _metadata \\ %{}) do
    send_email("Uncaught throw", reason, stacktrace)
  end

  @impl true
  def report_exit(reason, stacktrace, _metadata \\ %{}) do
    send_email("Exit", reason, stacktrace)
  end

  @impl true
  def report_message(level, message, metadata \\ %{})

  def report_message(level, message, _metadata) when is_binary(message) do
    send_email("[#{level}] #{message}", "")
  end

  def report_message(level, message, _metadata) when is_list(message) or is_map(message) do
    send_email("[#{level}] #{inspect(message)}", "")
  end

  defp send_email(kind, reason, stacktrace \\ nil) do
    {:ok, _} =
      Tower.Email.Message.new(kind, reason, stacktrace)
      |> Tower.Email.Mailer.deliver()

    :ok
  end
end
