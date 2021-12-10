defmodule ElixirAnalyzer.ExerciseTest.DNAEncodingTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.DNAEncoding

  test_exercise_analysis "example solution",
    comments: [ElixirAnalyzer.Constants.solution_same_as_exemplar()] do
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

  test_exercise_analysis "detects the usage of the Enum module",
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
          do_decode(dna, [])
        end

        defp do_decode(<<>>, acc), do: acc |> reverse()

        defp do_decode(<<n::4, rest::bitstring>>, acc),
          do: do_decode(rest, [decode_nucleotide(n) | acc])

        defp reverse(l), do: do_reverse(l, [])
        defp do_reverse([], acc), do: acc
        defp do_reverse([h | t], acc), do: do_reverse(t, [h | acc])
      end
    ]
  end

  test_exercise_analysis "detects the usage of the Stream module",
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
          Stream.map(dna, &encode_nucleotide/1)
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
    ]
  end

  test_exercise_analysis "detects the usage of the List module",
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
          List.foldr(dna, <<0::0>>, &<<encode_nucleotide(&1)::4, &2::bitstring>>)
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

        def encode(dna) do
          do_encode(dna, <<>>)
        end

        defp do_encode([], acc), do: acc

        defp do_encode([n | rest], acc) do
          do_encode(rest, <<acc::bitstring, encode_nucleotide(n)::4>>)
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
