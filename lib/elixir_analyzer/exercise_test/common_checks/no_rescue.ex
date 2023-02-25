# credo:disable-for-this-file Credo.Check.Refactor.LongQuoteBlocks

defmodule ElixirAnalyzer.ExerciseTest.CommonChecks.NoRescue do
  @moduledoc """
  This is an exercise analyzer extension module used for common tests looking for the usage of `rescue`
  """

  alias ElixirAnalyzer.Constants

  defmacro __using__(_opts) do
    quote do
      feature Constants.solution_no_rescue() do
        type :essential
        comment Constants.solution_no_rescue()
        find :none

        # try ------------------------------------------------------------------------
        form do
          try do
            _ignore
          rescue
            _ignore
          end
        end

        form do
          try do
            _ignore
          rescue
            _ignore
          else
            _ignore
          end
        end

        form do
          try do
            _ignore
          rescue
            _ignore
          after
            _ignore
          end
        end

        form do
          try do
            _ignore
          rescue
            _ignore
          else
            _ignore
          after
            _ignore
          end
        end

        form do
          try do
            _ignore
          rescue
            _ignore
          after
            _ignore
          else
            _ignore
          end
        end

        # def ------------------------------------------------------------------------

        form do
          def _ignore do
            _ignore
          rescue
            _ignore
          end
        end

        form do
          def _ignore do
            _ignore
          rescue
            _ignore
          else
            _ignore
          end
        end

        form do
          def _ignore do
            _ignore
          rescue
            _ignore
          after
            _ignore
          end
        end

        form do
          def _ignore do
            _ignore
          rescue
            _ignore
          else
            _ignore
          after
            _ignore
          end
        end

        form do
          def _ignore do
            _ignore
          rescue
            _ignore
          after
            _ignore
          else
            _ignore
          end
        end

        # defp -----------------------------------------------------------------------

        form do
          defp _ignore do
            _ignore
          rescue
            _ignore
          end
        end

        form do
          defp _ignore do
            _ignore
          rescue
            _ignore
          else
            _ignore
          end
        end

        form do
          defp _ignore do
            _ignore
          rescue
            _ignore
          after
            _ignore
          end
        end

        form do
          defp _ignore do
            _ignore
          rescue
            _ignore
          else
            _ignore
          after
            _ignore
          end
        end

        form do
          defp _ignore do
            _ignore
          rescue
            _ignore
          after
            _ignore
          else
            _ignore
          end
        end
      end
    end
  end
end
