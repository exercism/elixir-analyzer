defmodule ElixirAnalyzer.TestSuite.NeedForSpeedTest do
  use ElixirAnalyzer.ExerciseTestCase,
    exercise_test_module: ElixirAnalyzer.TestSuite.NeedForSpeed

  test_exercise_analysis "perfect solution",
    comments: [] do
    ~S'''
    defmodule NeedForSpeed do
      alias NeedForSpeed.Race
      alias NeedForSpeed.RemoteControlCar, as: Car

      import IO, only: [puts: 1]
      import IO.ANSI, except: [color: 1]

      def print_race(%Race{} = race) do
        puts("""
        🏁 #{race.title} 🏁
        Status: #{Race.display_status(race)}
        Distance: #{Race.display_distance(race)}

        Contestants:
        """)

        race.cars
        |> Enum.sort_by(&(-1 * &1.distance_driven_in_meters))
        |> Enum.with_index()
        |> Enum.each(fn {car, index} -> print_car(car, index + 1) end)
      end

      defp print_car(%Car{} = car, index) do
        color = color(car)

        puts("""
          #{index}. #{color}#{car.nickname}#{default_color()}
          Distance: #{Car.display_distance(car)}
          Battery: #{Car.display_battery(car)}
        """)
      end

      defp color(%Car{} = car) do
        case car.color do
          :red -> red()
          :blue -> cyan()
          :green -> green()
        end
      end
    end
    '''
  end

  test_exercise_analysis "does not import IO with :only",
    comments_include: [Constants.need_for_speed_import_IO_with_only()] do
    [
      defmodule NeedForSpeed do
        alias NeedForSpeed.Race
        alias NeedForSpeed.RemoteControlCar, as: Car

        import IO
      end,
      defmodule NeedForSpeed do
        alias NeedForSpeed.Race
        alias NeedForSpeed.RemoteControlCar, as: Car

        def print_race(%Race{} = race) do
          IO.puts("""
          🏁 #{race.title} 🏁
          Status: #{Race.display_status(race)}
          Distance: #{Race.display_distance(race)}
          Contestants:
          """)

          race.cars
          |> Enum.sort_by(&(-1 * &1.distance_driven_in_meters))
          |> Enum.with_index()
          |> Enum.each(fn {car, index} -> print_car(car, index + 1) end)
        end
      end
    ]
  end

  test_exercise_analysis "does not import IO with :except",
    comments_include: [Constants.need_for_speed_import_ANSI_with_except()] do
    [
      defmodule NeedForSpeed do
        alias NeedForSpeed.Race
        alias NeedForSpeed.RemoteControlCar, as: Car

        import IO, only: [puts: 1]
        import IO.ANSI, only: [red: 0, green: 0, blue: 0, default_color: 0]
      end,
      defmodule NeedForSpeed do
        alias NeedForSpeed.Race
        alias NeedForSpeed.RemoteControlCar, as: Car

        import IO, only: [puts: 1]

        defp print_car(%Car{} = car, index) do
          color = color(car)

          puts("""
            #{index}. #{color}#{car.nickname}#{IO.ANSI.default_color()}
            Distance: #{Car.display_distance(car)}
            Battery: #{Car.display_battery(car)}
          """)
        end

        defp color(%Car{} = car) do
          case car.color do
            :red -> IO.ANSI.red()
            :blue -> IO.ANSI.cyan()
            :green -> IO.ANSI.green()
          end
        end
      end
    ]
  end

  test_exercise_analysis "modifies code",
    comments: [Constants.need_for_speed_do_not_modify_code()] do
    [
      defmodule NeedForSpeed do
        alias NeedForSpeed.Race
        alias NeedForSpeed.RemoteControlCar, as: Car

        import IO, only: [puts: 1]
        import IO.ANSI, except: [color: 1]

        def print_race(%Race{} = race) do
          puts("""
          🏁 #{race.title} 🏁
          Status: #{Race.display_status(race)}
          Distance: #{Race.display_distance(race)}
          Contestants:
          """)

          race.cars
          # small change here
          |> Enum.sort_by(&(0 - &1.distance_driven_in_meters))
          |> Enum.with_index()
          |> Enum.each(fn {car, index} -> print_car(car, index + 1) end)
        end

        defp print_car(%Car{} = car, index) do
          color = color(car)

          puts("""
            #{index}. #{color}#{car.nickname}#{default_color()}
            Distance: #{Car.display_distance(car)}
            Battery: #{Car.display_battery(car)}
          """)
        end

        defp color(%Car{} = car) do
          case car.color do
            :red -> red()
            :blue -> cyan()
            :green -> green()
          end
        end
      end,
      defmodule NeedForSpeed do
        alias NeedForSpeed.Race
        alias NeedForSpeed.RemoteControlCar, as: Car

        import IO, only: [puts: 1]
        import IO.ANSI, except: [color: 1]

        def print_race(%Race{} = race) do
          puts("""
          🏁 #{race.title} 🏁
          Status: #{Race.display_status(race)}
          Distance: #{Race.display_distance(race)}
          Contestants:
          """)

          race.cars
          |> Enum.sort_by(&(-1 * &1.distance_driven_in_meters))
          |> Enum.with_index()
          |> Enum.each(fn {car, index} -> print_car(car, index + 1) end)
        end

        defp print_car(%Car{} = car, index) do
          color = color(car)

          puts("""
            #{index}. #{color}#{car.nickname}#{default_color()}
            Distance: #{Car.display_distance(car)}
            Battery: #{Car.display_battery(car)}
          """)
        end

        defp color(%Car{} = car) do
          case car.color do
            # swap order here
            :green -> green()
            :blue -> cyan()
            :red -> red()
          end
        end
      end
    ]
  end
end
