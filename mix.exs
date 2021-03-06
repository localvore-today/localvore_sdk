defmodule LocalvoreSdk.Mixfile do
  use Mix.Project

  def project do
    [
      app: :localvore_sdk,
      version: "0.3.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:httpoison, "~> 0.11"},
      {:poison, "~> 3.1"}
    ]
  end
end
