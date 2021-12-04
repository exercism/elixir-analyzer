defmodule ElixirAnalyzer.ExerciseTest.DNATest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.DNA

  test_exercise_analysis "example solution",
    comments: [ElixirAnalyzer.Constants.solution_same_as_exemplar()] do
    defmodule DNA do
      @moduledoc """
      Example solution for the `bitstrings` exercise.

      Written by Tim Austin, tim@neenjaw.com, June 2020.

       | NucleicAcid | Bits |
       | ----------- | ---- |
       |    ' '      | 0000 |
       |     A       | 0001 |
       |     C       | 0010 |
       |     G       | 0100 |
       |     T       | 1000 |
      """

      def encode_nucleotide(?\s), do: 0b0000
      def encode_nucleotide(?A), do: 0b0001
      def encode_nucleotide(?C), do: 0b0010
      def encode_nucleotide(?G), do: 0b0100
      def encode_nucleotide(?T), do: 0b1000

      def decode_nucleotide(0b0000), do: ?\s
      def decode_nucleotide(0b0001), do: ?A
      def decode_nucleotide(0b0010), do: ?C
      def decode_nucleotide(0b0100), do: ?G
      def decode_nucleotide(0b1000), do: ?T

      def encode(dna) do
        do_encode(dna, <<>>)
      end

      defp do_encode([], acc), do: acc

      defp do_encode([n | rest], acc) do
        do_encode(rest, <<acc::bitstring, encode_nucleotide(n)::4>>)
      end

      def decode(dna) do
        do_decode(dna, [])
      end

      defp do_decode(<<>>, acc), do: acc |> reverse()

      defp do_decode(<<n::4, rest::bitstring>>, acc),
        do: do_decode(rest, [decode_nucleotide(n) | acc])

      defp reverse(l), do: do_reverse(l, [])
      defp do_reverse([], acc), do: acc
      defp do_reverse([h | t], acc), do: do_reverse(t, [h | acc])
    end
  end

  test_exercise_analysis "detecs Enum.reduce",
    comments: [Constants.dna_encoding_use_recursion()] do
    [
      defmodule DNA do
        def encode_nucleotide(?\s), do: 0b0000
        def encode_nucleotide(?A), do: 0b0001
        def encode_nucleotide(?C), do: 0b0010
        def encode_nucleotide(?G), do: 0b0100
        def encode_nucleotide(?T), do: 0b1000
        def decode_nucleotide(0b0000), do: ?\s
        def decode_nucleotide(0b0001), do: ?A
        def decode_nucleotide(0b0010), do: ?C
        def decode_nucleotide(0b0100), do: ?G
        def decode_nucleotide(0b1000), do: ?T

        def encode(dna) do
          dna
          |> Enum.map(&encode_nucleotide/1)
          |> Enum.reduce("", fn enc, bs -> <<bs::bitstring, enc::4>> end)
        end

        def decode(dna) do
          for <<ns::4 <- dna>> do
            decode_nucleotide(ns)
          end
        end
      end
    ]
  end

  test_exercise_analysis "detects List.foldr",
    comments: [Constants.dna_encoding_use_recursion(), Constants.solution_use_function_capture()] do
    [
      defmodule DNA do
        @acids %{
          ?\s => 0b0000,
          ?A => 0b0001,
          ?C => 0b0010,
          ?G => 0b0100,
          ?T => 0b1000
        }

        def encode_nucleotide(code_point), do: @acids[code_point]

        def decode_nucleotide(encoded_code) do
          {key, _} = Enum.find(@acids, nil, fn {_, code} -> code == encoded_code end)
          key
        end

        def encode(dna) do
          Enum.map(dna, &encode_nucleotide(&1))
          |> List.foldr(<<0::0>>, &<<&1::4, &2::bitstring>>)
        end

        def decode(dna) do
          do_decode(dna, [])
          |> Enum.reverse()
        end

        defp do_decode(<<0::0>>, acc), do: acc

        defp do_decode(dna, acc) do
          <<value::4, rest::bitstring>> = dna
          do_decode(rest, [decode_nucleotide(value) | acc])
        end
      end
    ]
  end

  test_exercise_analysis "detects list comprehensions",
    comments: [Constants.dna_encoding_use_recursion()] do
    [
      defmodule DNA do
        def encode_nucleotide(?\s), do: 0b0000
        def encode_nucleotide(?A), do: 0b0001
        def encode_nucleotide(?C), do: 0b0010
        def encode_nucleotide(?G), do: 0b0100
        def encode_nucleotide(?T), do: 0b1000

        def decode_nucleotide(0b0000), do: ?\s
        def decode_nucleotide(0b0001), do: ?A
        def decode_nucleotide(0b0010), do: ?C
        def decode_nucleotide(0b0100), do: ?G
        def decode_nucleotide(0b1000), do: ?T

        def encode([]), do: <<>>

        def encode([nucleotide | dna]) do
          <<encode_nucleotide(nucleotide)::4, encode(dna)::bitstring()>>
        end

        def decode(dna) do
          for <<ns::4 <- dna>> do
            decode_nucleotide(ns)
          end
        end
      end,
      defmodule DNA do
        def encode_nucleotide(?\s), do: 0b0000
        def encode_nucleotide(?A), do: 0b0001
        def encode_nucleotide(?C), do: 0b0010
        def encode_nucleotide(?G), do: 0b0100
        def encode_nucleotide(?T), do: 0b1000

        def decode_nucleotide(0b0000), do: ?\s
        def decode_nucleotide(0b0001), do: ?A
        def decode_nucleotide(0b0010), do: ?C
        def decode_nucleotide(0b0100), do: ?G
        def decode_nucleotide(0b1000), do: ?T

        def encode(chars) do
          for c <- chars, reduce: <<>> do
            acc -> <<acc::bitstring, encode_nucleotide(c)::4>>
          end
        end

        def decode(bin) do
          for <<b::4 <- bin>>, into: [], do: decode_nucleotide(b)
        end
      end
    ]
  end
end
