defmodule ElixirAnalyzer.ExerciseTest.Feature.StringInterpolationTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.Support.AnalyzerVerification.Feature.StringInterpolation

  test_exercise_analysis "normal string",
    comments_exclude: ["normal string", "elixir.general.parsing_error"] do
    [
      ~S"""
      defmodule MyModule do
        def hi(name) do
          "hello you"
        end
      end
      """
    ]
  end

  test_exercise_analysis "string with newline in the middle",
    comments_exclude: ["string with newline in the middle", "elixir.general.parsing_error"] do
    [
      ~S"""
      defmodule MyModule do
        def hi(name) do
          "hello\nyou"
        end
      end
      """
    ]
  end

  test_exercise_analysis "string with interpolation",
    comments_exclude: ["string with interpolation", "elixir.general.parsing_error"] do
    [
      ~S"""
      defmodule MyModule do
        def hi(name) do
          "hello #{name}"
        end
      end
      """
    ]
  end

  test_exercise_analysis "string with interpolation and newline at the end",
    comments_exclude: [
      "string with interpolation and newline at the end",
      "elixir.general.parsing_error"
    ] do
    [
      ~S"""
      defmodule MyModule do
        def hi(name) do
          "hello #{name}\n"
        end
      end
      """
    ]
  end

  test_exercise_analysis "string with interpolation and newline in the middle",
    comments_exclude: [
      "string with interpolation and newline in the middle",
      "elixir.general.parsing_error"
    ] do
    [
      ~S"""
      defmodule MyModule do
        def hi(name) do
          "hello\n#{name}"
        end
      end
      """
    ]
  end

  test_exercise_analysis "Multiline complex string interpolation",
    comments_exclude: ["Multiline complex string interpolation", "elixir.general.parsing_error"] do
    [
      ~S'''
      defmodule MyModule do
        def hi(name) do
          """
          hello #{name.last}
          how are you?
          """
        end
      end
      '''
    ]
  end

  test_exercise_analysis "Multiline string interpolation must match exactly",
    comments_exclude: [
      "multiline string interpolation doesn't match exactly",
      "elixir.general.parsing_error"
    ] do
    [
      ~S'''
      defmodule MyModule do
      def start(race)

      IO.puts("""
      🏁 #{race.title} 🏁
      Status: #{Race.display_status(race)}
      Distance: #{Race.display_distance(race)}
      Contestants:
      """)
      end
      '''
    ]
  end
end
