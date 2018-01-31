defmodule ExtrackerPlug.MixProject do
  use Mix.Project

  def project do
    [
      app: :extracker_server,
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
      mod: {ExtrackerServer.Application, []}
    ]
  end

  defp deps do
    [
      {:extracker, in_umbrella: true},
      {:cowboy, "~> 1.1"},
      {:plug, "~> 1.4"},
      {:ex_bencode, "~> 2.0"}
    ]
  end
end
