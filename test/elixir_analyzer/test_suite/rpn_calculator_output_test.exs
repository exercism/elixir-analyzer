defmodule ElixirAnalyzer.TestSuite.RpnCalculatorOutputTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.RpnCalculatorOutput

  test_exercise_analysis "example solution",
    comments: [] do
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
    end
  end

  test_exercise_analysis "does not contain all of try-rescue-else-after",
    comments_include: [Constants.try_rescue_else_after()] do
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

    test_exercise_analysis "open in try",
      comments: [Constants.open_before_try()] do
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

    test_exercise_analysis "write before try",
      comments: [Constants.write_in_try()] do
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
    end

    test_exercise_analysis "output not in else",
      comments: [Constants.output_in_else()] do
      def write(resource, filename, equation) do
        {:ok, file} = resource.open(filename)

        try do
          IO.write(file, equation)
        rescue
          _ -> ok = false
        else
          :ok -> ok = true
        after
          resource.close(file)
        end

        if ok,
          do: {:ok, equation},
          else: {:error, "Unable to write to resource"}
      end
    end

    test_exercise_analysis "close after after",
      comments: [Constants.close_in_after()] do
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
