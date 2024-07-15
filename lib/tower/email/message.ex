defmodule Tower.Email.Message do
  def new(kind, reason, stacktrace \\ nil) do
    Swoosh.Email.new(
      to: "TBD",
      from: "TBD",
      subject: "#{kind}: #{reason}",
      html_body: html_body(kind, reason, stacktrace),
      text_body: text_body(kind, reason, stacktrace)
    )
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
      Kind: <%= kind %>
      Reason: <%= reason %>

      <%= if stacktrace do %>
        Stacktrace:

        <%= for entry <- stacktrace do %>
          <%= Exception.format_stacktrace_entry(entry) %>
        <% end %>
      <% end %>
    """,
    [:kind, :reason, :stacktrace]
  )
end
