defmodule TowerEmailTest do
  use ExUnit.Case
  doctest TowerEmail

  import ExUnit.CaptureLog, only: [capture_log: 1]

  defmodule BrokenEndpoint do
    # Like a Phoenix endpoint that hasn't started yet
    def url, do: raise(ArgumentError, "endpoint not started")
  end

  defmodule FakeEndpoint do
    # Stands in for the host application's Phoenix endpoint
    def url, do: "http://localhost:4000"
    def path(path), do: path
  end

  defmodule Router do
    use Phoenix.Router
    import TowerWeb.Router

    tower_dashboard("/tower_errors")
  end

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

  test "doesn't link to Tower Web when tower_web is not configured" do
    capture_log(fn ->
      in_unlinked_process(fn ->
        exit(:badarith)
      end)
    end)

    assert_receive({:email, email}, 1_000)

    refute email.html_body =~ "View occurrence in Tower Web"
    assert email.html_body =~ ~r/\A<pre style="font-size:1.2em">\*\* \(ArithmeticError\)/
    refute email.text_body =~ "View occurrence in Tower Web"
    assert email.text_body =~ ~r/\A\*\* \(ArithmeticError\)/
  end

  describe "with tower_web configured" do
    setup do
      put_env(:tower_web, :endpoint, FakeEndpoint)
      put_env(:tower_web, :router, Router)

      :ok
    end

    test "links to the occurrence of a crash" do
      capture_log(fn ->
        in_unlinked_process(fn ->
          exit(:badarith)
        end)
      end)

      assert_receive({:email, email}, 1_000)

      url = "#{FakeEndpoint.url()}/tower_errors/occurrences/#{event_id(email)}"

      assert email.html_body =~ ~s(<a href="#{url}">View occurrence in Tower Web</a>)
      assert email.text_body =~ ~r/\A\s*View occurrence in Tower Web: #{Regex.escape(url)}\n/
    end

    test "links to the occurrence of a reported message" do
      Tower.report_message(:error, "Something went wrong")

      assert_receive({:email, email}, 1_000)

      url = "#{FakeEndpoint.url()}/tower_errors/occurrences/#{event_id(email)}"

      assert email.html_body =~ ~s(<a href="#{url}">View occurrence in Tower Web</a>)
      assert email.text_body =~ ~r/\A\s*View occurrence in Tower Web: #{Regex.escape(url)}\n/
    end
  end

  test "still sends the email, and warns, when the occurrence URL can't be built" do
    put_env(:tower_web, :endpoint, BrokenEndpoint)
    put_env(:tower_web, :router, Router)

    log =
      capture_log(fn ->
        in_unlinked_process(fn ->
          exit(:badarith)
        end)

        assert_receive({:email, email}, 1_000)

        refute email.html_body =~ "View occurrence in Tower Web"
        refute email.text_body =~ "View occurrence in Tower Web"
      end)

    assert log =~ "TowerEmail couldn't build the occurrence URL: endpoint not started"
  end

  defp event_id(email) do
    [_, id] = Regex.run(~r/id: ([0-9a-f-]{36})/, email.text_body)
    id
  end

  defp put_env(app, key, value) do
    original_value = Application.get_env(app, key)
    Application.put_env(app, key, value)

    on_exit(fn ->
      if original_value == nil do
        Application.delete_env(app, key)
      else
        Application.put_env(app, key, original_value)
      end
    end)
  end

  defp in_unlinked_process(fun) when is_function(fun, 0) do
    {:ok, pid} = Task.Supervisor.start_link()

    pid
    |> Task.Supervisor.async_nolink(fun)
    |> Task.yield()
  end
end
