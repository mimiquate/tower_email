defmodule TowerEmail.MixProject do
  use Mix.Project

  @description "Error tracking and reporting to your e-mail inbox"
  @source_url "https://github.com/mimiquate/tower_email"
  @version "0.5.2"

  def project do
    [
      app: :tower_email,
      description: @description,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # Docs
      name: "TowerEmail",
      source_url: @source_url,
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tower, "~> 0.7.5 or ~> 0.8.0"},
      {:swoosh, "~> 1.14"},

      # Optional
      {:hackney, "~> 1.20", optional: true},

      # Dev
      {:blend, "~> 0.4.0", only: :dev},
      {:ex_doc, "~> 0.37.1", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
