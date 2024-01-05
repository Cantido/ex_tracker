# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

defmodule Extracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :extracker,
      description: "A BitTorrent tracker backed by Redis",
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      homepage_url: "https://github.com/Cantido/extracker",
      source_url: "https://github.com/Cantido/extracker"
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Extracker.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package() do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/Cantido/extracker",
        "Sponsor" => "https://liberapay.org/rosa"
      }
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bento, "~> 1.0"},
      {:bandit, "~> 1.1.2"},
      {:castore, ">= 0.0.0"},
      {:credo, "~> 1.7.0", only: :dev, runtime: false},
      {:doctor, "~> 0.21.0", only: :dev},
      {:ex_check, "~> 0.15.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:hex_licenses, "> 0.0.0", only: :dev, runtime: false},
      {:poison, "~> 2.0", override: true},
      {:redix, "~> 1.1"},
      {:sobelow, "~> 0.8", only: :dev},
      {:telemetry, "~> 1.0"},
      {:vapor, "~> 0.10"}
    ]
  end
end
