defmodule ElixirAnalyzer.ExerciseTest.ListOpsTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.ListOps

  test_exercise_analysis "example solution",
    comments: [] do
    defmodule ListOps do
      @spec length(list) :: non_neg_integer
      def length(l), do: do_length(l, 0)

      defp do_length([], acc), do: acc
      defp do_length([_ | t], acc), do: do_length(t, acc + 1)

      @spec reverse(list) :: list
      def reverse(l), do: do_reverse(l, [])

      defp do_reverse([], acc), do: acc
      defp do_reverse([h | t], acc), do: do_reverse(t, [h | acc])

      @spec map(list, (any -> any)) :: list
      def map(l, f), do: do_map(l, f, []) |> reverse()

      defp do_map([], _, acc), do: acc
      defp do_map([h | t], f, acc), do: do_map(t, f, [f.(h) | acc])

      @spec filter(list, (any -> as_boolean(term))) :: list
      def filter(l, f), do: do_filter(l, f, []) |> reverse()

      defp do_filter([], _, acc), do: acc

      defp do_filter([h | t], f, acc) do
        if f.(h) do
          do_filter(t, f, [h | acc])
        else
          do_filter(t, f, acc)
        end
      end

      @type acc :: any
      @spec foldl(list, acc, (any, acc -> acc)) :: acc
      def foldl([], acc, _), do: acc
      def foldl([h | t], acc, f), do: foldl(t, f.(h, acc), f)

      @spec foldr(list, acc, (any, acc -> acc)) :: acc
      def foldr([], acc, _), do: acc
      def foldr([h | t], acc, f), do: f.(h, foldr(t, acc, f))

      @spec append(list, list) :: list
      def append(a, b), do: do_append(reverse(a), b)

      defp do_append([], b), do: b
      defp do_append([h | t], b), do: do_append(t, [h | b])

      @spec concat([[any]]) :: [any]
      def concat(ll), do: reverse(ll) |> foldl([], &append(&1, &2))
    end
  end

  test_exercise_analysis "illegal implementations",
    comments: [Constants.list_ops_do_not_use_list_functions()] do
    [
      defmodule ListOps do
        def filter(p, l), do: Enum.filter(p, l)
      end,
      defmodule ListOps do
        import Enum
        def filter(p, l), do: filter(p, l)
      end,
      defmodule ListOps do
        import Enum, only: [reduce: 3]
        def foldr(l, a, f), do: reduce(l, a, f)
      end,
      defmodule ListOps do
        alias Enum, as: E
        def filter(p, l), do: E.filter(p, l)
      end,
      defmodule ListOps do
        import List
        def foldr(l, a, f), do: List.foldr(l, a, f)
      end,
      defmodule ListOps do
        import Stream
        def filter(l, a, f), do: Stream.filter(l, a, f) |> Enum.to_list()
      end,
      defmodule ListOps do
        def append(l1, l2), do: l1 ++ l2
      end,
      defmodule ListOps do
        def map(l) do
          try do
            hd(l)
          rescue
            _ -> []
          else
            h -> [h | map(tl(l))]
          end
        end
      end,
      defmodule ListOps do
        def filter(p, l) do
          for x <- l,
              p(x) do
            x
          end
        end
      end,
      defmodule ListOps do
        def filter(p, [h | _] = l) do
          if p.(h) do
            [h | filter(l -- [h])]
          else
            filter(l -- [h])
          end
        end
      end,
      defmodule ListOps do
        def length(l), do: Kernel.length(l)
      end
    ]
  end
end
