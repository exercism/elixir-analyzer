defmodule ElixirAnalyzer.LogFormatterTest do
  use ExUnit.Case

  test "formatting a message" do
    assert ElixirAnalyzer.LogFormatter.format(:warn, "hi", {{2021, 12, 4}, {11, 59, 12, 0}}, []) ==
             "# 2021-12-04T11:59:12.000Z [] [warn] hi\n"
  end

  test "formatting failure" do
    assert ElixirAnalyzer.LogFormatter.format(:warn, "hi", :not_a_timestamp, []) ==
             "could not format message: {:warn, \"hi\", :not_a_timestamp, []}\n"
  end
end
