defmodule Tower.Email.Message do
  def new(kind, reason, stacktrace \\ nil) do
    Swoosh.Email.new(
      to: Application.fetch_env!(:tower_email, :to),
      from: Application.get_env(:tower_email, :from, {"Undefined From", "undefined@example.com"}),
      subject: "[#{app_name()}][#{environment()}] #{kind}: #{reason}",
      html_body: html_body(kind, reason, stacktrace),
      text_body: text_body(kind, reason, stacktrace)
    )
  end

  defp app_name do
    Application.fetch_env!(:tower_email, :otp_app)
  end

  defp environment do
    Application.fetch_env!(:tower_email, :environment)
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
    """,
    [:kind, :reason, :stacktrace]
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
    """,
    [:kind, :reason, :stacktrace]
  )
end
