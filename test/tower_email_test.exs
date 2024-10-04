defmodule TowerEmailTest do
  use ExUnit.Case
  doctest TowerEmail

  import ExUnit.CaptureLog, only: [capture_log: 1]

  setup do
    Application.put_env(:tower, :reporters, [TowerEmail.Reporter])
    Application.put_env(:tower_email, :to, "to@example.com")

    :ok
  end

  test "reports arithmetic error" do
    capture_log(fn ->
      in_unlinked_process(fn ->
        1 / 0
      end)
    end)

    # TODO: Support waiting on assert_email_sent with a timeout
    # Swoosh.TestAssertions.assert_email_sent(subject: "ArithmeticError: bad argument in arithmetic expression")
    assert_receive(
      {
        :email,
        %{
          subject:
            "[tower_email][test] ArithmeticError: bad argument in arithmetic expression (" <>
              <<_id::binary-size(36)>> <> ")"
        }
      },
      1_000
    )
  end

  test "reports long match error" do
    capture_log(fn ->
      in_unlinked_process(fn ->
        [eleven: "eleven"] = [
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
      end)
    end)

    # TODO: Support waiting on assert_email_sent with a timeout
    # Swoosh.TestAssertions.assert_email_sent(subject: "ArithmeticError: bad argument in arithmetic expression")
    assert_receive(
      {
        :email,
        %{
          subject:
            ~s{[tower_email][test] MatchError: no match of right hand side value: [one: "one", two: "two", three... (} <>
              <<_id::binary-size(36)>> <> ")"
        }
      },
      1_000
    )
  end

  defp in_unlinked_process(fun) when is_function(fun, 0) do
    {:ok, pid} = Task.Supervisor.start_link()

    pid
    |> Task.Supervisor.async_nolink(fun)
    |> Task.yield()
  end
end
