defmodule ExTracker.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      dialyzer: [ flags: ["-Wunmatched_returns", :error_handling, :race_conditions, :underspecs]],

      # Docs
      name: "Extracker",
      source_url: "https://github.com/Cantido/ex_tracker",
      docs: [
        extras: [
          "README.md": [title: "README"]
        ]
      ]
    ]
  end

  defp deps do
    []
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
