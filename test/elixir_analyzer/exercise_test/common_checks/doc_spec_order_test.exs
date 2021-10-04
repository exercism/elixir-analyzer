defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.DocSpecOrderTest do
  use ExUnit.Case
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.ExerciseTest.CommonChecks.DocSpecOrder

  test "wrong order" do
    ast =
      quote do
        defmodule Test do
          @spec x()
          @doc ""
          def x()
        end
      end

    assert DocSpecOrder.run(ast) == [
             {:fail,
              %Comment{
                type: :informative,
                name: Constants.solution_doc_spec_order(),
                comment: Constants.solution_doc_spec_order()
              }}
           ]
  end
end
