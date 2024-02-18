defmodule ElixirAnalyzer.TestSuite.HighScore do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise High Score
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  feature "uses the module attribute in add_player function head" do
    find :any
    type :actionable
    comment Constants.high_score_use_default_argument_with_module_attribute()

    form do
      def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
        _ignore
      end
    end

    form do
      def add_player(_ignore, _ignore, _ignore \\ @_ignore)
    end

    form do
      def add_player(_ignore, _ignore, _ignore \\ @_ignore) when _ignore do
        _ignore
      end
    end

    form do
      def add_player(_ignore, _ignore, _ignore \\ @_ignore) when _ignore
    end

    form do
      defdelegate add_player(_ignore, _ignore, _ignore \\ @_ignore), _ignore
    end
  end

  feature "uses a module attribute to define the initial score" do
    find :any
    type :essential
    comment Constants.high_score_use_module_attribute()

    form do
      @_shallow_ignore 0
    end
  end

  assert_call "uses the module attribute in reset_score" do
    type :essential
    comment Constants.high_score_use_module_attribute()
    calling_fn module: HighScore, name: :reset_score
    called_fn name: :@
    suppress_if "uses add_player in reset_score", :pass
  end

  assert_call "uses add_player in reset_score" do
    type :essential
    comment Constants.high_score_use_module_attribute()
    calling_fn module: HighScore, name: :reset_score
    called_fn name: :add_player
    suppress_if "uses the module attribute in reset_score", :pass
  end

  assert_call "uses Map.update/4 in update_score" do
    type :actionable
    comment Constants.high_score_use_map_update()
    calling_fn module: HighScore, name: :update_score
    called_fn module: Map, name: :update
  end
end
