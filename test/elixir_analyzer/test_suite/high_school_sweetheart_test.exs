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
end
