defmodule ElixirAnalyzer.TestSuite.RpgCharacterSheet do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise rpg-character-sheet
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants

  feature "welcome ends with IO.puts" do
    type :actionable
    find :any
    depth 1
    comment Constants.rpg_character_sheet_welcome_ends_with_IO_puts()

    form do
      def welcome() do
        _block_ends_with do
          IO.puts(_ignore)
        end
      end
    end

    form do
      def welcome() do
        _block_ends_with do
          IO.write(_ignore)
        end
      end
    end
  end

  assert_call "run uses welcome" do
    type :actionable
    called_fn name: :welcome
    calling_fn module: RPG.CharacterSheet, name: :run
    comment ElixirAnalyzer.Constants.rpg_character_sheet_run_uses_other_functions()
  end

  assert_call "run uses ask_name" do
    type :actionable
    called_fn name: :ask_name
    calling_fn module: RPG.CharacterSheet, name: :run
    comment ElixirAnalyzer.Constants.rpg_character_sheet_run_uses_other_functions()
  end

  assert_call "run uses ask_class" do
    type :actionable
    called_fn name: :ask_class
    calling_fn module: RPG.CharacterSheet, name: :run
    comment ElixirAnalyzer.Constants.rpg_character_sheet_run_uses_other_functions()
  end

  assert_call "run uses ask_level" do
    type :actionable
    called_fn name: :ask_level
    calling_fn module: RPG.CharacterSheet, name: :run
    comment ElixirAnalyzer.Constants.rpg_character_sheet_run_uses_other_functions()
  end

  feature "run ends with IO.inspect" do
    type :essential
    find :one
    depth 1
    comment Constants.rpg_character_sheet_run_ends_with_IO_inspect()

    form do
      def run() do
        _block_ends_with do
          IO.inspect(_ignore)
        end
      end
    end

    form do
      def run() do
        _block_ends_with do
          IO.inspect(_ignore, _ignore)
        end
      end
    end
  end

  feature "IO.inspect uses the :label option" do
    type :essential
    find :all
    depth 1
    comment Constants.rpg_character_sheet_IO_inspect_uses_label()

    form do
      def run() do
        _block_includes do
          IO.inspect(_ignore, label: _ignore)
        end
      end
    end
  end
end
