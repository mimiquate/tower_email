defmodule TowerEmail.Message do
  @moduledoc false

  def new(grouping_id, title, formatted, metadata \\ []) do
    if not muted_issue?(grouping_id) do
      reopened? = reopened_issue?(Keyword.get(metadata, :id))

      Swoosh.Email.new(
        to: Application.fetch_env!(:tower_email, :to),
        from:
          Application.get_env(:tower_email, :from, {"Undefined From", "undefined@example.com"}),
        subject: subject(grouping_id, title),
        html_body: html_body(formatted, metadata, reopened?),
        text_body: text_body(formatted, metadata, reopened?)
      )
    end
  end

  defp muted_issue?(grouping_id) do
    Code.ensure_loaded?(TowerWeb) and function_exported?(TowerWeb, :issue_muted?, 1) and
      TowerWeb.issue_muted?(String.to_integer(grouping_id))
  end

  defp reopened_issue?(event_id) do
    Code.ensure_loaded?(TowerWeb) and function_exported?(TowerWeb, :issue_reopened?, 1) and
      TowerWeb.issue_reopened?(event_id)
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

  require EEx

  EEx.function_from_string(
    :defp,
    :html_body,
    """
    <%= if reopened? do %>
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:#eef2fd;border-radius:8px;margin:0 0 2em;">
        <tr>
          <td style="padding:9px 20px;">
            <table role="presentation" cellpadding="0" cellspacing="0">
              <tr>
                <td style="padding-right:14px;padding-bottom:2px;font-size:26px;line-height:1;color:#1f3a8a;">&#8635;</td>
                <td width="2" bgcolor="#1f3a8a" style="background-color:#1f3a8a;font-size:0;line-height:0;">&nbsp;</td>
                <td style="vertical-align:middle;padding-left:14px;">
                  <p style="margin:0;font-weight:bold;color:#1f3a8a;font-size:1.1em;white-space:nowrap;">This event reopened a previously resolved issue.</p>
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    <% end %>

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
    """,
    [:formatted, :metadata, :reopened?]
  )

  EEx.function_from_string(
    :defp,
    :text_body,
    """
    <%= if reopened? do %>
    This event reopened a previously resolved issue.

    <% end %>
    <%= formatted %>

    <%= for {key, value} <- metadata do %>
      <%= key %>: <%= value %>
    <% end %>
    """,
    [:formatted, :metadata, :reopened?]
  )
end
