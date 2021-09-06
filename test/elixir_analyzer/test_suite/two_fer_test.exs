defmodule ElixirAnalyzer.TestSuite.TwoFerTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.TwoFer

  test_exercise_analysis "perfect solution",
    comments: [] do
    defmodule TwoFer do
      @moduledoc """
      Two-fer or 2-fer is short for two for one. One for you and one for me.
      """
      @spec two_fer(String.t()) :: String.t()
      def two_fer(name \\ "you") when is_binary(name) do
        "One for #{name}, one for me."
      end
    end
  end

  test_exercise_analysis "missing moduledoc",
    comments: [Constants.solution_use_moduledoc()] do
    defmodule TwoFer do
      @spec two_fer(String.t()) :: String.t()
      def two_fer(name \\ "you") when is_binary(name) do
        "One for #{name}, one for me."
      end
    end
  end

  describe "spec" do
    test_exercise_analysis "correct spec",
      comments_exclude: [
        Constants.solution_use_specification(),
        Constants.two_fer_wrong_specification()
      ] do
      defmodule TwoFer do
        @spec two_fer(String.t()) :: String.t()
        def two_fer(name)
      end
    end

    test_exercise_analysis "refer when wrong spec",
      comments_include: [Constants.two_fer_wrong_specification()] do
      [
        defmodule TwoFer do
          @spec two_fer(binary()) :: binary()
          def two_fer(name)
        end,
        defmodule TwoFer do
          @spec two_fer(bitstring()) :: bitstring()
          def two_fer(name)
        end
      ]
    end

    test_exercise_analysis "info when missing spec",
      comments_include: [Constants.solution_use_specification()] do
      defmodule TwoFer do
        @moduledoc """
        Two-fer or 2-fer is short for two for one. One for you and one for me.
        """
        def two_fer(name \\ "you") when is_binary(name) do
          "One for #{name}, one for me."
        end
      end
    end
  end

  describe "default parameter" do
    test_exercise_analysis "finds the default parameter",
      comments_exclude: [Constants.two_fer_use_default_parameter()] do
      [
        defmodule TwoFer do
          def two_fer(x \\ "you")
        end,
        defmodule TwoFer do
          def two_fer(name \\ "you") do
            "One for #{name}, one for me."
          end
        end
      ]
    end

    test_exercise_analysis "disapprove when not using a default parameter",
      comments_include: [Constants.two_fer_use_default_parameter()] do
      [
        defmodule TwoFer do
          def two_fer(_)
        end,
        defmodule TwoFer do
          def two_fer(name \\ "wrong default value")
        end,
        defmodule TwoFer do
          def two_fer(name) do
            "One for #{name}, one for me."
          end
        end,
        defmodule TwoFer do
          def two_fer(name), do: "One for #{name}, one for me."
        end,
        defmodule TwoFer do
          def two_fer(name) when is_binary(name) do
            "One for #{name}, one for me."
          end
        end,
        defmodule TwoFer do
          def two_fer(name) when is_binary(name), do: "One for #{name}, one for me."
        end
      ]
    end
  end

  describe "function header" do
    test_exercise_analysis "refer when using a function header",
      comments_include: [Constants.two_fer_use_of_function_header()] do
      defmodule TwoFer do
        def two_fer(name \\ "you")
      end
    end
  end

  describe "guards" do
    test_exercise_analysis "usage of is_binary or is_bitstring is required",
      comments_include: [Constants.two_fer_use_guards()] do
      defmodule TwoFer do
        def two_fer(name \\ "you") do
          "One for #{name}, one for me."
        end
      end
    end

    test_exercise_analysis "refer when is_binary or is_bitstring in used outside of the function head",
      comments_include: [Constants.two_fer_use_function_level_guard()] do
      [
        defmodule TwoFer do
          def two_fer(name \\ "you") do
            is_binary(name)
            "One for #{name}, one for me."
          end
        end,
        defmodule TwoFer do
          def two_fer(name \\ "you") do
            if is_bitstring(name) do
              "One for #{name}, one for me."
            else
              raise FunctionClauseError
            end
          end
        end
      ]
    end
  end

  describe "using auxiliary functions" do
    test_exercise_analysis "multiple implementations of two_fer/1 don't count as auxiliary functions",
      comments_exclude: [Constants.two_fer_use_of_aux_functions()] do
      defmodule TwoFer do
        def two_fer("foo") do
          "One for foo, one for me."
        end

        def two_fer(name) do
          "One for #{name}, one for me."
        end
      end
    end

    test_exercise_analysis "refer there are other functions than two_fer/1",
      comments_include: [Constants.two_fer_use_of_aux_functions()] do
      [
        defmodule TwoFer do
          def two_fer(name \\ "you") do
            "One for #{name}, one for me."
          end

          defp foo() do
          end
        end,
        defmodule TwoFer do
          def two_fer(name \\ "you") do
            "One for #{name}, one for me."
          end

          defp foo(), do: nil
        end,
        defmodule TwoFer do
          def two_fer(name \\ "you") do
            "One for #{name}, one for me."
          end

          defp foo(_a), do: nil
        end,
        defmodule TwoFer do
          def two_fer(name \\ "you") do
            "One for #{name}, one for me."
          end

          defp foo(_a, _b), do: nil
        end
      ]
    end
  end

  describe "string interpolation" do
    test_exercise_analysis "doesn't allow string concatenation",
      comments_include: [Constants.two_fer_use_string_interpolation()] do
      defmodule TwoFer do
        def two_fer(name \\ "you") when is_binary(name) do
          "One for " <> name <> ", one for me."
        end
      end
    end
  end

  describe "FunctionClauseError" do
    test_exercise_analysis "doesn't allow raising FunctionClauseError explicitly",
      comments_include: [Constants.solution_raise_fn_clause_error()] do
      defmodule TwoFer do
        def two_fer(name \\ "you") do
          if is_bitstring(name) do
            "One for #{name}, one for me."
          else
            raise FunctionClauseError
          end
        end
      end
    end
  end
end
