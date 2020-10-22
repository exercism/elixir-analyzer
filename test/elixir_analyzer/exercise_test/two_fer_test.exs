defmodule ElixirAnalyzer.ExerciseTest.TwoFerTest do
  use ExUnit.Case

  alias ElixirAnalyzer.ExerciseTest.TwoFer
  alias ElixirAnalyzer.{Submission, Constants}

  test_cases = [
    %{
      name: "missing moduledoc",
      status: :approve,
      comments: [Constants.solution_use_moduledoc()],
      code:
        quote do
          defmodule TwoFer do
            @spec two_fer(String.t()) :: String.t()
            def two_fer(name \\ "you") when is_binary(name) do
              "One for #{name}, one for me"
            end
          end
        end
    },
    %{
      name: "wrong spec",
      status: :refer,
      comments: [Constants.two_fer_wrong_specification()],
      code: [
        quote do
          defmodule TwoFer do
            @moduledoc """
            Two-fer or 2-fer is short for two for one. One for you and one for me.
            """
            @spec two_fer(binary()) :: binary()
            def two_fer(name \\ "you") when is_binary(name) do
              "One for #{name}, one for me"
            end
          end
        end,
        quote do
          defmodule TwoFer do
            @moduledoc """
            Two-fer or 2-fer is short for two for one. One for you and one for me.
            """
            @spec two_fer(bitstring()) :: bitstring()
            def two_fer(name \\ "you") when is_binary(name) do
              "One for #{name}, one for me"
            end
          end
        end
      ]
    }
  ]

  Enum.map(test_cases, fn test_case ->
    test_case.code
    |> List.wrap()
    |> Enum.with_index()
    |> Enum.map(fn {code, index} ->
      test "#{test_case.name} - code sample #{index + 1}" do
        result = TwoFer.analyze(empty_submission(), unquote(Macro.to_string(code)))
        assert result.status == unquote(test_case.status)
        assert result.comments == unquote(test_case.comments)
      end
    end)
  end)

  defp empty_submission() do
    %Submission{
      code_file: "",
      code_path: "",
      path: "",
      analysis_module: ""
    }
  end
end
