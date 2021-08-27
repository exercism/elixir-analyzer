defmodule ElixirAnalyzer.ExerciseTest.FileSnifferTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.FileSniffer

  test_exercise_analysis "example solution",
    comments: [] do
    [
      defmodule FileSniffer do
        def type_from_extension("bmp"), do: "image/bmp"
        def type_from_extension("png"), do: "image/png"
        def type_from_extension("jpg"), do: "image/jpg"
        def type_from_extension("gif"), do: "image/gif"
        def type_from_extension("exe"), do: "application/octet-stream"

        def type_from_binary(<<0x42, 0x4D, _::binary>>), do: "image/bmp"

        def type_from_binary(<<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>>),
          do: "image/png"

        def type_from_binary(<<0xFF, 0xD8, 0xFF, _::binary>>), do: "image/jpg"
        def type_from_binary(<<0x47, 0x49, 0x46, _::binary>>), do: "image/gif"

        def type_from_binary(<<0x7F, 0x45, 0x4C, 0x46, _::binary>>),
          do: "application/octet-stream"

        def verify(binary, extension) do
          binary_type = type_from_binary(binary)
          extension_type = type_from_extension(extension)

          if binary_type == extension_type do
            {:ok, binary_type}
          else
            {:error, "Warning, file format and file extension do not match."}
          end
        end
      end,
      defmodule FileSniffer do
        def type_from_binary(<<?B, ?M, _::binary>>), do: "image/bmp"

        def type_from_binary(<<0x89, ?P, ?N, ?G, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>>),
          do: "image/png"

        def type_from_binary(<<0xFF, 0xD8, 0xFF, _::binary>>), do: "image/jpg"
        def type_from_binary(<<?G, ?I, ?F, _::binary>>), do: "image/gif"

        def type_from_binary(<<?\d, ?E, ?L, ?F, _::binary>>),
          do: "application/octet-stream"
      end,
      def type_from_binary(file_binary) do
        case file_binary do
          <<0x7F, 0x45, 0x4C, 0x46, rest::binary>> -> "application/octet-stream"
          <<0x42, 0x4D, rest::binary>> -> "image/bmp"
          <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, rest::binary>> -> "image/png"
          <<0xFF, 0xD8, 0xFF, rest::binary>> -> "image/jpg"
          <<0x47, 0x49, 0x46, rest::binary>> -> "image/gif"
        end
      end
    ]
  end

  test_exercise_analysis "doesn't use pattern matching",
    comments: [Constants.file_sniffer_use_pattern_matching()] do
    [
      defmodule FileSniffer do
        def type_from_binary(file) do
          cond do
            String.starts_with?(file, "BM") ->
              "image/bmp"

            String.starts_with?(file, <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>) ->
              "image/png"

            String.starts_with?(file, <<0xFF, 0xD8, 0xFF>>) ->
              "image/jpg"

            String.starts_with?(file, "GIF") ->
              "image/gif"

            String.starts_with?(file, <<0x7F, 0x45, 0x4C, 0x46>>) ->
              "application/octet-stream"
          end
        end
      end,
      defmodule FileSniffer do
        def type_from_binary("BM" <> _rest), do: "image/bmp"

        def type_from_binary(<<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>>),
          do: "image/png"

        def type_from_binary(<<0xFF, 0xD8, 0xFF, _::binary>>), do: "image/jpg"
        def type_from_binary("GIF" <> _rest), do: "image/gif"
        def type_from_binary("\dELF" <> _rest), do: "application/octet-stream"
      end
    ]
  end
end
