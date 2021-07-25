defmodule ElixirAnalyzer.Support.AnalyzerVerification.Feature.StringInterpolation do
  @moduledoc """
  This is an exercise analyzer extension module to test feature specifically on string interpolation
  """

  use ElixirAnalyzer.ExerciseTest

  feature "normal string" do
    type :essential
    comment "normal string"

    form do
      "hello you"
    end
  end

  feature "string with newline in the middle" do
    type :essential
    comment "string with newline in the middle"

    form do
      "hello\nyou"
    end
  end

  feature "string with interpolation" do
    type :essential
    comment "string with interpolation"

    form do
      "hello #{name}"
    end
  end

  feature "string with interpolation and newline at the end" do
    type :essential
    comment "string with interpolation and newline at the end"

    form do
      "hello #{name}\n"
    end
  end

  feature "string with interpolation and newline in the middle" do
    type :essential
    comment "string with interpolation and newline in the middle"

    form do
      "hello\n#{name}"
    end
  end

  feature "Multiline complex string inperpolation" do
    type :essential
    comment "Multiline complex string inperpolation"

    form do
      """
      hello #{name.last}
      how are you?
      """
    end
  end

  feature "multiline string interpolation must match exactly" do
    type :essential
    comment "multiline string interpolation doesn't match exactly"

    form do
      """
      🏁 #{race.title} 🏁
      Status: #{Race.display_status(race)}
      Distance: #{Race.display_distance(race)}
      Contestants:
      """
    end
  end
end
