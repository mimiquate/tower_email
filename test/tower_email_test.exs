defmodule TowerEmailTest do
  use TowerEmail.DBCase
  doctest TowerEmail

  import ExUnit.CaptureLog, only: [capture_log: 1]

  setup do
    Application.put_env(:tower, :reporters, [TowerWeb.DB.Reporter, TowerEmail])
    Application.put_env(:tower_email, :to, "to@example.com")

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

  test "does not send an email when the issue is muted" do
    crash = fn -> exit(:badarith) end

    capture_log(fn -> in_unlinked_process(crash) end)

    assert_receive({:email, _email}, 1_000)

    [event] = TowerWeb.DB.Events.list_events()
    issue = TowerWeb.DB.Issues.get_issue(event.issue_id)
    muted_until = DateTime.add(DateTime.utc_now(), 3600, :second)
    {:ok, _issue} = TowerWeb.DB.Issues.update_issue(issue, %{muted_until: muted_until})

    capture_log(fn -> in_unlinked_process(crash) end)

    refute_receive({:email, _email}, 1_000)
  end

  test "marks the email as reopened when a new event reopens a resolved issue" do
    crash = fn -> exit(:badarith) end

    capture_log(fn -> in_unlinked_process(crash) end)

    assert_receive({:email, first_email}, 1_000)
    refute first_email.text_body =~ "This event reopened a previously resolved issue."

    [event] = TowerWeb.DB.Events.list_events()
    issue = TowerWeb.DB.Issues.get_issue(event.issue_id)
    {:ok, _issue} = TowerWeb.DB.Issues.update_issue(issue, %{state: :resolved})

    capture_log(fn -> in_unlinked_process(crash) end)

    assert_receive({:email, second_email}, 1_000)
    assert second_email.text_body =~ "This event reopened a previously resolved issue."
  end

  defp in_unlinked_process(fun) when is_function(fun, 0) do
    {:ok, pid} = Task.Supervisor.start_link()

    pid
    |> Task.Supervisor.async_nolink(fun)
    |> Task.yield()
  end
end
