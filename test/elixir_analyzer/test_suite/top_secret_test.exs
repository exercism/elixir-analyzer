defmodule ElixirAnalyzer.TestSuite.TopSecretTest do
  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.TopSecret

  test_exercise_analysis "example solution",
    comments: [Constants.solution_same_as_exemplar()] do
    defmodule TopSecret do
      def to_ast(string) do
        Code.string_to_quoted!(string)
      end

      def decode_secret_message_part({keyword, _, children} = ast, acc)
          when keyword in [:def, :defp] do
        {function_name, arguments} = get_function_name_and_arguments(children)

        arity = if arguments, do: length(arguments), else: 0

        message_part =
          function_name
          |> to_string()
          |> String.slice(0, arity)

        {ast, [message_part | acc]}
      end

      def decode_secret_message_part(ast, acc) do
        {ast, acc}
      end

      defp get_function_name_and_arguments([{:when, _, [{function_name, _, arguments} | _]} | _]) do
        {function_name, arguments}
      end

      defp get_function_name_and_arguments([{function_name, _, arguments} | _]) do
        {function_name, arguments}
      end

      def decode_secret_message(string) do
        ast = to_ast(string)
        {_, acc} = Macro.prewalk(ast, [], &decode_secret_message_part/2)

        acc
        |> Enum.reverse()
        |> Enum.join("")
      end
    end
  end

  test_exercise_analysis "other valid solution",
    comments: [] do
    # https://exercism.org/tracks/elixir/exercises/top-secret/solutions/jiegillet
    defmodule TopSecret do
      def to_ast(string) do
        Code.string_to_quoted!(string)
      end

      @def_ops [:def, :defp]
      def decode_secret_message_part({op, _, [{:when, _, [{name, _, args} | _]} | _]} = ast, acc)
          when op in @def_ops do
        acc = add_part(name, if(is_atom(args), do: 0, else: length(args)), acc)
        {ast, acc}
      end

      def decode_secret_message_part({op, _, [{name, _, args} | _]} = ast, acc)
          when op in @def_ops do
        acc = add_part(name, if(is_atom(args), do: 0, else: length(args)), acc)
        {ast, acc}
      end

      def decode_secret_message_part(ast, acc) do
        {ast, acc}
      end

      def decode_secret_message(string) do
        {_, message} =
          string
          |> to_ast()
          |> Macro.prewalk([], &decode_secret_message_part/2)

        message
        |> Enum.reverse()
        |> Enum.join()
      end

      defp add_part(name, arity, acc) do
        name
        |> to_string()
        |> String.slice(0, arity)
        |> then(&[&1 | acc])
      end
    end
  end

  describe "function reuse" do
    test_exercise_analysis "TopSecret.decode_secret_message/1 must call to_ast/1",
      comments_include: [Constants.top_secret_function_reuse()] do
      defmodule TopSecret do
        def decode_secret_message(string) do
          ast = Code.string_to_quoted!(string)
          {_, acc} = Macro.prewalk(ast, [], &decode_secret_message_part/2)

          acc
          |> Enum.reverse()
          |> Enum.join("")
        end
      end
    end

    test_exercise_analysis "TopSecret.decode_secret_message/1 must call decode_secret_message_part/2",
      comments_include: [Constants.top_secret_function_reuse()] do
      def decode_secret_message(string) do
        ast = to_ast(string)

        {_, acc} =
          Macro.prewalk(ast, [], fn ast, acc ->
            case {ast, acc} do
              {{keyword, _, children} = ast, acc}
              when keyword in [:def, :defp] ->
                {function_name, arguments} = get_function_name_and_arguments(children)

                arity = if arguments, do: length(arguments), else: 0

                message_part =
                  function_name
                  |> to_string()
                  |> String.slice(0, arity)

                {ast, [message_part | acc]}

              _ ->
                {ast, acc}
            end
          end)

        acc
        |> Enum.reverse()
        |> Enum.join("")
      end
    end

    test_exercise_analysis "A call to decode_secret_message_part/2 is found even when it is referenced in different ways",
      comments_exclude: [Constants.top_secret_function_reuse()] do
      [
        defmodule TopSecret do
          def decode_secret_message(string) do
            ast = to_ast(string)
            {_, acc} = Macro.prewalk(ast, [], &decode_secret_message_part/2)

            acc
            |> Enum.reverse()
            |> Enum.join("")
          end
        end,
        defmodule TopSecret do
          def decode_secret_message(string) do
            ast = to_ast(string)
            {_, acc} = Macro.prewalk(ast, [], &decode_secret_message_part(&1, &2))

            acc
            |> Enum.reverse()
            |> Enum.join("")
          end
        end,
        defmodule TopSecret do
          def decode_secret_message(string) do
            ast = to_ast(string)

            {_, acc} =
              Macro.prewalk(ast, [], fn ast, acc -> decode_secret_message_part(ast, acc) end)

            acc
            |> Enum.reverse()
            |> Enum.join("")
          end
        end
      ]
    end
  end

  describe "function capture" do
    test_exercise_analysis "reports instances of creating a new function",
      comments_include: [Constants.top_secret_function_capture()] do
      [
        defmodule TopSecret do
          def decode_secret_message(string) do
            ast = to_ast(string)
            {_, acc} = Macro.prewalk(ast, [], &decode_secret_message_part(&1, &2))

            acc
            |> Enum.reverse()
            |> Enum.join("")
          end
        end,
        defmodule TopSecret do
          def decode_secret_message(string) do
            ast = to_ast(string)

            {_, acc} =
              Macro.prewalk(ast, [], fn ast, acc -> decode_secret_message_part(ast, acc) end)

            acc
            |> Enum.reverse()
            |> Enum.join("")
          end
        end
      ]
    end
  end
end
