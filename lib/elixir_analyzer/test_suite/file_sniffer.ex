defmodule ElixirAnalyzer.TestSuite.FileSniffer do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise File Sniffer
  """

  alias ElixirAnalyzer.Constants
  use ElixirAnalyzer.ExerciseTest

  feature "use pattern matching for bmp" do
    type :essential
    find :any
    comment Constants.file_sniffer_use_pattern_matching()

    form do
      <<0x42, 0x4D, _ignore>>
    end

    form do
      <<0x42, 0x4D>>
    end

    form do
      <<0x42::8, 0x4D::8, _ignore>>
    end

    form do
      <<0x42::8, 0x4D::8>>
    end

    form do
      <<0x42::size(8), 0x4D::size(8), _ignore>>
    end

    form do
      <<0x42::size(8), 0x4D::size(8)>>
    end
  end

  feature "use pattern matching for png" do
    type :essential
    find :any
    comment Constants.file_sniffer_use_pattern_matching()

    form do
      <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _ignore>>
    end

    form do
      <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A>>
    end

    form do
      <<0x89::8, 0x50::8, 0x4E::8, 0x47::8, 0x0D::8, 0x0A::8, 0x1A::8, 0x0A::8, _ignore>>
    end

    form do
      <<0x89::8, 0x50::8, 0x4E::8, 0x47::8, 0x0D::8, 0x0A::8, 0x1A::8, 0x0A::8>>
    end

    form do
      <<0x89::size(8), 0x50::size(8), 0x4E::size(8), 0x47::size(8), 0x0D::size(8), 0x0A::size(8),
        0x1A::size(8), 0x0A::size(8), _ignore>>
    end

    form do
      <<0x89::size(8), 0x50::size(8), 0x4E::size(8), 0x47::size(8), 0x0D::size(8), 0x0A::size(8),
        0x1A::size(8), 0x0A::size(8)>>
    end
  end

  feature "use pattern matching for jpg" do
    type :essential
    find :any
    comment Constants.file_sniffer_use_pattern_matching()

    form do
      <<0xFF, 0xD8, 0xFF, _ignore>>
    end

    form do
      <<0xFF, 0xD8, 0xFF>>
    end

    form do
      <<0xFF::8, 0xD8::8, 0xFF::8, _ignore>>
    end

    form do
      <<0xFF::8, 0xD8::8, 0xFF::8>>
    end

    form do
      <<0xFF::size(8), 0xD8::size(8), 0xFF::size(8), _ignore>>
    end

    form do
      <<0xFF::size(8), 0xD8::size(8), 0xFF::size(8)>>
    end
  end

  feature "use pattern matching for gif" do
    type :essential
    find :any
    comment Constants.file_sniffer_use_pattern_matching()

    form do
      <<0x47, 0x49, 0x46, _ignore>>
    end

    form do
      <<0x47, 0x49, 0x46>>
    end

    form do
      <<0x47::8, 0x49::8, 0x46::8, _ignore>>
    end

    form do
      <<0x47::8, 0x49::8, 0x46::8>>
    end

    form do
      <<0x47::size(8), 0x49::size(8), 0x46::size(8), _ignore>>
    end

    form do
      <<0x47::size(8), 0x49::size(8), 0x46::size(8)>>
    end
  end

  feature "use pattern matching for exe" do
    type :essential
    find :any
    comment Constants.file_sniffer_use_pattern_matching()

    form do
      <<0x7F, 0x45, 0x4C, 0x46, _ignore>>
    end

    form do
      <<0x7F, 0x45, 0x4C, 0x46>>
    end

    form do
      <<0x7F::8, 0x45::8, 0x4C::8, 0x46::8, _ignore>>
    end

    form do
      <<0x7F::8, 0x45::8, 0x4C::8, 0x46::8>>
    end

    form do
      <<0x7F::size(8), 0x45::size(8), 0x4C::size(8), 0x46::size(8), _ignore>>
    end

    form do
      <<0x7F::size(8), 0x45::size(8), 0x4C::size(8), 0x46::size(8)>>
    end
  end
end
