defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.FunctionCaptureTest do
  use ExUnit.Case

  alias ElixirAnalyzer.ExerciseTest.CommonChecks.FunctionCapture
  alias ElixirAnalyzer.Comment
  alias ElixirAnalyzer.Constants

  @comment %Comment{
    type: :informative,
    comment: Constants.solution_use_function_capture(),
    name: Constants.solution_use_function_capture()
  }

  test "using valid notation for several cases" do
    code =
      quote do
        defmodule Capture do
          import Float, only: [ratio: 1, pow: 2]

          def captured(input) do
            input
            |> Enum.map(&ratio/1)
            |> Enum.map(&Float.round/1)
            |> Enum.map(&:math.sin/1)
            |> Enum.zip_with(input, &pow/2)
            |> Enum.zip_with(input, &Float.ceil/2)
            |> Enum.zip_with(input, &:math.atan2/2)
          end

          def legit(input) do
            input
            |> Enum.reduce([], fn n, acc -> div(acc, n) end)
            |> Enum.reduce([], &div(&2, &1))
            |> Enum.reduce([], fn n, acc -> String.pad_leading(n, acc, "42") end)
            |> Enum.reduce([], &String.pad_leading(&1, &2, "42"))
            |> Enum.map(fn x -> IO.inspect(x, charlists: :as_lists) end)
            |> Enum.map(&IO.inspect(&1, charlists: :as_lists))
          end

          def exceptions(input) do
            input
            |> Enum.map(&<<&1>>)
            |> Enum.map(fn x -> <<x>> end)
            |> Enum.reduce([], fn a, b, c -> {a, b, c} end)
            |> Enum.reduce([], &{&1, &2, &2})
          end

          # https://github.com/exercism/elixir/blob/main/exercises/practice/sgf-parsing/.meta/example.ex
          defmacrop lazy(parser) do
            quote do
              fn string -> unquote(parser).(string) end
            end
          end
        end
      end

    assert FunctionCapture.run(code) == []
  end

  describe "catches fn notation" do
    test "function in scope" do
      code =
        quote do
          defmodule Capture do
            def capture(input) do
              Enum.map(input, fn x -> to_string(x) end)
            end
          end
        end

      comment = %{
        @comment
        | params: %{actual: "fn x -> to_string(x) end", expected: "&to_string/1"}
      }

      assert FunctionCapture.run(code) == [{:fail, comment}]
    end

    test "function with module path" do
      code =
        quote do
          defmodule Capture do
            def capture(input) do
              Enum.map(input, fn x -> Integer.to_string(x) end)
            end
          end
        end

      comment = %{
        @comment
        | params: %{actual: "fn x -> Integer.to_string(x) end", expected: "&Integer.to_string/1"}
      }

      assert FunctionCapture.run(code) == [{:fail, comment}]
    end

    test "function with longer module path" do
      code =
        quote do
          defmodule Capture do
            def capture(input) do
              Enum.map(input, fn x -> Elixir.Integer.to_string(x) end)
            end
          end
        end

      comment = %{
        @comment
        | params: %{
            actual: "fn x -> Elixir.Integer.to_string(x) end",
            expected: "&Elixir.Integer.to_string/1"
          }
      }

      assert FunctionCapture.run(code) == [{:fail, comment}]
    end

    test "Erlang module" do
      code =
        quote do
          defmodule Capture do
            def capture(input) do
              Enum.map(input, fn x -> :math.ceil(x) end)
            end
          end
        end

      comment = %{
        @comment
        | params: %{actual: "fn x -> :math.ceil(x) end", expected: "&:math.ceil/1"}
      }

      assert FunctionCapture.run(code) == [{:fail, comment}]
    end

    test "function in scope, more variables" do
      code =
        quote do
          defmodule Capture do
            def capture(input) do
              Enum.zip_with(input, input, fn x, y, z -> update_in(x, y, z) end)
            end
          end
        end

      comment = %{
        @comment
        | params: %{actual: "fn x, y, z -> update_in(x, y, z) end", expected: "&update_in/3"}
      }

      assert FunctionCapture.run(code) == [{:fail, comment}]
    end

    test "function with module path, more variables" do
      code =
        quote do
          defmodule Capture do
            def capture(input) do
              Enum.zip_with(input, input, fn x, y, z -> Kernel.update_in(x, y, z) end)
            end
          end
        end

      comment = %{
        @comment
        | params: %{
            actual: "fn x, y, z -> Kernel.update_in(x, y, z) end",
            expected: "&Kernel.update_in/3"
          }
      }

      assert FunctionCapture.run(code) == [{:fail, comment}]
    end

    test "Erlang module, more variables" do
      code =
        quote do
          defmodule Capture do
            def capture(input) do
              Enum.map(input, fn a, b, c, d -> :gen_server.multi_call(a, b, c, d) end)
            end
          end
        end

      comment = %{
        @comment
        | params: %{
            actual: "fn a, b, c, d -> :gen_server.multi_call(a, b, c, d) end",
            expected: "&:gen_server.multi_call/4"
          }
      }

      assert FunctionCapture.run(code) == [{:fail, comment}]
    end
  end

  describe "catches & notation" do
    test "function in scope" do
      code =
        quote do
          defmodule Capture do
            def capture(input) do
              Enum.map(input, &to_string(&1))
            end
          end
        end

      comment = %{
        @comment
        | params: %{actual: "&to_string(&1)", expected: "&to_string/1"}
      }

      assert FunctionCapture.run(code) == [{:fail, comment}]
    end

    test "function with module path" do
      code =
        quote do
          defmodule Capture do
            def capture(input) do
              Enum.map(input, &Integer.to_string(&1))
            end
          end
        end

      comment = %{
        @comment
        | params: %{actual: "&Integer.to_string(&1)", expected: "&Integer.to_string/1"}
      }

      assert FunctionCapture.run(code) == [{:fail, comment}]
    end

    test "function with longer module path" do
      code =
        quote do
          defmodule Capture do
            def capture(input) do
              Enum.map(input, &Elixir.Integer.to_string(&1))
            end
          end
        end

      comment = %{
        @comment
        | params: %{
            actual: "&Elixir.Integer.to_string(&1)",
            expected: "&Elixir.Integer.to_string/1"
          }
      }

      assert FunctionCapture.run(code) == [{:fail, comment}]
    end

    test "Erlang module" do
      code =
        quote do
          defmodule Capture do
            def capture(input) do
              Enum.map(input, &:math.ceil(&1))
            end
          end
        end

      comment = %{
        @comment
        | params: %{actual: "&:math.ceil(&1)", expected: "&:math.ceil/1"}
      }

      assert FunctionCapture.run(code) == [{:fail, comment}]
    end

    test "function in scope, more variables" do
      code =
        quote do
          defmodule Capture do
            def capture(input) do
              Enum.zip_with(input, input, &update_in(&1, &2, &3))
            end
          end
        end

      comment = %{
        @comment
        | params: %{actual: "&update_in(&1, &2, &3)", expected: "&update_in/3"}
      }

      assert FunctionCapture.run(code) == [{:fail, comment}]
    end

    test "function with module path, more variables" do
      code =
        quote do
          defmodule Capture do
            def capture(input) do
              Enum.zip_with(input, input, &Kernel.update_in(&1, &2, &3))
            end
          end
        end

      comment = %{
        @comment
        | params: %{
            actual: "&Kernel.update_in(&1, &2, &3)",
            expected: "&Kernel.update_in/3"
          }
      }

      assert FunctionCapture.run(code) == [{:fail, comment}]
    end

    test "Erlang module, more variables" do
      code =
        quote do
          defmodule Capture do
            def capture(input) do
              Enum.map(input, &:gen_server.multi_call(&1, &2, &3, &4))
            end
          end
        end

      comment = %{
        @comment
        | params: %{
            actual: "&:gen_server.multi_call(&1, &2, &3, &4)",
            expected: "&:gen_server.multi_call/4"
          }
      }

      assert FunctionCapture.run(code) == [{:fail, comment}]
    end
  end
end
