defmodule ExtrackerPlug.MixProject do
  use Mix.Project

  def project do
    [
      app: :extracker_plug,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ExtrackerPlug.Application, []}
    ]
  end

  defp deps do
    [
      {:cowboy, "~> 2.1"},
      {:plug, "~> 1.5.0-rc.1"}
    ]
  end
end
