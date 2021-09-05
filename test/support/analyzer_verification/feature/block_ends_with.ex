defmodule ElixirAnalyzer.Support.AnalyzerVerification.Feature.BlockEndsWith do
  @moduledoc """
  This is an exercise analyzer extension module to test the _block_ends_with feature
  """

  use ElixirAnalyzer.ExerciseTest

  feature "can detect :ok" do
    type :essential
    comment "cannot detect :ok"

    form do
      _block_ends_with do
        :ok
      end
    end
  end

  feature "can detect two lines" do
    type :essential
    comment "cannot detect two lines"

    form do
      _block_ends_with do
        name = "Bob"
        greeting = "hi #{name}"
      end
    end
  end

  feature "can detect pattern matches" do
    type :essential
    comment "cannot detect pattern matches"

    form do
      _block_ends_with do
        :ok -> "All good"
        _ -> "Whoops"
      end
    end
  end

  feature "can detect functions" do
    type :essential
    comment "cannot detect functions"

    form do
      _block_ends_with do
        def foo() do
          _ignore
        end

        def bar(_ignore) do
          _ignore
        end
      end
    end
  end

  feature "can detect a block finishing on a function" do
    type :essential
    comment "cannot detect a block finishing on a function"

    form do
      def foo() do
        _block_ends_with do
          final_function(_ignore)
        end
      end
    end
  end

  feature "can detect nested blocks" do
    type :essential
    comment "cannot detect nested blocks"

    form do
      defmodule _ignore do
        _block_ends_with do
          def foo() do
            _block_ends_with do
              name = "Bob"
              greeting = "hi #{name}"
            end
          end
        end
      end
    end
  end

  feature "cannot match a line and a block on the same level" do
    type :essential
    comment "could match a line and a block in a row"

    form do
      :hello

      _block_ends_with do
        :goodbye
      end
    end
  end

  feature "cannot match two blocks in a row on the same level" do
    type :essential
    comment "could use two in a row"

    form do
      _block_ends_with do
        :hello
      end

      _block_ends_with do
        :goodbye
      end
    end
  end

  feature "should not use _block_ends_with with a single line without context" do
    type :essential
    comment "without context: could not match :done"

    form do
      _block_ends_with do
        :done
      end
    end
  end

  feature "should use _block_ends_with with a single line with a context" do
    type :essential
    comment "with context: could not match :done"

    form do
      def foo() do
        _block_ends_with do
          :done
        end
      end
    end
  end
end
