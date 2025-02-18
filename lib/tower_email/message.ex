defmodule TowerEmail.Message do
  @moduledoc false

  def new(id, title, formatted) do
    Swoosh.Email.new(
      to: Application.fetch_env!(:tower_email, :to),
      from: Application.get_env(:tower_email, :from, {"Undefined From", "undefined@example.com"}),
      subject: subject(id, title),
      html_body: html_body(id, formatted),
      text_body: text_body(id, formatted)
    )
  end

  defp subject(id, title) do
    truncate("[#{app_name()}][#{environment()}] #{title}", 100) <> " (#{id})"
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
    <pre><%= formatted %></pre>

    <p>
      ID: <%= id %>
    </p>
    """,
    [:id, :formatted]
  )

  EEx.function_from_string(
    :defp,
    :text_body,
    """
    <%= formatted %>

    id: <%= id %>
    """,
    [:id, :formatted]
  )
end
