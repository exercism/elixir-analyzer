defmodule ElixirAnalyzer.TestSuite.RpnCalculatorOutputTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.RpnCalculatorOutput

  test_exercise_analysis "example solution",
    comments: [] do
    [
      defmodule RPNCalculator.Output do
        def write(resource, filename, equation) do
          {:ok, file} = resource.open(filename)

          try do
            IO.write(file, equation)
          rescue
            _ -> {:error, "Unable to write to resource"}
          else
            :ok -> {:ok, equation}
          after
            resource.close(file)
          end
        end
      end,
      defmodule RPNCalculator.Output do
        def write(my_resource, my_filename, my_equation) do
          {:ok, file} = my_resource.open(my_filename)

          try do
            IO.write(file, my_equation)
          rescue
            _ -> {:error, "Unable to write to resource"}
          else
            :ok -> {:ok, my_equation}
          after
            my_resource.close(file)
          end
        end
      end,
      defmodule RPNCalculator.Output do
        def write(resource, filename, equation) do
          1
          2
          {:ok, file} = resource.open(filename)
          4

          try do
            :ok
            IO.write(file, equation)
          rescue
            _ -> {:error, "Unable to write to resource"}
            _ -> :unreachable
          else
            :foo -> :bar
            :ok -> {:ok, equation}
            :error -> :error
          after
            :hi
            resource.close(file)
            :bye
          end
        end
      end
    ]
  end

  test_exercise_analysis "does not contain all of try-rescue-else-after",
    comments_include: [Constants.rpn_calculator_output_try_rescue_else_after()] do
    [
      defmodule RPNCalculator.Output do
        def write(resource, filename, equation) do
          {:ok, file} = resource.open(filename)

          try do
            IO.write(file, equation)
          rescue
            _ -> {:error, "Unable to write to resource"}
          else
            :ok -> result = {:ok, equation}
          end

          resource.close(file)
          result
        end
      end,
      defmodule RPNCalculator.Output do
        def write(resource, filename, equation) do
          {:ok, file} = resource.open(filename)

          try do
            IO.write(file, equation)
          rescue
            _ -> {:error, "Unable to write to resource"}
          after
            resource.close(file)
          end

          {:ok, equation}
        end
      end,
      defmodule RPNCalculator.Output do
        def write(resource, filename, equation) do
          {:ok, file} = resource.open(filename)

          with :ok <- IO.write(file, equation) do
            result = {:ok, equation}
          else
            _ -> {:error, "Unable to write to resource"}
          end

          resource.close(file)
          result
        end
      end,
      defmodule RPNCalculator.Output do
        def write(resource, filename, equation) do
          {:ok, file} = resource.open(filename)

          try do
            IO.write(file, equation)
          rescue
            _ -> {:error, "Unable to write to resource"}
          end

          resource.close(file)
          {:ok, equation}
        end
      end
    ]
  end

  test_exercise_analysis "open in try",
    comments_include: [Constants.rpn_calculator_output_open_before_try()] do
    defmodule RPNCalculator.Output do
      def write(resource, filename, equation) do
        try do
          {:ok, file} = resource.open(filename)
          IO.write(file, equation)
        rescue
          _ -> {:error, "Unable to write to resource"}
        else
          :ok -> {:ok, equation}
        after
          resource.close(file)
        end
      end
    end
  end

  test_exercise_analysis "write before try",
    comments: [Constants.rpn_calculator_output_write_in_try()] do
    [
      defmodule RPNCalculator.Output do
        def write(resource, filename, equation) do
          {:ok, file} = resource.open(filename)
          IO.write(file, equation)

          try do
            :ok
          rescue
            _ -> {:error, "Unable to write to resource"}
          else
            :ok -> {:ok, equation}
          after
            resource.close(file)
          end
        end
      end,
      defmodule RPNCalculator.Output do
        def write(resource, filename, equation) do
          {:ok, file} = resource.open(filename)
          IO.write(file, equation)
          :break

          try do
            :ok
            :lol
          rescue
            _ -> {:error, "Unable to write to resource"}
          else
            :ok -> {:ok, equation}
          after
            resource.close(file)
          end
        end
      end
    ]
  end

  test_exercise_analysis "output not in else",
    comments_include: [Constants.rpn_calculator_output_output_in_else()] do
    defmodule RPNCalculator.Output do
      def write(resource, filename, equation) do
        {:ok, file} = resource.open(filename)

        result =
          try do
            IO.write(file, equation)
          rescue
            error -> error
          after
            resource.close(file)
          end

        case result do
          :ok -> {:ok, equation}
          _ -> {:error, "Unable to write to resource"}
        end
      end
    end
  end

  test_exercise_analysis "close after after",
    comments_include: [Constants.rpn_calculator_output_close_in_after()] do
    defmodule RPNCalculator.Output do
      def write(resource, filename, equation) do
        {:ok, file} = resource.open(filename)

        try do
          IO.write(file, equation)
        rescue
          _ -> {:error, "Unable to write to resource"}
        else
          :ok -> {:ok, equation}
        after
        end

        resource.close(file)
      end
    end
  end
end
