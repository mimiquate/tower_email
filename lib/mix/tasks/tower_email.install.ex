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

if Code.ensure_loaded?(Igniter) and Code.ensure_loaded?(Tower.Igniter) do
  defmodule Mix.Tasks.TowerEmail.Install do
    @shortdoc "#{__MODULE__.Docs.short_doc()}"

    @moduledoc __MODULE__.Docs.long_doc()

    use Igniter.Mix.Task

    @impl Igniter.Mix.Task
    def info(_argv, _composing_task) do
      %Igniter.Mix.Task.Info{
        group: :tower_email,
        example: __MODULE__.Docs.example()
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      # Do your work here and return an updated igniter
      igniter
      |> Tower.Igniter.reporters_list_append(TowerEmail)
      |> Igniter.Project.Config.configure(
        "dev.exs",
        :tower_email,
        [TowerEmail.Mailer, :adapter],
        code_value(~s[Swoosh.Adapters.Local])
      )
      |> Igniter.Project.Config.configure(
        "test.exs",
        :tower_email,
        [TowerEmail.Mailer, :adapter],
        code_value(~s[Swoosh.Adapters.Test])
      )
      |> Igniter.Project.Config.configure(
        "config.exs",
        :tower_email,
        [:otp_app],
        Igniter.Project.Application.app_name(igniter)
      )
      |> Igniter.Project.Config.configure(
        "config.exs",
        :tower_email,
        [:from],
        code_value(~s[{"Tower", "tower@<YOUR_DOMAIN>"}])
      )
      |> Igniter.Project.Config.configure(
        "config.exs",
        :tower_email,
        [:to],
        "<RECIPIENT_EMAIL_ADDRESS>"
      )
      |> Tower.Igniter.runtime_configure_reporter(
        :tower_email,
        environment: code_value(~s[System.get_env("DEPLOYMENT_ENV", to_string(config_env()))])
      )
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
