defmodule ElixirAnalyzer.Support.AnalyzerVerification.Feature do
  @moduledoc """
  This is an exercise analyzer extension module to test the feature macro
  """

  use ElixirAnalyzer.ExerciseTest

  feature "calc/1 must call some other function of any arity" do
    type :essential
    # sic! even though the form looks like it requires exactly 1 argument
    comment "calc/1 must call some other function of any arity"

    form do
      def calc(n) do
        arg1 = _ignore(n, 1)
        n * _ignore(arg1)
      end
    end
  end

  feature "strict_calc/1 must call some other function with one arguments named arg1" do
    type :essential
    comment "strict_calc/1 must call some other function with one arguments named arg1"

    form do
      def strict_calc(n) do
        arg1 = _shallow_ignore(n, 1)
        n * _shallow_ignore(arg1)
      end
    end
  end

  feature "there must be any module attribute with any value and any name" do
    type :essential
    find :all
    comment "there must be any module attribute with any value and any name"

    form do
      @_ignore
    end
  end

  feature "there must be any module attribute with the value 42, and any module attribute with the name 'answer'" do
    type :essential
    find :all

    comment "there must be any module attribute with the value 42, and any module attribute with the name 'answer'"

    form do
      @_shallow_ignore 42
    end

    form do
      @answer _ignore
    end
  end
end
