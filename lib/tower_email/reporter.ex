defmodule TowerEmail.Reporter do
  @moduledoc false

  @default_level :error

  def report_event(%Tower.Event{level: level} = event) do
    if Tower.equal_or_greater_level?(level, level()) do
      do_report_event(event)
    end
  end

  defp do_report_event(%Tower.Event{
         kind: kind,
         id: id,
         reason: reason,
         stacktrace: stacktrace,
         similarity_id: similarity_id,
         datetime: datetime
       })
       when kind in [:error, :throw, :exit] do
    similarity_id = fixed_length_similarity_id(similarity_id)

    send_email(
      similarity_id,
      Exception.format_banner(kind, reason, stacktrace),
      Exception.format(kind, reason, stacktrace),
      id: id,
      similarity_id: similarity_id,
      datetime: datetime
    )
  end

  defp do_report_event(%Tower.Event{
         kind: :message,
         id: id,
         level: level,
         reason: reason,
         similarity_id: similarity_id,
         datetime: datetime
       }) do
    message = "[#{level}] #{if(is_binary(reason), do: reason, else: inspect(reason))}"
    similarity_id = fixed_length_similarity_id(similarity_id)

    send_email(
      similarity_id,
      message,
      message,
      id: id,
      similarity_id: similarity_id,
      datetime: datetime
    )
  end

  defp send_email(similarity_id, title, body, metadata) do
    email_message = TowerEmail.Message.new(similarity_id, title, body, metadata)

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

  defp fixed_length_similarity_id(number) do
    String.pad_leading(to_string(number), 10, "0")
  end

  defp async(fun) do
    Tower.TaskSupervisor
    |> Task.Supervisor.start_child(fun)
  end
end
