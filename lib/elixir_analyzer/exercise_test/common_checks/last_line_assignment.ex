defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.LastLineAssignment do
  @moduledoc """
  This is an exercise analyzer extension module used for common tests looking for assignments
  on the last line of function definitions
  """

  alias ElixirAnalyzer.Constants

  defmacro __using__(_opts) do
    quote do
      feature Constants.solution_last_line_assignment() do
        type :informative
        comment Constants.solution_last_line_assignment()
        find :none

        form do
          def _ignore do
            _block_ends_with do
              _ignore = _ignore
            end
          end
        end

        form do
          defp _ignore do
            _block_ends_with do
              _ignore = _ignore
            end
          end
        end

        form do
          defmacro _ignore do
            _block_ends_with do
              _ignore = _ignore
            end
          end
        end

        form do
          defmacrop _ignore do
            _block_ends_with do
              _ignore = _ignore
            end
          end
        end
      end
    end
  end
end
