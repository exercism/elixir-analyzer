defmodule ElixirAnalyzer.Support.AnalyzerVerification.Feature.Pipes do
  @moduledoc """
  This is an exercise analyzer extension module to test feature specifically on pipes 
  """

  use ElixirAnalyzer.ExerciseTest

  feature "function with one parameter" do
    type :essential
    comment "not one parameter"

    form do
      foo(_ignore)
    end
  end

  feature "function with three parameter" do
    type :essential
    comment "not three parameter"

    form do
      foo(_ignore, _ignore, _ignore)
    end
  end

  feature "function with one piped parameter" do
    type :essential
    comment "not one piped parameter"

    form do
      _ignore |> foo()
    end
  end

  feature "function with one piped parameter (no parens)" do
    type :essential
    comment "not one piped parameter (no parens)"

    form do
      _ignore |> foo
    end
  end

  feature "function with three parameters with one piped" do
    type :essential
    comment "not three parameters with one piped"

    form do
      _ignore |> foo(_ignore, _ignore)
    end
  end
end
