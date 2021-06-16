defmodule ElixirAnalyzer.TestSuite.Accumulate do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Accumulate
  """

  use ElixirAnalyzer.ExerciseTest

  assert_no_call "does not call any Enum functions" do
    type :essential
    called_fn module: Enum, name: :_
    comment ElixirAnalyzer.Constants.accumulate_use_recursion()
  end

  feature "does not alias or import Enum" do
    find :none
    type :essential
    comment ElixirAnalyzer.Constants.accumulate_use_recursion()

    form do
      import Enum
    end

    form do
      import Enum, _ignore
    end

    form do
      alias Enum, as: _ignore
    end
  end

  assert_no_call "does not call any Stream functions" do
    type :essential
    called_fn module: Stream, name: :_
    comment ElixirAnalyzer.Constants.accumulate_use_recursion()
  end

  feature "does not alias or import Stream" do
    find :none
    type :essential
    comment ElixirAnalyzer.Constants.accumulate_use_recursion()

    form do
      import Stream
    end

    form do
      import Stream, _ignore
    end

    form do
      alias Stream, as: _ignore
    end
  end
end
