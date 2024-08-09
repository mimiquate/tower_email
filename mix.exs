defmodule TowerEmail.MixProject do
  use Mix.Project

  @description "Email reporter for Tower"
  @source_url "https://github.com/mimiquate/tower_email"
  @version "0.1.0"

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
      {:tower, "~> 0.2.0"},
      {:swoosh, "~> 1.14"},

      # Optional
      {:hackney, "~> 1.20", optional: true},

      # Dev
      {:blend, "~> 0.3.0", only: :dev},
      {:ex_doc, "~> 0.34.2", only: :dev, runtime: false}
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
      extras: ["README.md"]
    ]
  end
end
