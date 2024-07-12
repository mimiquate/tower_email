defmodule TowerEmail.MixProject do
  use Mix.Project

  def project do
    [
      app: :tower_email,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:tower, github: "mimiquate/tower"},
      {:bamboo, "~> 2.3"}
    ]
  end
end
