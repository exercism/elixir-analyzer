defmodule ElixirAnalyzer.TestSuite.TwoFer do
  @moduledoc """
  This is an exercise analyzer extension module for the exercise TwoFer

  Written by: Tim Austin (@neenjaw) tim@neenjaw.com
  """

  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTest

  #
  # Two-fer feature tests
  #

  feature "has spec" do
    # status :skip
    find :all
    type :actionable
    comment Constants.solution_use_specification()

    form do
      @spec _ignore
    end
  end

  feature "has wrong spec" do
    # status      :skip
    find :all
    type :actionable
    suppress_if "has spec", :fail
    comment Constants.two_fer_wrong_specification()

    form do
      @spec two_fer(String.t()) :: String.t()
    end
  end

  feature "has default parameter" do
    # status :skip
    find :any
    type :actionable
    comment Constants.two_fer_use_default_parameter()

    # function header
    form do
      def two_fer(_ignore \\ "you")
    end

    # function without a guard and with a do block
    form do
      def two_fer(_ignore \\ "you") do
        _ignore
      end
    end

    # function with do block
    form do
      def two_fer(_ignore \\ "you") when _ignore do
        _ignore
      end
    end
  end

  feature "uses function header" do
    # status   :skip
    find :none
    type :actionable
    comment Constants.two_fer_use_of_function_header()

    form do
      def two_fer(_ignore \\ "you")
    end
  end

  feature "uses guards" do
    # status :skip
    find :any
    type :actionable
    comment Constants.two_fer_use_guards()

    form do
      is_binary(_ignore)
    end

    form do
      is_bitstring(_ignore)
    end
  end

  feature "uses function level guard" do
    # status      :skip
    find :any
    type :actionable
    suppress_if "uses guards", :fail
    comment Constants.two_fer_use_function_level_guard()

    form do
      def two_fer(_ignore \\ "you") when is_binary(_ignore), _ignore
    end

    form do
      def two_fer(_ignore) when is_binary(_ignore), _ignore
    end

    form do
      def two_fer(_ignore \\ "you") when is_bitstring(_ignore), _ignore
    end

    form do
      def two_fer(_ignore) when is_bitstring(_ignore), _ignore
    end
  end

  feature "uses auxiliary functions" do
    # status   :skip
    find :none
    type :actionable
    comment Constants.two_fer_use_of_aux_functions()

    form do
      defp _ignore(_ignore), do: _ignore
    end
  end

  feature "uses string interpolation" do
    # status :skip
    find :any
    type :actionable
    comment Constants.two_fer_use_string_interpolation()

    form do
      "One for #{_ignore}, one for me."
    end
  end

  feature "raises function clause error" do
    # status :skip
    find :none
    type :actionable
    comment Constants.solution_raise_fn_clause_error()

    form do
      raise FunctionClauseError
    end
  end

  feature "first level @moduledoc recommended" do
    # status :skip
    find :all
    type :informative
    comment Constants.solution_use_moduledoc()
    depth 1

    form do
      @moduledoc _ignore
    end
  end
end
