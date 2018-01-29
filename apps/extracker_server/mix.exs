defmodule ExtrackerServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :extracker_server,
      version: "0.0.1",
      elixir: "~> 1.5",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
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
      {:cowboy, "~> 2.2"},
      {:httpotion, "~> 3.0.2"},
      {:ex_bencode, "~> 2.0"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
