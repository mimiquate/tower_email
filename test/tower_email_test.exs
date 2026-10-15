defmodule TowerEmailTest do
  use ExUnit.Case
  doctest TowerEmail

  import ExUnit.CaptureLog, only: [capture_log: 1]

  @base_url "http://localhost:4000/tower_errors"

  setup do
    Application.put_env(:tower, :reporters, [TowerEmail])
    Application.put_env(:tower_email, :to, "to@example.com")
    Application.put_env(:tower_web, :base_url, @base_url)

    :ok
  end

  test "reports arithmetic error" do
    capture_log(fn ->
      in_unlinked_process(fn ->
        exit(:badarith)
      end)
    end)

    # TODO: Support waiting on assert_email_sent with a timeout
    # Swoosh.TestAssertions.assert_email_sent(subject: "ArithmeticError: bad argument in arithmetic expression")
    assert_receive(
      {
        :email,
        %{
          subject:
            "[tower_email][test] ** (ArithmeticError) bad argument in arithmetic expression (#" <>
              <<_id::binary-size(10)>> <> ")"
        }
      },
      1_000
    )
  end

  test "reports long match error" do
    capture_log(fn ->
      in_unlinked_process(fn ->
        exit({
          :badmatch,
          [
            one: "one",
            two: "two",
            three: "three",
            four: "four",
            five: "five",
            six: "six",
            seven: "seven",
            eight: "eight",
            nine: "nine",
            ten: "ten"
          ]
        })
      end)
    end)

    # TODO: Support waiting on assert_email_sent with a timeout
    # Swoosh.TestAssertions.assert_email_sent(subject: "ArithmeticError: bad argument in arithmetic expression")
    assert_receive(
      {
        :email,
        %{
          # Loosely match on formatted value given Exception.message changed it's format from
          # Elixir 1.19+ compared to Elixir 1.18 or less
          subject:
            "[tower_email][test] ** (MatchError) no match of right hand side value:" <>
              <<_formatted_value::binary-size(27)>> <>
              "... (#" <>
              <<_grouping_id::binary-size(10)>> <>
              ")"
        }
      },
      1_000
    )
  end

  test "links to the Tower Web occurrence of the reported event" do
    Tower.report_message(:error, "Something went wrong")

    assert_receive({:email, email}, 1_000)

    url = "#{@base_url}/occurrences/#{event_id(email)}"

    assert email.html_body =~ ~s(<a href="#{url}">View occurrence in Tower Web</a>)
    assert email.text_body =~ "View occurrence in Tower Web: #{url}"
  end

  defp event_id(email) do
    [_, id] = Regex.run(~r/id: ([0-9a-f-]{36})/, email.text_body)
    id
  end

  defp in_unlinked_process(fun) when is_function(fun, 0) do
    {:ok, pid} = Task.Supervisor.start_link()

    pid
    |> Task.Supervisor.async_nolink(fun)
    |> Task.yield()
  end
end
