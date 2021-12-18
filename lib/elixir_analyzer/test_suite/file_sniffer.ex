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
  end
end
