defmodule Tower.Email.Reporter do
  @behaviour Tower.Reporter

  @html_template """
    <h1><%= kind %></h1>
    <h2><%= reason %></h2>
  """

  @text_template """
    Kind: <%= kind %>
    Reason: <%= reason %>
  """

  @impl true
  def report_exception(exception, _stacktrace, _metadata \\ %{}) when is_exception(exception) do
    send_email(exception.__struct__, Exception.message(exception))
  end

  @impl true
  def report_throw(reason, _stacktrace, _metadata \\ %{}) do
    send_email("Uncaught throw", reason)
  end

  @impl true
  def report_exit(reason, _stacktrace, _metadata \\ %{}) do
    send_email("EXIT", reason)
  end

  @impl true
  def report_message(level, message, metadata \\ %{})

  def report_message(level, message, _metadata) when is_binary(message) do
    send_email("[#{level}] #{message}", "")
  end

  def report_message(level, message, _metadata) when is_list(message) or is_map(message) do
    send_email("[#{level}] #{inspect(message)}", "")
  end

  defp send_email(kind, reason) do
    {:ok, _} =
      Tower.Email.Message.new(
        "#{kind}: #{reason}",
        EEx.eval_string(@html_template, kind: kind, reason: reason),
        EEx.eval_string(@text_template, kind: kind, reason: reason)
      )
      |> Tower.Email.Mailer.deliver()

    :ok
  end
end
