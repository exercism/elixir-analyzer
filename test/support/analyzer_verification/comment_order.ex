defmodule ElixirAnalyzer.Support.AnalyzerVerification.CommentOrder do
  @moduledoc """
  This is an exercise analyzer extension module to test the order of comments
  """

  use ElixirAnalyzer.ExerciseTest

  # features are defined in a non-alphabetical, non-importance order

  feature "find :celebratory" do
    type :celebratory
    comment "celebratory"

    form do
      :celebratory
    end
  end

  feature "find :essential" do
    type :essential
    comment "essential"

    form do
      :essential
    end
  end

  feature "find :informative" do
    type :informative
    comment "informative"

    form do
      :informative
    end
  end

  feature "find :actionable" do
    type :actionable
    comment "actionable"

    form do
      :actionable
    end
  end
end
