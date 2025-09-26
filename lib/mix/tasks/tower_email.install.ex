defmodule Mix.Tasks.TowerEmail.Install.Docs do
  @moduledoc false

  @spec task_name() :: String.t()
  def task_name do
    "tower_email.install"
  end

  @spec short_doc() :: String.t()
  def short_doc do
    "Installs TowerEmail"
  end

  @spec example() :: String.t()
  def example do
    "mix #{task_name()}"
  end

  @spec long_doc() :: String.t()
  def long_doc do
    """
    #{short_doc()}

    ## Example

    ```sh
    #{example()}
    ```
    """
  end
end

if Code.ensure_loaded?(Igniter) and
     Code.ensure_loaded?(Tower.Igniter) and
     function_exported?(Tower.Igniter, :runtime_configure_reporter, 3) do
  defmodule Mix.Tasks.TowerEmail.Install do
    @shortdoc "#{__MODULE__.Docs.short_doc()}"

    @moduledoc __MODULE__.Docs.long_doc()

    use Igniter.Mix.Task

    alias Sourceror.Zipper

    @impl Igniter.Mix.Task
    def info(_argv, _composing_task) do
      %Igniter.Mix.Task.Info{
        group: :tower,
        example: __MODULE__.Docs.example()
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      igniter
      |> Tower.Igniter.reporters_list_append(TowerEmail)
      |> Igniter.Project.Config.configure(
        "dev.exs",
        :tower_email,
        [TowerEmail.Mailer, :adapter],
        Swoosh.Adapters.Local
      )
      |> Igniter.Project.Config.configure(
        "test.exs",
        :tower_email,
        [TowerEmail.Mailer, :adapter],
        Swoosh.Adapters.Test
      )
      |> Igniter.Project.Config.configure(
        "config.exs",
        :tower_email,
        [:otp_app],
        Igniter.Project.Application.app_name(igniter),
        after: &match?({:config, _, [{_, _, [:tower]} | _]}, &1.node)
      )
      |> Igniter.Project.Config.configure(
        "config.exs",
        :tower_email,
        [:from],
        code_value(~s[{"Tower", "tower@<YOUR_DOMAIN>"}]),
        after: &match?({:config, _, [{_, _, [:tower]} | _]}, &1.node)
      )
      |> Igniter.Project.Config.configure(
        "config.exs",
        :tower_email,
        [:to],
        "<RECIPIENT_EMAIL_ADDRESS>",
        after: &match?({:config, _, [{_, _, [:tower]} | _]}, &1.node)
      )
      |> Tower.Igniter.runtime_configure_reporter(
        :tower_email,
        environment: code_value(~s[System.get_env("DEPLOYMENT_ENV", to_string(config_env()))])
      )
      |> add_commented_config(
        config_file_path(igniter, "prod.exs"),
        "Uncomment this line to use Postmark as Provider or use the provider of your choosing",
        "config :tower_email, TowerEmail.Mailer, adapter: Swoosh.Adapter.Postmark"
      )
      |> add_commented_config(
        config_file_path(igniter, "runtime.exs"),
        "Uncomment this line to use configure Postmark's API key, or configure your providers env variables",
        "config :tower_email, TowerEmail.Mailer, api_key: System.fetch_env!(\"POSTMARK_API_KEY\")"
      )
    end

    defp config_file_path(igniter, file_name) do
      case igniter |> Igniter.Project.Application.config_path() |> Path.split() do
        [path] -> [path]
        path -> Enum.drop(path, -1)
      end
      |> Path.join()
      |> Path.join(file_name)
    end

    defp flatten_ast(ast) do
      ast
      |> Macro.prewalk([], fn node, acc ->
        {node, [node | acc]}
      end)
      |> elem(1)
      |> Enum.reverse()
    end

    defp add_commented_config(igniter, file_path, comment, config_line) do
      Igniter.update_elixir_file(igniter, file_path, fn zipper ->
        if check_existing_comment_and_config(zipper, comment, config_line) do
          {:ok, zipper}
        else
          {:ok, add_comment_to_ast(zipper, comment, config_line)}
        end
      end)
    end

    defp check_existing_comment_and_config(zipper, comment, config_line) do
      {comment_exists?, config_exists?} =
        zipper
        |> Zipper.root()
        |> flatten_ast()
        |> Enum.reduce_while({false, false}, fn node, acc ->
          cond do
            mailer_config_node?(node) and mailer_config_matches?(config_line) ->
              {:halt, merge_states(acc, {false, true})}

            has_metadata?(node) and comment_exists_in_node?(elem(node, 1), comment) ->
              {:halt, merge_states(acc, {true, false})}

            true ->
              {:cont, merge_states(acc, {false, false})}
          end
        end)

      comment_exists? || config_exists?
    end

    defp merge_states(
           {comment_found_acc, config_found_acc},
           {comment_found_new, config_found_new}
         ) do
      {comment_found_acc or comment_found_new, config_found_acc or config_found_new}
    end

    defp mailer_config_node?(node) do
      match?(
        {:config, _meta,
         [{:__block__, _, [:tower_email]}, {:__aliases__, _, [:TowerEmail, :Mailer]}, _opts]},
        node
      )
    end

    defp has_metadata?(node) do
      match?({_, _meta, _}, node)
    end

    defp mailer_config_matches?(config_line) do
      String.contains?(config_line, "TowerEmail.Mailer")
    end

    defp comment_exists_in_node?(meta, comment) do
      trailing_comments = Keyword.get(meta, :trailing_comments, [])
      leading_comments = Keyword.get(meta, :leading_comments, [])

      Enum.any?(trailing_comments ++ leading_comments, fn comment_map ->
        Map.get(comment_map, :text) == "# #{comment}"
      end)
    end

    defp add_comment_to_ast(zipper, comment, config_line) do
      zipper
      |> Zipper.topmost()
      |> Zipper.update(fn node ->
        with {:__block__, meta, children} <- node do
          new_meta = update_trailing_comments(meta, comment, config_line)
          {:__block__, new_meta, children}
        end
      end)
    end

    defp update_trailing_comments(meta, comment, config_line) do
      new_comments = [
        create_comment_map(comment, 1, 0, 2),
        create_comment_map(config_line, 2, 1, 1)
      ]

      Keyword.update(meta, :trailing_comments, new_comments, fn existing_comments ->
        existing_comments ++ new_comments
      end)
    end

    defp create_comment_map(text, line, next_eol_count, previous_eol_count) do
      %{
        line: line,
        text: "# #{text}",
        column: 1,
        next_eol_count: next_eol_count,
        previous_eol_count: previous_eol_count
      }
    end

    defp code_value(value) do
      {:code, Sourceror.parse_string!(value)}
    end
  end
else
  defmodule Mix.Tasks.TowerEmail.Install do
    @shortdoc "#{__MODULE__.Docs.short_doc()} | Install `igniter` to use"

    @moduledoc __MODULE__.Docs.long_doc()

    @error_message """
    The task '#{__MODULE__.Docs.task_name()}' requires igniter plus tower >= 0.8.4. Please install igniter and/or update tower and try again.

    For more information, see: https://hexdocs.pm/igniter/readme.html#installation
    """

    use Mix.Task

    @impl Mix.Task
    def run(_argv) do
      Mix.shell().error(@error_message)
      exit({:shutdown, 1})
    end
  end
end
