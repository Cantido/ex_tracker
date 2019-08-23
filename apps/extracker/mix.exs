defmodule Extracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :extracker,
      version: "0.0.1",
      elixir: "~> 1.6",
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
      mod: {Extracker.Application, []}
    ]
  end

  defp deps do
    [
      {:ex_bencode, "~> 2.0"},
      {:benchee, "~> 1.0", only: :dev},
      {:stream_data, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
