defmodule ElixirAnalyzer.TestSuite.RpgCharacterSheetTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.RpgCharacterSheet

  alias ElixirAnalyzer.Constants

  test_exercise_analysis "example solution",
    comments: [] do
    [
      defmodule RPG.CharacterSheet do
        def welcome() do
          IO.puts("Welcome! Let's fill out your character sheet together.")
        end

        def ask_name() do
          name = IO.gets("What is your character's name?\n")
          String.trim(name)
        end

        def ask_class() do
          name = IO.gets("What is your character's class?\n")
          String.trim(name)
        end

        def ask_level() do
          level = IO.gets("What is your character's level?\n")
          level = String.trim(level)
          String.to_integer(level)
        end

        def run() do
          welcome()
          name = ask_name()
          class = ask_class()
          level = ask_level()

          character = %{
            name: name,
            class: class,
            level: level
          }

          IO.inspect(character, label: "Your character")
        end
      end,
      defmodule RPG.CharacterSheet do
        def welcome() do
          IO.puts("Welcome! Let's fill out your character sheet together.")
        end

        def ask_name() do
          IO.gets("What is your character's name?\n") |> String.trim()
        end

        def ask_class() do
          IO.gets("What is your character's class?\n") |> String.trim()
        end

        def ask_level() do
          IO.gets("What is your character's level?\n") |> String.trim() |> String.to_integer()
        end

        def run() do
          welcome()
          name = ask_name()
          class = ask_class()
          level = ask_level()

          %{
            name: name,
            class: class,
            level: level
          }
          |> IO.inspect(label: "Your character")
        end
      end,
      defmodule RPG.CharacterSheet do
        @moduledoc """
        A collection of functions related to creating a character sheet.
        """

        @doc """
        Prints out the welcome message.
        """
        @spec welcome() :: binary()

        def welcome do
          IO.puts("Welcome! Let's fill out your character sheet together.")
        end

        @doc """
        Gets the character name via input.
        """
        @spec ask_name() :: binary()

        def ask_name do
          ask("What is your character's name?\n")
        end

        @doc """
        Gets the character class via input.
        """
        @spec ask_class() :: binary()

        def ask_class do
          ask("What is your character's class?\n")
        end

        @doc """
        Gets the character's level via input, returns an integer.
        """
        @spec ask_level() :: pos_integer()

        def ask_level do
          "What is your character's level?\n"
          |> ask()
          |> String.to_integer(10)
        end

        @doc """
        Runs the character sheet creation workflow.
        """
        @spec run() :: %{name: binary(), class: binary(), level: pos_integer()}

        def run do
          welcome()

          %{
            name: ask_name(),
            class: ask_class(),
            level: ask_level()
          }
          |> IO.inspect(label: "Your character")
        end

        # Given a question, asks it and trims leading & trailing whitespaces.
        defp ask(question) do
          question
          |> IO.gets()
          |> String.trim()
        end
      end
    ]
  end

  describe "implicit :ok return" do
    test_exercise_analysis "ending with IO.write is not ideal, but allowed",
      comments_exclude: [Constants.rpg_character_sheet_welcome_ends_with_IO_puts()] do
      [
        defmodule RPG.CharacterSheet do
          def welcome() do
            IO.write("Welcome! Let's fill out your character sheet together.\n")
          end
        end
      ]
    end

    test_exercise_analysis "welcome doesn't end with IO.puts or IO write",
      comments_include: [Constants.rpg_character_sheet_welcome_ends_with_IO_puts()] do
      [
        defmodule RPG.CharacterSheet do
          def welcome() do
            IO.puts("Welcome! Let's fill out your character sheet together.")
            :ok
          end
        end,
        defmodule RPG.CharacterSheet do
          def welcome() do
            text = "Welcome! Let's fill out your character sheet together."
            IO.puts(text)
            :ok
          end
        end,
        defmodule RPG.CharacterSheet do
          def welcome() do
            text = "Welcome! Let's fill out your character sheet together."
            IO.write(text <> "\n")
            :ok
          end
        end
      ]
    end
  end

  test_exercise_analysis "run doesn't reuse functions",
    comments_include: [Constants.rpg_character_sheet_run_uses_other_functions()] do
    [
      defmodule RPG.CharacterSheet do
        def run() do
          IO.puts("Welcome! Let's fill out your character sheet together.")
          name = ask_name()
          class = ask_class()
          level = ask_level()

          character = %{
            name: name,
            class: class,
            level: level
          }

          IO.inspect(character, label: "Your character")
        end
      end,
      defmodule RPG.CharacterSheet do
        def run() do
          welcome()

          name =
            IO.gets("What is your character's name?\n")
            |> String.trim()

          class = ask_class()
          level = ask_level()

          character = %{
            name: name,
            class: class,
            level: level
          }

          IO.inspect(character, label: "Your character")
        end
      end,
      defmodule RPG.CharacterSheet do
        def run() do
          welcome()
          name = ask_name()

          class =
            IO.gets("What is your character's class?\n")
            |> String.trim()

          level = ask_level()

          character = %{
            name: name,
            class: class,
            level: level
          }

          IO.inspect(character, label: "Your character")
        end
      end,
      defmodule RPG.CharacterSheet do
        def run() do
          welcome()
          name = ask_name()
          class = ask_class()

          level =
            IO.gets("What is your character's level?\n")
            |> String.trim()
            |> String.to_integer()

          character = %{
            name: name,
            class: class,
            level: level
          }

          IO.inspect(character, label: "Your character")
        end
      end,
      defmodule RPG.CharacterSheet do
        def run() do
          IO.puts("Welcome! Let's fill out your character sheet together.")

          name =
            IO.gets("What is your character's name?\n")
            |> String.trim()

          class =
            IO.gets("What is your character's class?\n")
            |> String.trim()

          level =
            IO.gets("What is your character's level?\n")
            |> String.trim()
            |> String.to_integer()

          character = %{
            name: name,
            class: class,
            level: level
          }

          IO.inspect(character, label: "Your character")
        end
      end
    ]
  end

  test_exercise_analysis "run doesn't end with IO.inspect",
    comments_include: [Constants.rpg_character_sheet_run_ends_with_IO_inspect()] do
    [
      defmodule RPG.CharacterSheet do
        def run() do
          welcome()
          name = ask_name()
          class = ask_class()
          level = ask_level()

          character = %{
            name: name,
            class: class,
            level: level
          }

          IO.puts("Your character: \"#{character}\"")
          character
        end
      end,
      defmodule RPG.CharacterSheet do
        def run() do
          welcome()
          name = ask_name()
          class = ask_class()
          level = ask_level()

          character = %{
            name: name,
            class: class,
            level: level
          }

          IO.inspect(character, label: "Your character")
          character
        end
      end
    ]
  end

  test_exercise_analysis "IO.inspect doesn't use the :label option",
    comments_include: [Constants.rpg_character_sheet_IO_inspect_uses_label()] do
    defmodule RPG.CharacterSheet do
      def run() do
        welcome()
        name = ask_name()
        class = ask_class()
        level = ask_level()

        character = %{
          name: name,
          class: class,
          level: level
        }

        IO.write("Your character: ")
        IO.inspect(character)
      end
    end
  end
end
