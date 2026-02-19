defmodule ElixirAnalyzer.ExerciseTest.CaptainsLogTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.CaptainsLog

  alias ElixirAnalyzer.Constants

  test_exercise_analysis "example solution",
    comments: [Constants.solution_same_as_exemplar()] do
    defmodule CaptainsLog do
      @planetary_classes ["D", "H", "J", "K", "L", "M", "N", "R", "T", "Y"]

      def random_planet_class() do
        Enum.random(@planetary_classes)
      end

      def random_ship_registry_number() do
        number = Enum.random(1000..9999)
        "NCC-#{number}"
      end

      def random_stardate() do
        :rand.uniform() * 1000 + 41_000
      end

      def format_stardate(stardate) do
        to_string(:io_lib.format("~.1f", [stardate]))
      end
    end
  end

  describe "Expects random_planet_class and random_ship_registry_number to use Enum.random" do
    test_exercise_analysis "random_planet_class does not use Enum.random",
      comments_include: [Constants.captains_log_use_enum_random()] do
      defmodule CaptainsLog do
        @planetary_classes ["D", "H", "J", "K", "L", "M", "N", "R", "T", "Y"]

        def random_planet_class() do
          @planetary_classes
          |> Enum.shuffle()
          |> hd
        end
      end
    end

    test_exercise_analysis "random_ship_registry_number does not use Enum.random",
      comments_include: [Constants.captains_log_use_enum_random()] do
      defmodule CaptainsLog do
        def random_ship_registry_number() do
          number =
            1000..9999
            |> Enum.shuffle()
            |> hd

          "NCC-#{number}"
        end
      end
    end
  end

  describe "random_stardate uses :rand.uniform" do
    test_exercise_analysis "when using Enum.random instead",
      comments_include: [
        Constants.captains_log_do_not_use_enum_random()
      ],
      comments_exclude: [
        Constants.captains_log_use_rand_uniform()
      ] do
      defmodule CaptainsLog do
        def random_stardate do
          Enum.random(4_100_000..4_200_000) |> Kernel./(100)
        end
      end
    end

    test_exercise_analysis "when using :rand.uniform_real instead",
      comments_include: [
        Constants.captains_log_do_not_use_rand_uniform_real()
      ],
      comments_exclude: [
        Constants.captains_log_use_rand_uniform()
      ] do
      defmodule CaptainsLog do
        def random_stardate do
          :rand.uniform_real() * 1000 + 41_000
        end
      end
    end

    test_exercise_analysis "when using deprecated :random module",
      comments_include: [Constants.solution_deprecated_random_module()],
      comments_exclude: [Constants.captains_log_use_rand_uniform()] do
      defmodule CaptainsLog do
        def random_stardate() do
          :random.uniform() * 1000 + 41_000
        end
      end
    end
  end

  test_exercise_analysis "format_stardate uses Float.round",
    comments_include: [Constants.captains_log_use_erlang()] do
    defmodule CaptainsLog do
      def format_stardate(stardate) do
        if is_float(stardate) do
          Float.round(stardate, 1) |> to_string()
        else
          raise ArgumentError
        end
      end
    end
  end
end
