defmodule TowerEmailTest do
  use ExUnit.Case
  doctest TowerEmail

  import ExUnit.CaptureLog, only: [capture_log: 1]

  setup do
    Application.put_env(:tower, :reporters, [TowerEmail])
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
          subject:
            ~s{[tower_email][test] ** (MatchError) no match of right hand side value: [one: "one", two: "two", t... (#} <>
              <<_id::binary-size(10)>> <> ")"
        }
      },
      1_000
    )
  end

  test "reports error when the reason is a tuple" do
    capture_log(fn ->
      in_unlinked_process(fn ->
        exit(
          {{%{
              message:
                "tcp recv: closed (the connection was closed by the pool, possibly due to a timeout or because the pool has been terminated)",
              severity: :error,
              reason: :error
            }, []}, {GenServer, :call, [Foo, {:foo, :bar}]}}
        )
      end)
    end)

    assert_receive(
      {
        :email,
        %{
          subject:
            "[tower_email][test] ** (exit) exited in: GenServer.call(Foo, {:foo, :bar})\n    ** (EXIT) {%{messa... (#" <>
              <<_id::binary-size(10)>> <> ")"
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
