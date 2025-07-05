defmodule ElixirAnalyzer.TestSuite.HighSchoolSweetheartTest do
  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.HighSchoolSweetheart

  test_exercise_analysis "example solution",
    comments: [ElixirAnalyzer.Constants.solution_same_as_exemplar()] do
    ~S'''
    defmodule HighSchoolSweetheart do
      def first_letter(name) do
        name
        |> String.trim()
        |> String.first()
      end

      def initial(name) do
        name
        |> first_letter()
        |> String.upcase()
        |> Kernel.<>(".")
      end

      def initials(full_name) do
        [first_name, last_name] = String.split(full_name)
        "#{initial(first_name)} #{initial(last_name)}"
      end

      def pair(full_name1, full_name2) do
        i1 = initials(full_name1)
        i2 = initials(full_name2)

        """
        ❤-------------------❤
        |  #{i1}  +  #{i2}  |
        ❤-------------------❤
        """
      end
    end
    '''
  end

  test_exercise_analysis "other solution",
    comments: [] do
    # https://exercism.org/tracks/elixir/exercises/high-school-sweetheart/solutions/kavu
    ~S'''
    defmodule HighSchoolSweetheart do
      def first_letter(name), do: name |> String.trim() |> String.first()
      def initial(name), do: name |> first_letter |> String.upcase() |> Kernel.<>(".")

      def initials(full_name),
        do: full_name |> String.split() |> Enum.map(&initial/1) |> Enum.join(" ")

      def pair(full_name1, full_name2) do
        first_initials = initials(full_name1)
        second_initials = initials(full_name2)

        """
             ******       ******
           **      **   **      **
         **         ** **         **
        **            *            **
        **                         **
        **     #{first_initials}  +  #{second_initials}     **
         **                       **
           **                   **
             **               **
               **           **
                 **       **
                   **   **
                     ***
                      *
        """
      end
    end
    '''
  end

  describe "function reuse" do
    test_exercise_analysis "detects lack of reuse in all cases",
      comments_include: [Constants.high_school_sweetheart_function_reuse()] do
      [
        defmodule HighSchoolSweetheart do
          def initial(name) do
            name
            |> String.trim()
            |> String.first()
            |> String.upcase()
            |> Kernel.<>(".")
          end
        end,
        defmodule HighSchoolSweetheart do
          def initials(full_name) do
            [first_name, last_name] = String.split(full_name)

            first_name =
              first_name
              |> first_letter()
              |> String.upcase()
              |> Kernel.<>(".")

            last_name =
              last_name
              |> first_letter()
              |> String.upcase()
              |> Kernel.<>(".")

            "#{first_name} #{last_name}"
          end
        end,
        defmodule HighSchoolSweetheart do
          def first_letter(name) do
            name
            |> String.trim()
            |> String.first()
          end

          def initial(name) do
            name
            |> first_letter()
            |> String.upcase()
            |> Kernel.<>(".")
          end

          def pair(full_name1, full_name2) do
            [first_name, last_name] = String.split(full_name1)
            i1 = "#{initial(first_name)} #{initial(last_name)}"

            [first_name, last_name] = String.split(full_name2)
            i2 = "#{initial(first_name)} #{initial(last_name)}"

            """
                 ******       ******
               **      **   **      **
             **         ** **         **
            **            *            **
            **                         **
            **     #{i1}  +  #{i2}     **
             **                       **
               **                   **
                 **               **
                   **           **
                     **       **
                       **   **
                         ***
                          *
            """
          end
        end
      ]
    end
  end

  describe "multiline string" do
    test_exercise_analysis "accepts different ways of writing multiline strings with interpolation",
      comments_exclude: [Constants.high_school_sweetheart_multiline_string()] do
      [
        ~S'''
        def pair(full_name1, full_name2) do
          i1 = initials(full_name1)
          i2 = initials(full_name2)
          """
               ******       ******
             **      **   **      **
           **         ** **         **
          **            *            **
          **                         **
          **     #{i1}  +  #{i2}     **
           **                       **
             **                   **
               **               **
                 **           **
                   **       **
                     **   **
                       ***
                        *
          """
        end
        ''',
        ~S'''
        def pair(full_name1, full_name2) do
          ~s"""
               ******       ******
             **      **   **      **
           **         ** **         **
          **            *            **
          **                         **
          **     #{initials(full_name1)}  +  #{initials(full_name2)}     **
           **                       **
             **                   **
               **               **
                 **           **
                   **       **
                     **   **
                       ***
                        *
          """
        end
        ''',
        ~S"""
        def pair(full_name1, full_name2) do
          i1 = initials(full_name1)
          i2 = initials(full_name2)
          '''
               ******       ******
             **      **   **      **
           **         ** **         **
          **            *            **
          **                         **
          **     #{i1}  +  #{i2}     **
           **                       **
             **                   **
               **               **
                 **           **
                   **       **
                     **   **
                       ***
                        *
          '''
        end
        """,
        ~S"""
        def pair(full_name1, full_name2) do
          x1 = initials(full_name1)
          x2 = initials(full_name2)
          ~s'''
               ******       ******
             **      **   **      **
           **         ** **         **
          **            *            **
          **                         **
          **     #{x1}  +  #{x2}     **
           **                       **
             **                   **
               **               **
                 **           **
                   **       **
                     **   **
                       ***
                        *
          '''
        end
        """
      ]
    end

    test_exercise_analysis "doesn't care if the string is weirdly split",
      comments_exclude: [Constants.high_school_sweetheart_multiline_string()] do
      ~S'''
      def pair(full_name1, full_name2) do
        i1 = initials(full_name1)
        i2 = initials(full_name2)

        """
             ******       ******
           **      **   **      **
         **         ** **         **
        **            *            **
        **                         **
        """ <>
          "**     #{i1}  +  #{i2}     **" <>
          """

           **                       **
             **                   **
               **               **
                 **           **
                   **       **
                     **   **
                       ***
                        *
          """
      end
      '''
    end

    test_exercise_analysis "correctly detects multiline string in 'one line' function",
      comments_exclude: [Constants.high_school_sweetheart_multiline_string()] do
      ~S'''
      def pair(full_name1, full_name2), do:
        """
             ******       ******
           **      **   **      **
         **         ** **         **
        **            *            **
        **                         **
        **     #{initials(full_name1)}  +  #{initials(full_name2)}     **
         **                       **
           **                   **
             **               **
               **           **
                 **       **
                   **   **
                     ***
                      *
        """
      '''
    end

    test_exercise_analysis "detects lack of multiline strings",
      comments_include: [Constants.high_school_sweetheart_multiline_string()] do
      [
        defmodule HighSchoolSweetheart do
          def pair(full_name1, full_name2) do
            i1 = initials(full_name1)
            i2 = initials(full_name2)

            "     ******       ******\n   **      **   **      **\n **         ** **         **\n**            *            **\n**                         **\n**     #{i1}  +  #{i2}     **\n **                       **\n   **                   **\n     **               **\n       **           **\n         **       **\n           **   **\n             ***\n              *\n"
          end
        end,
        defmodule HighSchoolSweetheart do
          def pair(full_name1, full_name2),
            do:
              "     ******       ******\n   **      **   **      **\n **         ** **         **\n**            *            **\n**                         **\n**     #{initials(full_name1)}  +  #{initials(full_name2)}     **\n **                       **\n   **                   **\n     **               **\n       **           **\n         **       **\n           **   **\n             ***\n              *\n"
        end
      ]
    end

    test_exercise_analysis "gets fooled by documentation",
      comments_exclude: [Constants.high_school_sweetheart_multiline_string()] do
      ~S'''
      @moduledoc """
      Exercism exercise solution
      """
      @typedoc """
      I am a rebel and I don't want to accept that the string() type is not a string
      so I am defining my own string type!
      """
      @type str :: binary()
      @doc """
      draws a heart
      """
      def pair(full_name1, full_name2) do
        i1 = initials(full_name1)
        i2 = initials(full_name2)

        "     ******       ******\n   **      **   **      **\n **         ** **         **\n**            *            **\n**                         **\n**     #{i1}  +  #{i2}     **\n **                       **\n   **                   **\n     **               **\n       **           **\n         **       **\n           **   **\n             ***\n              *\n"
      end
      '''
    end
  end
end
