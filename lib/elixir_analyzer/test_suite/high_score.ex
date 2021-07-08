defmodule ElixirAnalyzer.TestSuite.HighScore do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Bird Count
  """

  use ElixirAnalyzer.ExerciseTest

  feature "uses a default argument" do
    find :any
    type :actionable
    comment ElixirAnalyzer.Constants.high_score_use_default_argument_with_module_attribute()

    form do
      def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
        _ignore
      end
    end
  end

  feature "uses a module attribute to define the initial score" do
    find :any
    type :essential
    comment ElixirAnalyzer.Constants.high_score_use_module_attribute()

    form do
      @_shallow_ignore 0
    end
  end

  feature "uses the module attribute in add_player function head" do
    find :any
    type :essential
    suppress_if "uses a default argument", :fail
    comment ElixirAnalyzer.Constants.high_score_use_module_attribute()

    form do
      def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
        _ignore
      end
    end
  end

  assert_call "uses the module attribute in reset_score" do
    type :essential
    comment ElixirAnalyzer.Constants.high_score_use_module_attribute()
    calling_fn module: HighScore, name: :reset_score
    called_fn name: :@
  end
end
