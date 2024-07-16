defmodule TowerEmailTest do
  use ExUnit.Case
  doctest TowerEmail

  setup do
    Application.put_env(:tower, :reporters, [Tower.Email.Reporter])
    Application.put_env(:tower_email, :to, "to@example.com")

    Tower.attach()

    on_exit(fn ->
      Tower.detach()
    end)
  end

  @tag capture_log: true
  test "reports arithmetic error" do
    in_unlinked_process(fn ->
      1 / 0
    end)

    # TODO: Support waiting on assert_email_sent with a timeout
    # Swoosh.TestAssertions.assert_email_sent(subject: "ArithmeticError: bad argument in arithmetic expression")
    assert_receive(
      {:email, %{subject: "ArithmeticError: bad argument in arithmetic expression"}},
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
