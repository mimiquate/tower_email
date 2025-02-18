defmodule TowerEmail.Reporter do
  @moduledoc false

  @default_level :error

  def report_event(%Tower.Event{level: level} = event) do
    if Tower.equal_or_greater_level?(level, level()) do
      do_report_event(event)
    end
  end

  defp do_report_event(%Tower.Event{kind: kind, id: id, reason: reason, stacktrace: stacktrace})
       when kind in [:error, :throw, :exit] do
    send_email(
      id,
      Exception.format_banner(kind, reason, stacktrace),
      Exception.format(kind, reason, stacktrace)
    )
  end

  defp do_report_event(%Tower.Event{kind: :message, id: id, level: level, reason: message}) do
    m =
      if is_binary(message) do
        message
      else
        inspect(message)
      end

    title = "[#{level}] #{m}"

    send_email(id, title, title)
  end

  defp send_email(id, title, body) do
    email_message = TowerEmail.Message.new(id, title, body)

    async(fn ->
      {:ok, _} = TowerEmail.Mailer.deliver(email_message)
    end)

    :ok
  end

  defp level do
    # This config env can be to any of the 8 levels in https://www.erlang.org/doc/apps/kernel/logger#t:level/0,
    # or special values :all and :none.
    Application.get_env(:tower_email, :level, @default_level)
  end

  defp async(fun) do
    Tower.TaskSupervisor
    |> Task.Supervisor.start_child(fun)
  end
end
