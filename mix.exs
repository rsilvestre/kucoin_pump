defmodule KucoinPump.MixProject do
  use Mix.Project

  def project do
    [
      app: :kucoin_pump,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {KucoinPump.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:distillery, "~> 2.1"},
      {:ecto_sql, "~> 3.12"},
      {:httpoison, "~> 2.2"},
      {:jason, "~> 1.4"},
      {:matrix, github: "fabio-t/elixir-matrix", branch: "master"},
      {:postgrex, "~> 0.20"},
      {:telegram, github: "visciang/telegram", tag: "0.22.4"},
      # {:timex, "~> 0.19.2"},
      {:type_check, "~> 0.13"},
      {:tz, "~> 0.28"},
      {:websockex, "~> 0.4"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
