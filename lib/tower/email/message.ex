defmodule Tower.Email.Message do

  @html_template """
    <h2>
      <%= kind %>
    </h2>

    <h4>
      <%= reason %>
    </h4>

    <%= if stacktrace do %>
      <code>
        <%= for entry <- stacktrace do %>
          <%= Exception.format_stacktrace_entry(entry) %>
          <br />
        <% end %>
      </code>
    <% end %>
  """

  @text_template """
    Kind: <%= kind %>
    Reason: <%= reason %>

    <%= if stacktrace do %>
      Stacktrace:

      <%= for entry <- stacktrace do %>
        <%= Exception.format_stacktrace_entry(entry) %>
      <% end %>
    <% end %>
  """

  def new(kind, reason, stacktrace \\ nil) do
    Swoosh.Email.new(
      to: "TBD",
      from: "TBD",
      subject: "#{kind}: #{reason}",
      html_body: EEx.eval_string(@html_template, kind: kind, reason: reason, stacktrace: stacktrace),
      text_body: EEx.eval_string(@text_template, kind: kind, reason: reason, stacktrace: stacktrace)
    )
  end
end
