defmodule Feature.DuplicateFeaturesTest do
  use ExUnit.Case
  alias ElixirAnalyzer.ExerciseTest.Feature.FeatureError

  describe "Catches duplicate forms" do
    test "Same forms" do
      assert_raise FeatureError,
                   "Forms number 1 and 2 of \"feature 1\" compile to the same value.",
                   fn ->
                     defmodule FormFail do
                       use ElixirAnalyzer.ExerciseTest

                       feature "feature 1" do
                         find :any
                         type :actionable
                         comment "feature 1 failed"

                         form do
                           def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
                             _ignore
                           end
                         end

                         form do
                           def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
                             _ignore
                           end
                         end
                       end
                     end
                   end
    end

    test "Same forms spread apart" do
      assert_raise FeatureError,
                   "Forms number 2 and 4 of \"feature 1\" compile to the same value.",
                   fn ->
                     defmodule FormFail do
                       use ElixirAnalyzer.ExerciseTest

                       feature "feature 1" do
                         find :any
                         type :actionable
                         comment "feature 1 failed"

                         form do
                           def foo() do
                             _ignore
                           end
                         end

                         form do
                           def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
                             _ignore
                           end
                         end

                         form do
                           def bar() do
                             _ignore
                           end
                         end

                         form do
                           def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
                             _ignore
                           end
                         end
                       end
                     end
                   end
    end

    test "Catches multiline strings" do
      assert_raise FeatureError,
                   "Forms number 1 and 2 of \"feature 1\" compile to the same value.",
                   fn ->
                     defmodule FormFail do
                       use ElixirAnalyzer.ExerciseTest

                       feature "feature 1" do
                         find :any
                         type :actionable
                         comment "feature 1 failed"

                         form do
                           def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
                             """
                             Hello
                             #{world}
                             """
                           end
                         end

                         form do
                           def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
                             "Hello\n#{world}\n"
                           end
                         end
                       end
                     end
                   end
    end

    test "Catches single line do blocks" do
      assert_raise FeatureError,
                   "Forms number 1 and 2 of \"feature 1\" compile to the same value.",
                   fn ->
                     defmodule FormFail do
                       use ElixirAnalyzer.ExerciseTest

                       feature "feature 1" do
                         find :any
                         type :actionable
                         comment "feature 1 failed"

                         form do
                           def foo(_ignore) do
                             :ok
                           end
                         end

                         form do
                           def foo(_ignore), do: :ok
                         end
                       end
                     end
                   end
    end
  end

  describe "Catches duplicate features" do
    test "Same features" do
      assert_raise FeatureError,
                   "Features \"feature 1\" and \"feature 1\" compile to the same value.",
                   fn ->
                     defmodule FeatureFail do
                       use ElixirAnalyzer.ExerciseTest

                       feature "feature 1" do
                         find :any
                         type :actionable
                         comment "feature 1 failed"

                         form do
                           def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
                             _ignore
                           end
                         end
                       end

                       feature "feature 1" do
                         find :any
                         type :actionable
                         comment "feature 1 failed"

                         form do
                           def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
                             _ignore
                           end
                         end
                       end
                     end
                   end
    end

    test "Features with more than one form" do
      assert_raise FeatureError,
                   "Features \"feature 1\" and \"feature 2\" compile to the same value.",
                   fn ->
                     defmodule FeatureFail do
                       use ElixirAnalyzer.ExerciseTest

                       feature "feature 1" do
                         find :any
                         type :actionable
                         comment "feature 1 failed"

                         form do
                           def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
                             _ignore
                           end
                         end

                         form do
                           @_ignore
                         end
                       end

                       feature "feature 2" do
                         find :any
                         type :actionable
                         comment "feature 2 failed"

                         form do
                           def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
                             _ignore
                           end
                         end

                         form do
                           @_ignore
                         end
                       end
                     end
                   end
    end

    test "Features with more than one form in different order" do
      assert_raise FeatureError,
                   "Features \"feature 1\" and \"feature 2\" compile to the same value.",
                   fn ->
                     defmodule FeatureFail do
                       use ElixirAnalyzer.ExerciseTest

                       feature "feature 1" do
                         find :any
                         type :actionable
                         comment "feature 1 failed"

                         form do
                           def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
                             _ignore
                           end
                         end

                         form do
                           @_ignore
                         end
                       end

                       feature "feature 2" do
                         find :any
                         type :actionable
                         comment "feature 2 failed"

                         form do
                           @_ignore
                         end

                         form do
                           def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
                             _ignore
                           end
                         end
                       end
                     end
                   end
    end

    test "Features with different types are distinct" do
      defmodule FeatureFind do
        use ElixirAnalyzer.ExerciseTest

        feature "feature 1" do
          find :any
          comment "feature 1 failed"

          form do
            @_ignore
          end

          form do
            def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
              _ignore
            end
          end
        end

        feature "feature 2" do
          find :all
          comment "feature 2 failed"

          form do
            @_ignore
          end

          form do
            def add_player(_ignore, _ignore, _ignore \\ @_ignore) do
              _ignore
            end
          end
        end
      end
    end

    test "Features with different depths are distinct" do
      defmodule FeatureDepth do
        use ElixirAnalyzer.ExerciseTest

        feature "feature 1" do
          comment "feature 1 failed"
          depth 1

          form do
            @_ignore
          end
        end

        feature "feature 2" do
          comment "feature 2 failed"
          depth 2

          form do
            @_ignore
          end
        end
      end
    end
  end
end
