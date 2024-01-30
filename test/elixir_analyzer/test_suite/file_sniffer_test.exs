defmodule ElixirAnalyzer.ExerciseTest.FileSnifferTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.FileSniffer

  test_exercise_analysis "example solution",
    comments: [ElixirAnalyzer.Constants.solution_same_as_exemplar()] do
    [
      defmodule FileSniffer do
        def type_from_extension("bmp"), do: "image/bmp"
        def type_from_extension("png"), do: "image/png"
        def type_from_extension("jpg"), do: "image/jpg"
        def type_from_extension("gif"), do: "image/gif"
        def type_from_extension("exe"), do: "application/octet-stream"
        def type_from_extension(_file_extension), do: nil

        def type_from_binary(<<0x42, 0x4D, _::binary>>), do: "image/bmp"

        def type_from_binary(<<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>>),
          do: "image/png"

        def type_from_binary(<<0xFF, 0xD8, 0xFF, _::binary>>), do: "image/jpg"
        def type_from_binary(<<0x47, 0x49, 0x46, _::binary>>), do: "image/gif"

        def type_from_binary(<<0x7F, 0x45, 0x4C, 0x46, _::binary>>),
          do: "application/octet-stream"

        def type_from_binary(_binary), do: nil

        def verify(binary, extension) do
          binary_type = type_from_binary(binary)
          extension_type = type_from_extension(extension)

          if binary_type == extension_type and not is_nil(binary_type) do
            {:ok, binary_type}
          else
            {:error, "Warning, file format and file extension do not match."}
          end
        end
      end
    ]
  end

  test_exercise_analysis "other solutions",
    comments: [] do
    [
      defmodule FileSniffer do
        def type_from_binary(<<?B, ?M, _::binary>>), do: "image/bmp"

        def type_from_binary(<<0x89, ?P, ?N, ?G, 0x0D, 0x0A, 0x1A, 0x0A, _::binary>>),
          do: "image/png"

        def type_from_binary(<<0xFF, 0xD8, 0xFF, _::binary>>), do: "image/jpg"
        def type_from_binary(<<?G, ?I, ?F, _::binary>>), do: "image/gif"

        def type_from_binary(<<?\d, ?E, ?L, ?F, _::binary>>),
          do: "application/octet-stream"
      end,
      defmodule FileSniffer do
        def type_from_binary(file_binary) do
          case file_binary do
            <<0x7F, 0x45, 0x4C, 0x46, rest::binary>> -> "application/octet-stream"
            <<0x42, 0x4D, rest::binary>> -> "image/bmp"
            <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, rest::binary>> -> "image/png"
            <<0xFF, 0xD8, 0xFF, rest::binary>> -> "image/jpg"
            <<0x47, 0x49, 0x46, rest::binary>> -> "image/gif"
          end
        end
      end,
      defmodule FileSniffer do
        def type_from_binary(file_binary) do
          case file_binary do
            <<0x7F, 0x45, 0x4C, 0x46, rest::bitstring>> -> "application/octet-stream"
            <<0x42, 0x4D, rest::bitstring>> -> "image/bmp"
            <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, rest::bitstring>> -> "image/png"
            <<0xFF, 0xD8, 0xFF, rest::bitstring>> -> "image/jpg"
            <<0x47, 0x49, 0x46, rest::bitstring>> -> "image/gif"
          end
        end
      end,
      defmodule FileSniffer do
        def type_from_binary(file_binary) do
          case file_binary do
            <<0x7F, 0x45, 0x4C, 0x46, rest::bits>> -> "application/octet-stream"
            <<0x42, 0x4D, rest::bits>> -> "image/bmp"
            <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, rest::bits>> -> "image/png"
            <<0xFF, 0xD8, 0xFF, rest::bits>> -> "image/jpg"
            <<0x47, 0x49, 0x46, rest::bits>> -> "image/gif"
          end
        end
      end,
      defmodule FileSniffer do
        @exe_signature <<0x7F, 0x45, 0x4C, 0x46>>
        @bmp_signature <<0x42, 0x4D>>
        @png_signature <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>
        @jpg_signature <<0xFF, 0xD8, 0xFF>>
        @gif_signature <<0x47, 0x49, 0x46>>

        def type_from_binary(<<@exe_signature, _rest::binary>>), do: type_from_extension("exe")
        def type_from_binary(<<@bmp_signature, _rest::binary>>), do: type_from_extension("bmp")
        def type_from_binary(<<@png_signature, _rest::binary>>), do: type_from_extension("png")
        def type_from_binary(<<@jpg_signature, _rest::binary>>), do: type_from_extension("jpg")
        def type_from_binary(<<@gif_signature, _rest::binary>>), do: type_from_extension("gif")
        def type_from_binary(_), do: :unknown
      end,
      defmodule FileSniffer do
        def type_from_binary(<<head::binary-size(8), _::binary>>) do
          case head do
            <<0x7F, 0x45, 0x4C, 0x46, _::binary>> -> "application/octet-stream"
            <<0x42, 0x4D, _::binary>> -> "image/bmp"
            <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>> -> "image/png"
            <<0xFF, 0xD8, 0xFF, _::binary>> -> "image/jpg"
            <<0x47, 0x49, 0x46, _::binary>> -> "image/gif"
          end
        end
      end,
      defmodule FileSniffer do
        def type_from_binary(<<head::binary-size(8), _::binary>>) do
          case head do
            <<0x7F::8, 0x45::8, 0x4C::8, 0x46::8, _::binary>> ->
              "application/octet-stream"

            <<0x42::8, 0x4D::8, _::binary>> ->
              "image/bmp"

            <<0x89::8, 0x50::8, 0x4E::8, 0x47::8, 0x0D::8, 0x0A::8, 0x1A::8, 0x0A::8>> ->
              "image/png"

            <<0xFF::8, 0xD8::8, 0xFF::8, _::binary>> ->
              "image/jpg"

            <<0x47::8, 0x49::8, 0x46::8, _::binary>> ->
              "image/gif"
          end
        end
      end,
      defmodule FileSniffer do
        def type_from_binary(<<head::binary-size(8), _::binary>>) do
          case head do
            <<0x7F::size(8), 0x45::size(8), 0x4C::size(8), 0x46::size(8), _::binary>> ->
              "application/octet-stream"

            <<0x42::size(8), 0x4D::size(8), _::binary>> ->
              "image/bmp"

            <<0x89::size(8), 0x50::size(8), 0x4E::size(8), 0x47::size(8), 0x0D::size(8),
              0x0A::size(8), 0x1A::size(8), 0x0A::size(8)>> ->
              "image/png"

            <<0xFF::size(8), 0xD8::size(8), 0xFF::size(8), _::binary>> ->
              "image/jpg"

            <<0x47::size(8), 0x49::size(8), 0x46::size(8), _::binary>> ->
              "image/gif"
          end
        end
      end,
      defmodule FileSniffer do
        @exe_type "application/octet-stream"
        @bmp_type "image/bmp"
        @png_type "image/png"
        @jpg_type "image/jpg"
        @gif_type "image/gif"

        def type_from_binary(<<"\dELF", _rest::binary>>), do: @exe_type
        def type_from_binary(<<"BM", _rest::binary>>), do: @bmp_type
        def type_from_binary(<<"\x89PNG\r\n\x1A\n", _rest::binary>>), do: @png_type
        def type_from_binary(<<"\xFF\xD8\xFF", _rest::binary>>), do: @jpg_type
        def type_from_binary(<<"GIF", _rest::binary>>), do: @gif_type
      end,
      defmodule FileSniffer do
        def type_from_binary(<<signature::binary-size(2), _rest::binary>>)
            when <<0x42, 0x4D>> == signature,
            do: "image/bmp"

        def type_from_binary(<<signature::binary-size(8), _rest::binary>>)
            when <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>> == signature,
            do: "image/png"

        def type_from_binary(<<signature::binary-size(3), _rest::binary>>)
            when <<0xFF, 0xD8, 0xFF>> == signature,
            do: "image/jpg"

        def type_from_binary(<<signature::binary-size(3), _rest::binary>>)
            when <<0x47, 0x49, 0x46>> == signature,
            do: "image/gif"

        def type_from_binary(<<signature::binary-size(4), _rest::binary>>)
            when <<0x7F, 0x45, 0x4C, 0x46>> == signature,
            do: "application/octet-stream"

        def type_from_binary(_binary), do: nil
      end,
      defmodule FileSniffer do
        def type_from_binary(<<66, 77, 30, _::binary>>), do: type_from_extension("bmp")

        def type_from_binary(<<71, 73, 70, 56, 57, 97, _::binary>>),
          do: type_from_extension("gif")

        def type_from_binary(<<255, 216, 255, 219, _::binary>>), do: type_from_extension("jpg")

        def type_from_binary(<<137, 80, 78, 71, 13, 10, 26, 10, _::binary>>),
          do: type_from_extension("png")

        def type_from_binary(<<127, 69, 76, 70, _::binary>>), do: type_from_extension("exe")
        def type_from_binary(file), do: type_from_extension(file)
      end
    ]
  end

  test_exercise_analysis "doesn't use <<>> nor ::",
    comments: [Constants.file_sniffer_use_bitstring()] do
    [
      defmodule FileSniffer do
        def type_from_binary(file) do
          cond do
            String.starts_with?(file, "BM") ->
              "image/bmp"

            String.starts_with?(file, "\x89PNG\r\n\x1A\n") ->
              "image/png"

            String.starts_with?(file, "\xFF\xD8\xFF") ->
              "image/jpg"

            String.starts_with?(file, "GIF") ->
              "image/gif"

            String.starts_with?(file, "\dELF") ->
              "application/octet-stream"
          end
        end
      end,
      defmodule FileSniffer do
        def type_from_binary("BM" <> _rest), do: "image/bmp"

        def type_from_binary("\x89PNG\r\n\x1A\n" <> _rest),
          do: "image/png"

        def type_from_binary("\xFF\xD8\xFF" <> _rest), do: "image/jpg"
        def type_from_binary("GIF" <> _rest), do: "image/gif"
        def type_from_binary("\dELF" <> _rest), do: "application/octet-stream"
      end,
      defmodule FileSniffer do
        def type_from_binary(<<0x42, 0x4D>> <> _rest), do: "image/bmp"

        def type_from_binary(<<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>> <> _rest),
          do: "image/png"

        def type_from_binary(<<0xFF, 0xD8, 0xFF>> <> _rest), do: "image/jpg"
        def type_from_binary(<<0x47, 0x49, 0x46>> <> _rest), do: "image/gif"
        def type_from_binary(<<0x7F, 0x45, 0x4C, 0x46>> <> _rest), do: "application/octet-stream"
        def type_from_binary(_), do: nil
      end
    ]
  end
end
