defmodule ElixirAnalyzer.TestSuite.BirdCount do
  @dialyzer generated: true
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Bird Count
  """

  use ElixirAnalyzer.ExerciseTest

  assert_no_call "does not call any Enum functions" do
    type :essential
    called_fn module: Enum, name: :_
    comment ElixirAnalyzer.Constants.bird_count_use_recursion()
  end

  feature "does not alias or import Enum" do
    find :none
    type :essential
    comment ElixirAnalyzer.Constants.bird_count_use_recursion()

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
    comment ElixirAnalyzer.Constants.bird_count_use_recursion()
  end

  feature "does not alias or import Stream" do
    find :none
    type :essential
    comment ElixirAnalyzer.Constants.bird_count_use_recursion()

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

  assert_no_call "does not call any List functions" do
    type :essential
    called_fn module: List, name: :_
    comment ElixirAnalyzer.Constants.bird_count_use_recursion()
  end

  feature "does not alias or import List" do
    find :none
    type :essential
    comment ElixirAnalyzer.Constants.bird_count_use_recursion()

    form do
      import List
    end

    form do
      import List, _ignore
    end

    form do
      alias List, as: _ignore
    end
  end

  feature "doesn't use list comprehensions" do
    find :none
    type :essential
    comment ElixirAnalyzer.Constants.bird_count_use_recursion()

    form do
      for _ignore <- _ignore do
        _ignore
      end
    end

    form do
      for _ignore <- _ignore, _ignore do
        _ignore
      end
    end

    form do
      for _ignore <- _ignore, _ignore, into: _ignore do
        _ignore
      end
    end
  end
end
