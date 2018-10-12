defmodule SearchMetrics.MixProject do
  use Mix.Project

  def project do
    [
      app: :searchmetrics,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [plt_add_apps: [:eex, :wallaby]],
      aliases: aliases()
    ]
  end

  defp aliases do
    [
      test: "test --no-start" #(2)
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :elixir_google_spreadsheets],
      mod: {SearchMetrics, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:distillery, "~> 2.0", runtime: false},
      {:wallaby, "~> 0.20.0", [runtime: true]},
      {:floki, "~> 0.20.4"},
      {:elixir_google_spreadsheets, "~> 0.1.9"}
    ]
  end
end
