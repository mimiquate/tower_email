defmodule Tower.Email.Reporter do
  @behaviour Tower.Reporter

  @impl true
  def report_exception(exception, _stacktrace, _metadata \\ %{}) when is_exception(exception) do
    send_email(exception.__struct__, Exception.message(exception))
  end

  @impl true
  def report_throw(reason, _stacktrace, _metadata \\ %{}) do
    send_email("Uncaught throw: #{reason}", "")
  end

  @impl true
  def report_exit(reason, _stacktrace, _metadata \\ %{}) do
    send_email("EXIT: #{reason}", "")
  end

  @impl true
  def report_message(level, message, metadata \\ %{})

  def report_message(level, message, _metadata) when is_binary(message) do
    send_email("[#{level}] #{message}", "")
  end

  def report_message(level, message, _metadata) when is_list(message) or is_map(message) do
    send_email("[#{level}] #{inspect(message)}", "")
  end

  defp send_email(subject, body) do
    Tower.Email.Message.new(subject, body, body)
    |> Tower.Email.Mailer.deliver_later()
  end
end
