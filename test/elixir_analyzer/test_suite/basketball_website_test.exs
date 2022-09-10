defmodule ElixirAnalyzer.ExerciseTest.BasketballWebsiteTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.BasketballWebsite

  describe "perfect solutions" do
    test_exercise_analysis "exemplar solution",
      comments: [ElixirAnalyzer.Constants.solution_same_as_exemplar()] do
      defmodule BasketballWebsite do
        def extract_from_path(data, path) do
          paths = String.split(path, ".", trim: true)
          do_extract(data, paths)
        end

        defp do_extract(data, []), do: data

        defp do_extract(data, [path | next]) do
          do_extract(data[path], next)
        end

        def get_in_path(data, path) do
          paths = String.split(path, ".", trim: true)
          get_in(data, paths)
        end
      end
    end

    test_exercise_analysis "other good solutions", comments: [] do
      [
        defmodule BasketballWebsite do
          def extract_from_path(data, path) do
            paths = String.split(path, ".", trim: true)
            do_extract(data, paths)
          end

          defp do_extract(data, []), do: data

          defp do_extract(data, [path | next]) do
            do_extract(Access.get(data, path), next)
          end

          def get_in_path(data, path) do
            paths = String.split(path, ".", trim: true)
            get_in(data, paths)
          end
        end,
        defmodule BasketballWebsite do
          def extract_from_path(data, path),
            do: do_extract_from_path(data, String.split(path, "."))

          defp do_extract_from_path(nil, _), do: nil
          defp do_extract_from_path(data, []), do: data

          defp do_extract_from_path(data, [head | tail]),
            do: do_extract_from_path(data[head], tail)

          def get_in_path(data, path), do: data |> get_in(String.split(path, "."))
        end
      ]
    end

    test_exercise_analysis "using Enum is also fine", comments: [] do
      defmodule BasketballWebsite do
        def extract_from_path(data, path) do
          Enum.reduce(String.split(path, "."), data, fn k, acc -> acc[k] end)
        end

        def get_in_path(data, path) do
          get_in(data, String.split(path, "."))
        end
      end
    end

    test_exercise_analysis "using Kernel prefix for get_in is also fine", comments: [] do
      defmodule BasketballWebsite do
        def extract_from_path(data, path) do
          paths = String.split(path, ".", trim: true)
          do_extract(data, paths)
        end

        defp do_extract(data, []), do: data

        defp do_extract(data, [path | next]) do
          do_extract(data[path], next)
        end

        def get_in_path(data, path) do
          paths = String.split(path, ".", trim: true)
          Kernel.get_in(data, paths)
        end
      end
    end
  end

  describe "using Map" do
    test_exercise_analysis "there should be no usage of the map module",
      comments_include: [ElixirAnalyzer.Constants.basketball_website_no_map()] do
      defmodule BasketballWebsite do
        def extract_from_path(data, path) do
          paths = String.split(path, ".", trim: true)
          do_extract(data, paths)
        end

        defp do_extract(data, []), do: data

        defp do_extract(data, [path | next]) do
          do_extract(Map.get(data || %{}, path, nil), next)
        end
      end
    end
  end

  describe "using get_in" do
    test_exercise_analysis "extract_from_path should not use get_in",
      comments_include: [ElixirAnalyzer.Constants.basketball_website_get_in()] do
      defmodule BasketballWebsite do
        def extract_from_path(data, path) do
          paths = String.split(path, ".", trim: true)
          get_in(data, paths)
        end
      end
    end

    test_exercise_analysis "get_in_path must use get_in",
      comments_include: [ElixirAnalyzer.Constants.basketball_website_get_in()] do
      defmodule BasketballWebsite do
        def get_in_path(data, path) do
          paths = String.split(path, ".", trim: true)
          do_extract(data, paths)
        end

        defp do_extract(data, []), do: data

        defp do_extract(data, [path | next]) do
          do_extract(data[path], next)
        end
      end
    end
  end
end
