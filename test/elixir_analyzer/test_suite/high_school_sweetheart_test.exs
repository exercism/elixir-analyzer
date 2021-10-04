defmodule ElixirAnalyzer.TestSuite.HighSchoolSweetheartTest do
  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.HighSchoolSweetheart

  test_exercise_analysis "example solution",
    comments: [] do
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
  end

  describe "function reuse" do
    test_exercise_analysis "HighSchoolSweetheart.initial must call first_letter",
      comments_include: [Constants.high_school_sweetheart_function_reuse()] do
      defmodule HighSchoolSweetheart do
        def initial(name) do
          name
          |> String.trim()
          |> String.first()
          |> String.upcase()
          |> Kernel.<>(".")
        end
      end
    end

    test_exercise_analysis "HighSchoolSweetheart.initials must call initial",
      comments_include: [Constants.high_school_sweetheart_function_reuse()] do
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
      end
    end

    test_exercise_analysis "HighSchoolSweetheart.pair must call initials",
      comments_include: [Constants.high_school_sweetheart_function_reuse()] do
      defmodule HighSchoolSweetheart do
        def pair(full_name1, full_name2) do
          i1 = full_name1
          i2 = full_name2

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
    end
  end
end
