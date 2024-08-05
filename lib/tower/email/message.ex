defmodule Tower.Email.Message do
  @subject_max_length 120

  def new(id, kind, reason, stacktrace \\ nil) do
    Swoosh.Email.new(
      to: Application.fetch_env!(:tower_email, :to),
      from: Application.get_env(:tower_email, :from, {"Undefined From", "undefined@example.com"}),
      subject: truncate(subject(kind, reason), @subject_max_length),
      html_body: html_body(id, kind, reason, stacktrace),
      text_body: text_body(id, kind, reason, stacktrace)
    )
  end

  defp subject(kind, reason) do
    "[#{app_name()}][#{environment()}] #{kind}: #{reason}"
  end

  defp app_name do
    Application.fetch_env!(:tower_email, :otp_app)
  end

  defp environment do
    Application.fetch_env!(:tower_email, :environment)
  end

  defp truncate(text, max_length) do
    if String.length(text) <= max_length do
      text
    else
      suffix = "..."
      "#{String.slice(text, 0, max_length - String.length(suffix))}#{suffix}"
    end
  end

  require EEx

  EEx.function_from_string(
    :defp,
    :html_body,
    """
    <h2>
      <%= kind %>
    </h2>

    <h4>
      <%= reason %>
    </h4>

    <%= if stacktrace do %>
      <code>
        <%= for entry <- stacktrace do %>
          &nbsp;
          <%= Exception.format_stacktrace_entry(entry) %>
          <br />
        <% end %>
      </code>
    <% end %>

    <p>
      ID: <%= id %>
    </p>
    """,
    [:id, :kind, :reason, :stacktrace]
  )

  EEx.function_from_string(
    :defp,
    :text_body,
    """
      <%= kind %>
      <%= reason %>
      <%= if stacktrace do %>
        <%= Exception.format_stacktrace(stacktrace) %>
      <% end %>
      id: <%= id %>
    """,
    [:id, :kind, :reason, :stacktrace]
  )
end
