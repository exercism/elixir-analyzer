defmodule ElixirAnalyzer.ExerciseTest.TwoFer do
  @moduledoc false

  use ElixirAnalyzer.ExerciseTest

  # these are all the tests need to pass for approval if no
  # failing tests that trigger a disapproval, defaults to []
  # if unspecified.
  @tests_needed_to_approve [
    "has default parameter",
    "has guard",
    "uses string interpolation",
    "raises function clause error",
  ]

  # has type specification
  feature "has spec" do
    # status :skip
    message("elixir.two_fer.no_specification")
    severity(:info)
    match(:all)

    form do
      @spec two_fer(String.t()) :: String.t()
    end
  end

  # has function header with default parameter
  feature "has default parameter" do
    # status :skip
    message("elixir.two_fer.no_default_param")
    severity(:info)
    match(:all)

    form do
      def two_fer(_ignore \\ "you")
    end
  end

  # function clauses use guards
  feature "has guard" do
    # status :skip
    message("elixir.two_fer.no_guards")
    severity(:disapprove)
    match(:any)

    form do
      def two_fer(_ignore) when is_binary(_ignore), do: _ignore
      def two_fer(_ignore), do: _ignore
    end

    form do
      def two_fer(_ignore) do
        case _ignore do
          _ignore when is_binary(_ignore) -> _ignore
          _ -> _ignore
        end
      end
    end
  end

  # string interpolation used
  feature "uses string interpolation" do
    # status :skip
    message("elixir.two_fer.use_string_interpolation")
    severity(:disapprove)
    match(:any)

    form do
      "One for #{name}, one for me"
    end
  end

  feature "raises function clause error" do
    # status :skip
    message("elixir.two_fer.use_function_to_catch_bad_argument")
    severity(:disapprove)
    match(:all)

    form do
      raise FunctionClauseError
    end
  end

  feature "first level @moduledoc recomended" do
    # status :skip
    message("elixir.solution.missing_module_doc")
    severity(:info)
    match(:all)
    depth(1)

    form do
      @moduledoc _ignore
    end
  end
end
