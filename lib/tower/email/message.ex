defmodule Tower.Email.Message do
  def new(subject, html_body, text_body) do
    Bamboo.Email.new_email(
      to: "to",
      from: "from",
      subject: subject,
      html_body: html_body,
      text_body: text_body
    )
  end
end
