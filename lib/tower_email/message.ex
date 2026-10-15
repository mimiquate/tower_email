defmodule TowerEmail.Message do
  @moduledoc false

  def new(grouping_id, title, formatted, metadata \\ []) do
    occurrence_url = occurrence_url(metadata[:id])

    Swoosh.Email.new(
      to: Application.fetch_env!(:tower_email, :to),
      from: Application.get_env(:tower_email, :from, {"Undefined From", "undefined@example.com"}),
      subject: subject(grouping_id, title),
      html_body: html_body(formatted, metadata, occurrence_url),
      text_body: text_body(formatted, metadata, occurrence_url)
    )
  end

  defp subject(grouping_id, title) do
    truncate("[#{app_name()}][#{environment()}] #{title}", 100) <> " (##{grouping_id})"
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

  defp occurrence_url(id) do
    if Code.ensure_loaded?(TowerWeb) and function_exported?(TowerWeb, :occurrence_url, 1) do
      TowerWeb.occurrence_url(id)
    end
  end

  require EEx

  EEx.function_from_string(
    :defp,
    :html_body,
    """
    <pre style="font-size:1.2em"><%= formatted %></pre>

    <table style="margin-top:3em">
      <tbody>
        <%= for {key, value} <- metadata do %>
          <tr>
            <th align="right" style="font-weight:lighter;color:#666"><%= key %></th>
            <td style="padding-left:1em"><samp><%= value %></samp></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    <%= if occurrence_url do %>
    <p style="margin-top:2em"><a href="<%= occurrence_url %>">View occurrence in Tower Web</a><span style="display:none"><%= metadata[:id] %></span></p>
    <% end %>
    """,
    [:formatted, :metadata, :occurrence_url]
  )

  EEx.function_from_string(
    :defp,
    :text_body,
    """
    <%= formatted %>

    <%= for {key, value} <- metadata do %>
      <%= key %>: <%= value %>
    <% end %>
    <%= if occurrence_url do %>
    View occurrence in Tower Web: <%= occurrence_url %>
    <% end %>
    """,
    [:formatted, :metadata, :occurrence_url]
  )
end
