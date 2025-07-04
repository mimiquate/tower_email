if Code.ensure_loaded?(Igniter) && Code.ensure_loaded?(Tower.Igniter) do
  defmodule Mix.Tasks.TowerEmail.Install do
    @example "mix igniter.install tower_email"

    @shortdoc "Installs TowerEmail. Invoke with `mix igniter.install tower_email`"
    @moduledoc """
    #{@shortdoc}

    ## Example

    ```bash
    #{@example}
    ```
    """

    alias Sourceror.Zipper

    use Igniter.Mix.Task

    import Tower.Igniter

    @impl Igniter.Mix.Task
    def info(_argv, _composing_task) do
      %Igniter.Mix.Task.Info{
        group: :tower,
        adds_deps: [],
        installs: [],
        example: @example,
        only: nil,
        positional: [],
        composes: [],
        schema: [],
        defaults: [],
        aliases: [],
        required: []
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      app_name = Igniter.Project.Application.app_name(igniter)
      prod_file_path = config_file_path(igniter, "prod.exs")
      runtime_file_path = config_file_path(igniter, "runtime.exs")

      igniter
      |> add_reporter_to_config(TowerEmail)
      |> Igniter.Project.Config.configure(
        "config.exs",
        :tower_email,
        [:from],
        {:code, Sourceror.parse_string!("{\"Tower\", \"tower@<YOUR_DOMAIN>\"}")},
        after: &match?({:config, _, [{_, _, [:tower]} | _]}, &1.node)
      )
      |> Igniter.Project.Config.configure(
        "config.exs",
        :tower_email,
        [:to],
        "<RECIPIENT EMAIL ADDRESS>"
      )
      |> Igniter.Project.Config.configure(
        "runtime.exs",
        :tower_email,
        [:otp_app],
        app_name
      )
      |> Igniter.Project.Config.configure(
        "runtime.exs",
        :tower_email,
        [:environment],
        {:code,
         Sourceror.parse_string!("System.get_env(\"DEPLOYMENT_ENV\", to_string(config_env()))")}
      )
      |> Igniter.Project.Config.configure(
        "dev.exs",
        :tower_email,
        [TowerEmail.Mailer, :adapter],
        Swoosh.Adapters.Local
      )
      |> add_commented_config(
        prod_file_path,
        "Uncomment this line to use Postmark as Provider or use the provider of your choosing",
        "config :tower_email, TowerEmail.Mailer, adapter: Swoosh.Adapter.Postmark"
      )
      |> add_commented_config(
        runtime_file_path,
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

    defp add_commented_config(igniter, file_path, comment, config_line) do
      Igniter.update_elixir_file(igniter, file_path, fn zipper ->
        # Check if the comment already exists to avoid duplicate comments
        file_content =
          zipper
          |> Zipper.root()
          |> Sourceror.to_string()

        if String.contains?(file_content, "# #{comment}") do
          # Comment already exists, don't add it again
          {:ok, zipper}
        else
          # Add the commented lines directly
          zipper =
            zipper
            |> Zipper.topmost()
            |> Zipper.update(fn node ->
              case node do
                {:__block__, meta, children} ->
                  new_meta =
                    meta
                    |> Keyword.update(
                      :trailing_comments,
                      [
                        %{
                          line: 1,
                          text: "# #{comment}",
                          column: 1,
                          next_eol_count: 0,
                          previous_eol_count: 2
                        },
                        %{
                          line: 2,
                          text: "# #{config_line}",
                          column: 1,
                          next_eol_count: 1,
                          previous_eol_count: 1
                        }
                      ],
                      fn existing_comments ->
                        existing_comments ++
                          [
                            %{
                              line: 1,
                              text: "# #{comment}",
                              column: 1,
                              next_eol_count: 0,
                              previous_eol_count: 2
                            },
                            %{
                              line: 2,
                              text: "# #{config_line}",
                              column: 1,
                              next_eol_count: 1,
                              previous_eol_count: 1
                            }
                          ]
                      end
                    )

                  {:__block__, new_meta, children}

                other ->
                  other
              end
            end)

          {:ok, zipper}
        end
      end)
    end
  end
else
  defmodule Mix.Tasks.TowerEmail.Install do
    @example "mix igniter.install tower_email"

    @shortdoc "Installs TowerEmail. Invoke with `mix igniter.install tower_email`"

    @moduledoc """
    #{@shortdoc}

    ## Example

    ```bash
    #{@example}
    ```
    """

    use Mix.Task

    @impl Mix.Task
    def run(_argv) do
      Mix.shell().error("""
      The task 'tower_email.install' requires igniter. Please install igniter and try again.

      For more information, see: https://hexdocs.pm/igniter/readme.html#installation
      """)

      exit({:shutdown, 1})
    end
  end
end
