# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# third-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :elixir_analyzer, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:elixir_analyzer, :key)
#
# You can also configure a third-party app:
#
#     config :logger, level: :info
#

config :elixir_analyzer,
  exercise_config: %{
    "two-fer" => %{
      code_file: "two_fer.ex",
      analyzer_module: ElixirAnalyzer.TestSuite.TwoFer
    },
    "pacman-rules" => %{
      code_file: "rules.ex",
      analyzer_module: ElixirAnalyzer.TestSuite.PacmanRules
    },
    "take-a-number" => %{
      code_file: "take_a_number.ex",
      analyzer_module: ElixirAnalyzer.TestSuite.TakeANumber
    }
  }

config :logger, :console,
  metadata: [:input_path, :output_path, :path, :code_path, :analysis_module, :code_file_path]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).

import_config "#{Mix.env()}.exs"
