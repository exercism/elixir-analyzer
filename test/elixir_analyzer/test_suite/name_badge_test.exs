defmodule ElixirAnalyzer.ExerciseTest.NameBadgeTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.NameBadge

  test_exercise_analysis "example solution",
    comments: [] do
    [
      defmodule NameBadge do
        def print(id, name, department) do
          department = if department, do: department, else: "owner"
          prefix = if id, do: "[#{id}] - ", else: ""

          prefix <> "#{name} - #{String.upcase(department)}"
        end
      end,
      defmodule NameBadge do
        def print(id, name, department) do
          department =
            if department do
              department
            else
              "owner"
            end

          prefix =
            if id do
              "[#{id}] - "
            else
              ""
            end

          prefix <> "#{name} - #{String.upcase(department)}"
        end
      end,
      defmodule NameBadge do
        def totally_not_if(a, b, c), do: if(a, do: b, else: c)

        def print(id, name, department) do
          department = totally_not_if(department, department, "owner")
          prefix = totally_not_if(id, "[#{id}] - ", "")

          prefix <> "#{name} - #{String.upcase(department)}"
        end
      end,
      defmodule NameBadge do
        def print(id, name, department) do
          department = department || if department == nil, do: "owner"
          prefix = if(id, do: "[#{id}] - ") || ""

          prefix <> "#{name} - #{String.upcase(department)}"
        end
      end
    ]
  end

  describe "forbids solutions without if" do
    test_exercise_analysis "use other conditionals",
      comments: [Constants.name_badge_use_if()] do
      [
        defmodule NameBadge do
          def print(id, name, department) do
            department =
              case department do
                nil -> "owner"
                _ -> department
              end

            prefix =
              case prefix do
                nil -> ""
                _ -> "[#{id}] - "
              end

            prefix <> "#{name} - #{String.upcase(department)}"
          end
        end,
        defmodule NameBadge do
          def print(id, name, department) do
            department =
              cond do
                is_nil(department) -> "owner"
                true -> department
              end

            prefix =
              cond do
                is_nil(prefix) -> ""
                true -> "[#{id}] - "
              end

            prefix <> "#{name} - #{String.upcase(department)}"
          end
        end,
        defmodule NameBadge do
          def print(id, name, department) do
            department = unless department, do: "owner", else: department
            if = unless id, do: "", else: "[#{id}] - "

            if <> "#{name} - #{String.upcase(department)}"
          end
        end,
        defmodule NameBadge do
          def print(id, name, department) do
            department = unless department, do: "owner", else: department
            prefix = unless id, do: "", else: "[#{id}] - "

            prefix <> "#{name} - #{String.upcase(department)}"
          end
        end,
        defmodule NameBadge do
          def totally_not_if(true, a, _b), do: a
          def totally_not_if(false, _a, b), do: b

          def print(id, name, department) do
            department = totally_not_if(department == nil, "owner", department)
            prefix = totally_not_if(id == nil, "", "[#{id}] - ")
            prefix <> "#{name} - #{String.upcase(department)}"
          end
        end,
        defmodule NameBadge do
          def if(true, a, _b), do: a
          def if(false, _a, b), do: b

          def print(id, name, department) do
            department = if(department == nil, "owner", department)
            prefix = if(id == nil, "", "[#{id}] - ")
            prefix <> "#{name} - #{String.upcase(department)}"
          end
        end,
        defmodule NameBadge do
          def print(id, name, nil), do: print(id, name, "owner")

          def print(nil, name, department) do
            "#{name} - #{String.upcase(department)}"
          end

          def print(id, name, department) do
            "[#{id}] - #{name} - #{String.upcase(department)}"
          end
        end
      ]
    end
  end
end
