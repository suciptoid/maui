defmodule Maui.MixProject do
  use Mix.Project

  def project do
    [
      app: :maui,
      version: "1.0.0-alpha.6",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix_live_view, "~> 1.1.0"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: :maui,
      description: "A Phoenix LiveView UI toolkit",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/suciptoid/maui"},
      maintainers: ["Sucipto"],
      files: ~w(
        assets/js assets/css lib priv mix.exs package.json README.md
      )
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["esbuild.install --if-missing"],
      "assets.build": ["cmd --cd assets npm ci", "esbuild main", "esbuild module"],
      build: ["assets.build", "hex.build"],
      publish: ["build", "hex.publish"],
      dev: ["esbuild module --watch"]
    ]
  end
end
