defmodule ElixirAnalyzer.ExerciseTest.DNAEncodingTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.DNAEncoding

  alias ElixirAnalyzer.Submission

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

  test_exercise_analysis "recursive solutions but no tail call recursion",
    comments: [ElixirAnalyzer.Constants.dna_encoding_use_tail_call_recursion()] do
    [
      defmodule DNA do
        @nucleotide_encode_table %{
          ?\s => 0b0000,
          ?A => 0b0001,
          ?C => 0b0010,
          ?G => 0b0100,
          ?T => 0b1000
        }

        @nucleotide_decode_table %{
          0b0000 => ?\s,
          0b0001 => ?A,
          0b0010 => ?C,
          0b0100 => ?G,
          0b1000 => ?T
        }

        def encode_nucleotide(code_point) do
          Map.fetch!(@nucleotide_encode_table, code_point)
        end

        def decode_nucleotide(encoded_code) do
          Map.fetch!(@nucleotide_decode_table, encoded_code)
        end

        def encode(dna)
        def encode([]), do: <<>>

        def encode([head | tail]) do
          <<encode_nucleotide(head)::4, encode(tail)::bitstring>>
        end

        def decode(dna)
        def decode(<<>>), do: []

        def decode(<<head::4, tail::bitstring>>) do
          [decode_nucleotide(head) | decode(tail)]
        end
      end,
      defmodule DNA do
        @moduledoc false

        @type nucleotide_char :: ?\s | ?A | ?C | ?G | ?T
        @type nucleotide_bitstring :: 0 | 1 | 2 | 4 | 8
        @type dna_charlist :: [nucleotide_char()]
        @type dna_bitstring :: <<_::_*4>>

        @spec encode_nucleotide(nucleotide_char()) :: nucleotide_bitstring()
        def encode_nucleotide(?\s), do: 0b0000
        def encode_nucleotide(?A), do: 0b0001
        def encode_nucleotide(?C), do: 0b0010
        def encode_nucleotide(?G), do: 0b0100
        def encode_nucleotide(?T), do: 0b1000

        @spec decode_nucleotide(nucleotide_bitstring()) :: nucleotide_char()
        def decode_nucleotide(0b0000), do: ?\s
        def decode_nucleotide(0b0001), do: ?A
        def decode_nucleotide(0b0010), do: ?C
        def decode_nucleotide(0b0100), do: ?G
        def decode_nucleotide(0b1000), do: ?T

        @spec encode(dna_charlist()) :: dna_bitstring()
        def encode([]), do: <<>>
        def encode([head | tail]), do: <<encode_nucleotide(head)::4, encode(tail)::bitstring>>

        @spec decode(bitstring) :: dna_charlist()
        def decode(<<>>), do: []
        def decode(<<head::4, rest::bitstring>>), do: [decode_nucleotide(head) | decode(rest)]
      end,
      defmodule DNA do
        @moduledoc false

        @type nucleotide_char :: ?\s | ?A | ?C | ?G | ?T
        @type nucleotide_bitstring :: 0 | 1 | 2 | 4 | 8
        @type dna_charlist :: [nucleotide_char()]
        @type dna_bitstring :: <<_::_*4>>

        @spec encode_nucleotide(nucleotide_char()) :: nucleotide_bitstring()
        def encode_nucleotide(?\s), do: 0b0000
        def encode_nucleotide(?A), do: 0b0001
        def encode_nucleotide(?C), do: 0b0010
        def encode_nucleotide(?G), do: 0b0100
        def encode_nucleotide(?T), do: 0b1000

        @spec decode_nucleotide(nucleotide_bitstring()) :: nucleotide_char()
        def decode_nucleotide(0b0000), do: ?\s
        def decode_nucleotide(0b0001), do: ?A
        def decode_nucleotide(0b0010), do: ?C
        def decode_nucleotide(0b0100), do: ?G
        def decode_nucleotide(0b1000), do: ?T

        @spec encode(dna_charlist()) :: dna_bitstring()
        def encode([]), do: <<>>
        def encode([head | tail]), do: <<encode_nucleotide(head)::4, encode(tail)::bitstring>>

        @spec decode(bitstring) :: dna_charlist()
        def decode(<<>>), do: []
        def decode(<<head::4, rest::bitstring>>), do: [decode_nucleotide(head) | decode(rest)]
      end,
      defmodule DNA do
        @nucleic_space 0b0000
        @nucleic_acid_a 0b0001
        @nucleic_acid_c 0b0010
        @nucleic_acid_g 0b0100
        @nucleic_acid_t 0b1000

        @spec encode_nucleotide(char()) :: integer()
        def encode_nucleotide(?\s), do: @nucleic_space
        def encode_nucleotide(?A), do: @nucleic_acid_a
        def encode_nucleotide(?C), do: @nucleic_acid_c
        def encode_nucleotide(?G), do: @nucleic_acid_g
        def encode_nucleotide(?T), do: @nucleic_acid_t

        @spec decode_nucleotide(integer()) :: char()
        def decode_nucleotide(@nucleic_space), do: ?\s
        def decode_nucleotide(@nucleic_acid_a), do: ?A
        def decode_nucleotide(@nucleic_acid_c), do: ?C
        def decode_nucleotide(@nucleic_acid_g), do: ?G
        def decode_nucleotide(@nucleic_acid_t), do: ?T

        @spec encode(charlist()) :: bitstring()
        def encode([]), do: <<>>
        def encode([?\s | rest]), do: <<@nucleic_space::size(4), encode(rest)::bitstring>>
        def encode([?A | rest]), do: <<@nucleic_acid_a::size(4), encode(rest)::bitstring>>
        def encode([?C | rest]), do: <<@nucleic_acid_c::size(4), encode(rest)::bitstring>>
        def encode([?G | rest]), do: <<@nucleic_acid_g::size(4), encode(rest)::bitstring>>
        def encode([?T | rest]), do: <<@nucleic_acid_t::size(4), encode(rest)::bitstring>>

        @spec decode(bitstring()) :: charlist()
        def decode(<<>>), do: []
        def decode(<<@nucleic_space::size(4), rest::bitstring>>), do: [?\s | decode(rest)]
        def decode(<<@nucleic_acid_a::size(4), rest::bitstring>>), do: [?A | decode(rest)]
        def decode(<<@nucleic_acid_c::size(4), rest::bitstring>>), do: [?C | decode(rest)]
        def decode(<<@nucleic_acid_g::size(4), rest::bitstring>>), do: [?G | decode(rest)]
        def decode(<<@nucleic_acid_t::size(4), rest::bitstring>>), do: [?T | decode(rest)]
      end,
      # exemplar but with extra function calls that make it not tail-calls
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
          result = do_encode(rest, <<acc::bitstring, encode_nucleotide(n)::4>>)
          log(result)
          result
        end

        def decode(dna) do
          do_decode(dna, [])
        end

        defp do_decode(<<>>, acc), do: acc |> reverse()

        defp do_decode(<<n::4, rest::bitstring>>, acc) do
          result = do_decode(rest, [decode_nucleotide(n) | acc])
          log(result)
          result
        end

        defp reverse(l), do: do_reverse(l, [])
        defp do_reverse([], acc), do: acc
        defp do_reverse([h | t], acc), do: do_reverse(t, [h | acc])
      end
    ]
  end

  test "use_tail_call_recursion has params with function lists" do
    code_string = ~S"""
    defmodule DNA do
      @nucleotide_encode_table %{
        ?\s => 0b0000,
        ?A => 0b0001,
        ?C => 0b0010,
        ?G => 0b0100,
        ?T => 0b1000
      }

      @nucleotide_decode_table %{
        0b0000 => ?\s,
        0b0001 => ?A,
        0b0010 => ?C,
        0b0100 => ?G,
        0b1000 => ?T
      }

      def encode_nucleotide(code_point) do
        Map.fetch!(@nucleotide_encode_table, code_point)
      end

      def decode_nucleotide(encoded_code) do
        Map.fetch!(@nucleotide_decode_table, encoded_code)
      end

      def encode(dna)
      def encode([]), do: <<>>

      def encode([head | tail]) do
        <<encode_nucleotide(head)::4, encode(tail)::bitstring>>
      end

      def decode(dna)
      def decode(<<>>), do: []

      def decode(<<head::4, tail::bitstring>>) do
        [decode_nucleotide(head) | decode(tail)]
      end

      defp some_other_function(x) do
        some_other_function(x - 1)
      end

      defp some_other_function(0), do: 100
    end
    """

    source = ElixirAnalyzer.ExerciseTestCase.find_source(ElixirAnalyzer.TestSuite.DNAEncoding)

    result =
      ElixirAnalyzer.TestSuite.DNAEncoding.analyze(%Submission{
        source: %{source | code_string: code_string},
        analysis_module: ElixirAnalyzer.TestSuite.DNAEncoding
      })

    assert hd(result.comments) ==
             %{
               comment: ElixirAnalyzer.Constants.dna_encoding_use_tail_call_recursion(),
               params: %{
                 non_tail_call_recursive_functions: "`decode/1`, `encode/1`",
                 tail_call_recursive_functions: "`some_other_function/1`"
               },
               type: :essential
             }
  end

  test "use_tail_call_recursion params have a fallback value for empty lists" do
    code_string = ~S"""
    defmodule DNA do
      @nucleotide_encode_table %{
        ?\s => 0b0000,
        ?A => 0b0001,
        ?C => 0b0010,
        ?G => 0b0100,
        ?T => 0b1000
      }

      @nucleotide_decode_table %{
        0b0000 => ?\s,
        0b0001 => ?A,
        0b0010 => ?C,
        0b0100 => ?G,
        0b1000 => ?T
      }

      def encode_nucleotide(code_point) do
        Map.fetch!(@nucleotide_encode_table, code_point)
      end

      def decode_nucleotide(encoded_code) do
        Map.fetch!(@nucleotide_decode_table, encoded_code)
      end

      def encode(dna)
      def encode([]), do: <<>>

      def encode([head | tail]) do
        <<encode_nucleotide(head)::4, encode(tail)::bitstring>>
      end

      def decode(dna)
      def decode(<<>>), do: []

      def decode(<<head::4, tail::bitstring>>) do
        [decode_nucleotide(head) | decode(tail)]
      end
    end
    """

    source = ElixirAnalyzer.ExerciseTestCase.find_source(ElixirAnalyzer.TestSuite.DNAEncoding)

    result =
      ElixirAnalyzer.TestSuite.DNAEncoding.analyze(%Submission{
        source: %{source | code_string: code_string},
        analysis_module: ElixirAnalyzer.TestSuite.DNAEncoding
      })

    assert hd(result.comments) ==
             %{
               comment: ElixirAnalyzer.Constants.dna_encoding_use_tail_call_recursion(),
               params: %{
                 non_tail_call_recursive_functions: "`decode/1`, `encode/1`",
                 tail_call_recursive_functions: "none"
               },
               type: :essential
             }
  end

  test "use_tail_call_recursion works with function definitions with guards" do
    code_string = ~S"""
    defmodule DNA do
      @nucleotide_encode_table %{
        ?\s => 0b0000,
        ?A => 0b0001,
        ?C => 0b0010,
        ?G => 0b0100,
        ?T => 0b1000
      }

      @nucleotide_decode_table %{
        0b0000 => ?\s,
        0b0001 => ?A,
        0b0010 => ?C,
        0b0100 => ?G,
        0b1000 => ?T
      }

      def encode_nucleotide(code_point) do
        Map.fetch!(@nucleotide_encode_table, code_point)
      end

      def decode_nucleotide(encoded_code) do
        Map.fetch!(@nucleotide_decode_table, encoded_code)
      end

      def encode(dna)
      def encode([]), do: <<>>

      def encode([head | tail]) when is_list(tail) do
        <<encode_nucleotide(head)::4, encode(tail)::bitstring>>
      end

      def decode(dna)
      def decode(<<>>), do: []

      def decode(<<head::4, tail::bitstring>>) do
        [decode_nucleotide(head) | decode(tail)]
      end

      defp some_other_function(x) when is_integer(x) do
        some_other_function(x - 1)
      end

      defp some_other_function(0), do: 100
    end
    """

    source = ElixirAnalyzer.ExerciseTestCase.find_source(ElixirAnalyzer.TestSuite.DNAEncoding)

    result =
      ElixirAnalyzer.TestSuite.DNAEncoding.analyze(%Submission{
        source: %{source | code_string: code_string},
        analysis_module: ElixirAnalyzer.TestSuite.DNAEncoding
      })

    assert hd(result.comments) ==
             %{
               comment: ElixirAnalyzer.Constants.dna_encoding_use_tail_call_recursion(),
               params: %{
                 non_tail_call_recursive_functions: "`decode/1`, `encode/1`",
                 tail_call_recursive_functions: "`some_other_function/1`"
               },
               type: :essential
             }
  end
end
