defmodule ElixirAnalyzer.ExerciseTest.SieveTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.Sieve

  test_exercise_analysis "example solution",
    comments: [] do
    defmodule Sieve do
      @doc """
      Generates a list of primes up to a given limit.
      """

      @spec primes_to(non_neg_integer) :: [non_neg_integer]
      def primes_to(n) when n < 2, do: []

      def primes_to(limit) do
        do_primes(limit, Enum.to_list(2..limit), [])
      end

      def do_primes(_limit, [], primes), do: Enum.reverse(primes)
      def do_primes(limit, [nil | sieve], primes), do: do_primes(limit, sieve, primes)

      def do_primes(limit, [prime | _] = sieve, primes) do
        sieve =
          sieve
          |> Enum.chunk_every(prime)
          |> Enum.map(fn [_ | tail] -> [nil | tail] end)
          |> Enum.concat()

        do_primes(limit, sieve, [prime | primes])
      end
    end
  end

  describe "forbids division and remainder operations" do
    test_exercise_analysis "detects Kernel.rem/2",
      comments: [Constants.sieve_do_not_use_div_rem()] do
      defmodule Sieve do
        defp sieve([prime | candidates], primes) do
          new_candidates = Enum.reject(candidates, &(rem(&1, prime) == 0))
          sieve(new_candidates, [prime | primes])
        end
      end
    end

    test_exercise_analysis "detects Kernel.div/2",
      comments: [Constants.sieve_do_not_use_div_rem()] do
      defmodule Sieve do
        defp sieve([prime | candidates], primes) do
          new_candidates = Enum.reject(candidates, &(&1 - prime * div(&1, prime) == 0))
          sieve(new_candidates, [prime | primes])
        end
      end
    end

    test_exercise_analysis "detects Kernel.//2",
      comments: [Constants.sieve_do_not_use_div_rem()] do
      defmodule Sieve do
        defp sieve([prime | candidates], primes) do
          new_candidates = Enum.reject(candidates, &(&1 - prime * floor(&1 / prime) == 0))
          sieve(new_candidates, [prime | primes])
        end
      end
    end
  end

  # here be dragons

  describe "forbids math-related modules" do
    test_exercise_analysis "detects Integer module",
      comments: [Constants.sieve_do_not_use_div_rem()] do
      defmodule Sieve do
        defp sieve([prime | candidates], primes) do
          new_candidates =
            Enum.reject(candidates, fn candidate ->
              candidate - prime * Integer.floor_div(candidate, prime) == 0
            end)

          sieve(new_candidates, [prime | primes])
        end
      end
    end

    test_exercise_analysis "detects Float module",
      comments: [Constants.sieve_do_not_use_div_rem()] do
      defmodule Sieve do
        defp sieve([prime | candidates], primes) do
          new_candidates =
            Enum.reject(candidates, fn candidate ->
              candidate - prime * floor(Float.floor(candidate * 1.0 / (prime * 1.0))) == 0
            end)

          sieve(new_candidates, [prime | primes])
        end
      end
    end

    test_exercise_analysis "detects :math module",
      comments: [Constants.sieve_do_not_use_div_rem()] do
      defmodule Sieve do
        defp sieve([prime | candidates], primes) do
          new_candidates =
            Enum.reject(candidates, fn candidate ->
              candidate - prime * floor(:math.floor(candidate * 1.0 / (prime * 1.0))) == 0
            end)

          sieve(new_candidates, [prime | primes])
        end
      end
    end
  end
end
