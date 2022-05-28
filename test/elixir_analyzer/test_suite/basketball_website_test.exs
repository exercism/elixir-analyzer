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

    test_exercise_analysis "another good solution", comments: [] do
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
      end
    end
  end

  describe "explicit nil" do
    test_exercise_analysis "there should be no explicit nil handling",
      comments_include: [ElixirAnalyzer.Constants.basketball_website_no_explicit_nil()] do
      defmodule BasketballWebsite do
        def extract_from_path(data, path) do
          paths = String.split(path, ".", trim: true)
          do_extract(data, paths)
        end

        defp do_extract(nil, _), do: nil
        defp do_extract(data, []), do: data

        defp do_extract(data, [path | next]) do
          do_extract(data[path], next)
        end
      end
    end
  end

  describe "using Map" do
    test_exercise_analysis "there should be no usage of the map module",
      comments_include: [ElixirAnalyzer.Constants.basketball_website_no_explicit_nil()] do
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
end
