defmodule ElixirAnalyzer.TestSuite.RemoteControlCarTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.RemoteControlCar

  alias ElixirAnalyzer.Constants

  test_exercise_analysis "perfect solution",
    comments: [Constants.solution_same_as_exemplar()] do
    defmodule RemoteControlCar do
      @enforce_keys [:nickname]
      defstruct [
        :nickname,
        battery_percentage: 100,
        distance_driven_in_meters: 0
      ]

      def new(nickname \\ "none") do
        %RemoteControlCar{nickname: nickname}
      end

      def display_distance(%RemoteControlCar{distance_driven_in_meters: d}) do
        "#{d} meters"
      end

      def display_battery(%RemoteControlCar{battery_percentage: 0}) do
        "Battery empty"
      end

      def display_battery(%RemoteControlCar{battery_percentage: b}) do
        "Battery at #{b}%"
      end

      def drive(%RemoteControlCar{battery_percentage: b} = r) when b > 0 do
        d = r.distance_driven_in_meters
        %{r | battery_percentage: b - 1, distance_driven_in_meters: d + 20}
      end

      def drive(%RemoteControlCar{} = r), do: r
    end
  end

  test_exercise_analysis "using default arguments for new",
    comments: [] do
    [
      defmodule RemoteControlCar do
        def new(nickname \\ "none") do
          %RemoteControlCar{nickname: nickname}
        end
      end,
      defmodule RemoteControlCar do
        def new(nickname \\ "none")

        def new(nickname) do
          %RemoteControlCar{nickname: nickname}
        end
      end,
      defmodule RemoteControlCar do
        def new(nickname \\ "none") when is_binary(nickname) do
          %RemoteControlCar{nickname: nickname}
        end
      end,
      defmodule RemoteControlCar do
        @default_nickname "none"

        def new(nickname \\ @default_nickname) do
          %RemoteControlCar{nickname: nickname}
        end
      end
    ]
  end

  test_exercise_analysis "not using default arguments for new",
    comments: [Constants.remote_control_car_use_default_argument()] do
    defmodule RemoteControlCar do
      def new() do
        %RemoteControlCar{nickname: "none"}
      end

      def new(nickname) do
        %RemoteControlCar{nickname: nickname}
      end
    end
  end
end
