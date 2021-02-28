defmodule ElixirAnalyzer.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_analyzer,
      version: "0.1.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
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
    [{:jason, "~> 1.2"}]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp escript do
    [main_module: ElixirAnalyzer.CLI]
  end
end
