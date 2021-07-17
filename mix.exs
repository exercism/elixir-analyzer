defmodule ElixirAnalyzer.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_analyzer,
      version: "0.1.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      preferred_cli_env: [
        # run dialyzer in test env so that files in test/support also get checked
        dialyzer: :test
      ],
      dialyzer: [
        plt_core_path: "priv/plts",
        plt_file: {:no_warn, "priv/plts/eventstore.plt"}
        # important note:
        # The option ignore_warnings only works when running `mix dialyzer` (from `dialyxir`),
        # it DOES NOT work when ElixirLS runs dialyzer.
        # When using ElixirLS with VSCode reporting dialyzer warnings, obscuring code feedback.
        # So to ensure the best experience for devs using VSCode, try to disable dialyzer
        # warnings using the `@dialyzer` module attribute
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :ex_unit]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp escript do
    [main_module: ElixirAnalyzer.CLI]
  end
end
