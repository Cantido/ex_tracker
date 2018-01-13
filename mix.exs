defmodule Extracker.Mixfile do
  use Mix.Project

  def project do
    [
      app: :extracker,
      version: "0.0.1",
      elixir: "~> 1.1-dev",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      dialyzer: [ flags: ["-Wunmatched_returns", :error_handling, :race_conditions, :underspecs]]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Extracker.Application, []}
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.2"},
      {:httpoison, "~> 1.0"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: :ex_tracker,
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Rosa Richter"],
      licenses: ["GPL-3"],
      links: %{"Github" => "https://github.com/Cantido/ex_tracker"}
    ]
  end
end
