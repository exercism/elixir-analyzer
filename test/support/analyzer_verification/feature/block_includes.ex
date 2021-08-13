defmodule ElixirAnalyzer.Support.AnalyzerVerification.Feature.BlockIncludes do
  @moduledoc """
  This is an exercise analyzer extension module to test the _block_includes feature
  """

  use ElixirAnalyzer.ExerciseTest

  feature "can detect :ok" do
    type :essential
    comment "cannot detect :ok"

    form do
      _block_includes do
        :ok
      end
    end
  end

  feature "can detect two lines" do
    type :essential
    comment "cannot detect two lines"

    form do
      _block_includes do
        name = "Bob"
        greeting = "hi #{name}"
      end
    end
  end

  feature "can detect pattern matches" do
    type :essential
    comment "cannot detect pattern matches"

    form do
      _block_includes do
        :ok -> "All good"
        _ -> "Whoops"
      end
    end
  end

  feature "can detect functions" do
    type :essential
    comment "cannot detect functions"

    form do
      _block_includes do
        def foo() do
          _ignore
        end

        def bar(_ignore) do
          _ignore
        end
      end
    end
  end

  feature "can detect nested blocks" do
    type :essential
    comment "cannot detect nested blocks"

    form do
      _block_includes do
        def foo() do
          _block_includes do
            name = "Bob"
            greeting = "hi #{name}"
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

      _block_includes do
        :goodbye
      end
    end
  end

  feature "cannot match two blocks in a row on the same level" do
    type :essential
    comment "could use two in a row"

    form do
      _block_includes do
        :hello
      end

      _block_includes do
        :goodbye
      end
    end
  end
end
