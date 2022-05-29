defmodule ElixirAnalyzer.TestSuite.DancingDotsTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.DancingDots

  test_exercise_analysis "example solution",
    comments: [ElixirAnalyzer.Constants.solution_same_as_exemplar()] do
    ~S"""
    defmodule DancingDots.Animation do
      @type dot :: DancingDots.Dot.t()
      @type opts :: keyword
      @type error :: any
      @type frame_number :: pos_integer

      @callback init(opts :: opts) :: {:ok, opts} | {:error, error}
      @callback handle_frame(dot :: dot, n :: frame_number, opts :: opts) :: dot

      defmacro __using__(_) do
        quote do
          @behaviour DancingDots.Animation
          def init(opts), do: {:ok, opts}
          defoverridable init: 1
        end
      end
    end

    defmodule DancingDots.Flicker do
      use DancingDots.Animation

      @impl DancingDots.Animation
      def handle_frame(dot, frame_number, _opts) do
        opacity = if rem(frame_number, 4) == 0, do: dot.opacity / 2, else: dot.opacity
        %{dot | opacity: opacity}
      end
    end

    defmodule DancingDots.Zoom do
      use DancingDots.Animation

      @impl DancingDots.Animation
      def init(opts) do
        velocity = Keyword.get(opts, :velocity)

        if is_number(velocity) do
          {:ok, [velocity: velocity]}
        else
          {:error,
           "The :velocity option is required, and its value must be a number. Got: #{inspect(velocity)}"}
        end
      end

      @impl DancingDots.Animation
      def handle_frame(dot, frame_number, opts) do
        %{dot | radius: dot.radius + opts[:velocity] * (frame_number - 1)}
      end
    end
    """
  end

  describe "DancingDots.Flicker shouldn't reimplement init/1" do
    test_exercise_analysis "reimplementing init in various ways triggers the check",
      comments_include: [Constants.dancing_dots_do_not_reimplement_init()] do
      [
        defmodule DancingDots.Flicker do
          use DancingDots.Animation

          @impl DancingDots.Animation
          def handle_frame(dot, frame_number, _opts) do
            opacity = if rem(frame_number, 4) == 0, do: dot.opacity / 2, else: dot.opacity
            %{dot | opacity: opacity}
          end

          def init(opts), do: {:ok, opts}
        end,
        defmodule DancingDots.Flicker do
          use DancingDots.Animation

          @impl DancingDots.Animation
          def init(x) do
            _unrelated_statement = []
            {:ok, x}
          end

          @impl DancingDots.Animation
          def handle_frame(dot, frame_number, _opts) do
            opacity = if rem(frame_number, 4) == 0, do: dot.opacity / 2, else: dot.opacity
            %{dot | opacity: opacity}
          end
        end,
        defmodule DancingDots.Flicker do
          use DancingDots.Animation

          defp helper1, do: 1

          def init(x) do
            _unrelated_statement = []
            y = x
            {:ok, y}
          end

          defp helper2, do: 2
        end
      ]
    end
  end

  describe "must annotate with `@impl DancingDots.Animation`" do
    test_exercise_analysis "forgot `@impl` entirely",
      comments_include: [Constants.dancing_dots_annotate_impl_animation()] do
      defmodule DancingDots.Flicker do
        use DancingDots.Animation

        def handle_frame(dot, frame_number, _opts) do
          opacity = if rem(frame_number, 4) == 0, do: dot.opacity / 2, else: dot.opacity
          %{dot | opacity: opacity}
        end
      end
    end

    test_exercise_analysis "value must be a module",
      comments_include: [Constants.dancing_dots_annotate_impl_animation()] do
      defmodule DancingDots.Flicker do
        use DancingDots.Animation

        @impl true
        def handle_frame(dot, frame_number, _opts) do
          opacity = if rem(frame_number, 4) == 0, do: dot.opacity / 2, else: dot.opacity
          %{dot | opacity: opacity}
        end
      end
    end

    test_exercise_analysis "alias works",
      comments_exclude: [Constants.dancing_dots_annotate_impl_animation()] do
      [
        defmodule DancingDots.Flicker do
          alias DancingDots.Animation
          use Animation

          @impl Animation
          def handle_frame(dot, frame_number, _opts) do
            opacity = if rem(frame_number, 4) == 0, do: dot.opacity / 2, else: dot.opacity
            %{dot | opacity: opacity}
          end
        end,
        defmodule DancingDots.Flicker do
          alias DancingDots.Animation, as: A
          use A

          @impl A
          def handle_frame(dot, frame_number, _opts) do
            opacity = if rem(frame_number, 4) == 0, do: dot.opacity / 2, else: dot.opacity
            %{dot | opacity: opacity}
          end
        end
      ]
    end

    test_exercise_analysis "unrelated alias doesn't fool the analyzer",
      comments_include: [Constants.dancing_dots_annotate_impl_animation()] do
      [
        defmodule DancingDots.Flicker do
          alias Genserver, as: Animation
          use DancingDots.Animation

          @impl Animation
          def handle_frame(dot, frame_number, _opts) do
            opacity = if rem(frame_number, 4) == 0, do: dot.opacity / 2, else: dot.opacity
            %{dot | opacity: opacity}
          end
        end,
        defmodule DancingDots.Flicker do
          alias OtherModule.Animation
          use DancingDots.Animation

          @impl Animation
          def handle_frame(dot, frame_number, _opts) do
            opacity = if rem(frame_number, 4) == 0, do: dot.opacity / 2, else: dot.opacity
            %{dot | opacity: opacity}
          end
        end
      ]
    end

    test_exercise_analysis "non-callback helpers do not trigger the check",
      comments_exclude: [Constants.dancing_dots_annotate_impl_animation()] do
      defmodule DancingDots.Flicker do
        use DancingDots.Animation

        def helper(dot) do
          dot
        end
      end
    end

    test_exercise_analysis "must be used for all callbacks",
      comments_include: [Constants.dancing_dots_annotate_impl_animation()] do
      [
        defmodule DancingDots.Zoom do
          use DancingDots.Animation

          @impl DancingDots.Animation
          def init(opts) do
            velocity = Keyword.get(opts, :velocity)

            if is_number(velocity) do
              {:ok, [velocity: velocity]}
            else
              {:error,
               "The :velocity option is required, and its value must be a number. Got: #{inspect(velocity)}"}
            end
          end

          def handle_frame(dot, frame_number, opts) do
            %{dot | radius: dot.radius + opts[:velocity] * (frame_number - 1)}
          end
        end,
        defmodule DancingDots.Zoom do
          use DancingDots.Animation

          def init(opts) do
            velocity = Keyword.get(opts, :velocity)

            if is_number(velocity) do
              {:ok, [velocity: velocity]}
            else
              {:error,
               "The :velocity option is required, and its value must be a number. Got: #{inspect(velocity)}"}
            end
          end

          @impl DancingDots.Animation
          def handle_frame(dot, frame_number, opts) do
            %{dot | radius: dot.radius + opts[:velocity] * (frame_number - 1)}
          end
        end,
        ~S"""
        defmodule DancingDots.Flicker do
        use DancingDots.Animation

          def handle_frame(dot, frame_number, _opts) do
            opacity = if rem(frame_number, 4) == 0, do: dot.opacity / 2, else: dot.opacity
            %{dot | opacity: opacity}
          end
        end

        defmodule DancingDots.Zoom do
          use DancingDots.Animation

          @impl DancingDots.Animation
          def init(opts) do
            velocity = Keyword.get(opts, :velocity)

            if is_number(velocity) do
              {:ok, [velocity: velocity]}
            else
              {:error,
                "The :velocity option is required, and its value must be a number. Got: #{inspect(velocity)}"}
            end
          end

          @impl DancingDots.Animation
          def handle_frame(dot, frame_number, opts) do
            %{dot | radius: dot.radius + opts[:velocity] * (frame_number - 1)}
          end
        end
        """
      ]
    end
  end
end
