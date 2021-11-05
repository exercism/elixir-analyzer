defmodule ElixirAnalyzer.CommentsTest do
  use ExUnit.Case

  alias ElixirAnalyzer.Comment

  @types ~w(essential actionable informative celebratory)a

  describe "supported_type?/1" do
    for type <- @types do
      test "#{type} passes" do
        assert Comment.supported_type?(unquote(type))
      end
    end

    test "other atoms are not supported" do
      refute Comment.supported_type?(:super_actionable)
    end
  end

  describe "supported_types/0" do
    test "lists all types" do
      assert Comment.supported_types() == @types
    end
  end
end
