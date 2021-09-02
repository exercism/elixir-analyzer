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
    # concept exercises
    "bird-count" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.BirdCount
    },
    "boutique-suggestions" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.BoutiqueSuggestions
    },
    "chessboard" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.Chessboard
    },
    "file-sniffer" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.FileSniffer
    },
    "freelancer-rates" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.FreelancerRates
    },
    "guessing-game" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.GuessingGame
    },
    "german-sysadmin" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.GermanSysadmin
    },
    "high-score" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.HighScore
    },
    "lasagna" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.Lasagna
    },
    "name-badge" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.NameBadge
    },
    "need-for-speed" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.NeedForSpeed
    },
    "newsletter" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.Newsletter
    },
    "pacman-rules" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.PacmanRules
    },
    "rpg-character-sheet" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.RpgCharacterSheet
    },
    "rpn-calculator-inspection" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.RpnCalculatorInspection
    },
    "rpn-calculator-output" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.RpnCalculatorOutput
    },
    "take-a-number" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.TakeANumber
    },

    # practice exercises
    "accumulate" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.Accumulate
    },
    "list-ops" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.ListOps
    },
    "square-root" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.SquareRoot
    },
    "two-fer" => %{
      analyzer_module: ElixirAnalyzer.TestSuite.TwoFer
    }
  }

config :logger, :console,
  format: {ElixirAnalyzer.LogFormatter, :format},
  metadata: [
    :input_path,
    :output_path,
    :path,
    :code_path,
    :analysis_module,
    :code_file_path,
    :error_message,
    :file_name
  ]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).

import_config "#{Mix.env()}.exs"
