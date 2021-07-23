defmodule ElixirAnalyzer.ExerciseTest.AssertCall.ModuleTrackingTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.AssertCall.ModuleTracking

  test_exercise_analysis "Calling Elixir.Mix.Utils.read_path/1",
    comments_include: [
      "found a call to Elixir.Mix.Utils.read_path/1"
    ] do
    [
      defmodule AssertCallVerification do
        def function() do
          {:ok, file} = Elixir.Mix.Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix.Utils

        def function() do
          {:ok, file} = read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix.{CLI, Config, Utils}

        def function() do
          {:ok, file} = read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix

        def function() do
          {:ok, file} = Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.{Mix, Hex.Utils}

        def function() do
          {:ok, file} = Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix.Utils, only: :functions

        def function() do
          {:ok, file} = read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix.Utils, only: [read_path: 1]

        def function() do
          {:ok, file} = read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix.Utils, only: [print_tree: 3]

        def function() do
          {:ok, file} = Elixir.Mix.Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix.Utils, except: [print_tree: 3]

        def function() do
          {:ok, file} = read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix.Utils, except: [read_path: 0, read_path: 2, read_path: 3]

        def function() do
          {:ok, file} = read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        alias Elixir.Mix.Utils

        def function() do
          {:ok, file} = Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        alias Elixir.Mix

        def function() do
          {:ok, file} = Mix.Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        alias Elixir.{Hex.API, Mix, Mix.CLI}

        def function() do
          {:ok, file} = Mix.Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        alias Elixir.{Mix, Hex, Hex.Config}

        def function() do
          {:ok, file} = Mix.Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        alias Elixir

        def function() do
          {:ok, file} = Elixir.Mix.Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        alias Elixir.Mix.Utils, as: U

        def function() do
          {:ok, file} = U.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        alias Elixir.Mix, as: M

        def function() do
          {:ok, file} = M.Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        alias Elixir, as: E

        def function() do
          {:ok, file} = E.Mix.Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        alias Elixir.Mix.Utils, as: U

        def function() do
          {:ok, file} = Elixir.Mix.Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix.Utils, only: :functions

        def function() do
          {:ok, file} = read_path("mix.exs")
        end
      end
    ]
  end

  test_exercise_analysis "Not calling Elixir.Mix.Utils.read_path/1",
    comments_include: [
      "didn't find any call to Elixir.Mix.Utils.read_path/1"
    ] do
    [
      defmodule AssertCallVerification do
        def function() do
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix.Utils, only: :macros

        def function() do
          {:ok, file} = read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        def function() do
          {:ok, file} = Mix.Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        def function() do
          {:ok, file} = Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        def function() do
          {:ok, file} = read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix.{CLI, Config}

        def function() do
          {:ok, file} = read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        def function() do
          {:ok, file} = Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix.Utils, only: [print_tree: 3, command_to_module: 2]

        def function() do
          {:ok, file} = read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix.Utils, only: [read_path: 0, read_path: 2, read_path: 3]

        def function() do
          {:ok, file} = read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix.Utils, except: [read_path: 1]

        def function() do
          {:ok, file} = read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        import Elixir.Mix.Utils, only: [read_path: 1]
        import Elixir.Mix.Utils, except: [read_path: 1]

        def function() do
          {:ok, file} = read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        def function() do
          import Elixir.Mix.Utils
        end

        {:ok, file} = read_path("mix.exs")
      end,
      defmodule AssertCallVerification do
        def function() do
          import Elixir.Mix
        end

        {:ok, file} = Utils.read_path("mix.exs")
      end,
      defmodule AssertCallVerification do
        alias Elixir.Mix

        def function() do
          {:ok, file} = Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        alias Elixir.Mix

        def function() do
          {:ok, file} = Utils.read_path("mix.exs")
        end
      end,
      defmodule AssertCallVerification do
        def function() do
          alias Elixir.{Hex.API, Mix, Mix.CLI}
        end

        {:ok, file} = Mix.Utils.read_path("mix.exs")
      end,
      defmodule AssertCallVerification do
        def function() do
          alias Elixir.{Mix, Hex, Hex.Config}
        end

        {:ok, file} = Mix.Utils.read_path("mix.exs")
      end,
      defmodule AssertCallVerification do
        def function() do
          {:ok, file} = U.read_path("mix.exs")
        end

        alias Elixir.Mix.Utils, as: U
      end,
      defmodule AssertCallVerification do
        def function() do
          alias Elixir.Mix, as: M
        end

        {:ok, file} = M.Utils.read_path("mix.exs")
      end,
      defmodule AssertCallVerification do
        def function() do
          {:ok, file} = E.Mix.Utils.read_path("mix.exs")
          alias Elixir, as: E
        end
      end
    ]
  end

  test_exercise_analysis "Calling non standard library function using import",
    comments_include: [
      "found a call to MyModule.Custom.my_function/0"
    ] do
    [
      defmodule AssertCallVerification do
        import MyModule
        Custom.my_function()
      end,
      defmodule AssertCallVerification do
        import MyModule.Custom, only: [my_function: 0]
        my_function()
      end
    ]
  end

  test_exercise_analysis "Failing to call non standard library function using import",
    comments_include: [
      "didn't find any call to MyModule.Custom.my_function/0"
    ] do
    [
      defmodule AssertCallVerification do
        import MyModule.Custom
        my_function()
      end,
      defmodule AssertCallVerification do
        import MyModule.Custom, only: :functions
        my_function()
      end,
      defmodule AssertCallVerification do
        import MyModule.Custom, only: :macros
        my_function()
      end,
      defmodule AssertCallVerification do
        import MyModule.Custom, except: [my_function: 0]
        my_function()
      end,
      defmodule AssertCallVerification do
        import MyModule.Custom, except: [her_function: 0]
        my_function()
      end,
      defmodule AssertCallVerification do
        import MyModule.Custom, only: [her_function: 0]
        my_function()
      end
    ]
  end
end
