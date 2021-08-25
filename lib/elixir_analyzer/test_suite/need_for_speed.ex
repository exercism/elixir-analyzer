defmodule ElixirAnalyzer.TestSuite.NeedForSpeed do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise NeedForSpeed
  """

  alias ElixirAnalyzer.Constants
  use ElixirAnalyzer.ExerciseTest

  feature "IO imports with :only option" do
    type :actionable
    comment Constants.need_for_speed_import_IO_with_only()

    form do
      import IO, only: _ignore
    end
  end

  feature "ANSI imports with :except option" do
    type :actionable
    comment Constants.need_for_speed_import_ANSI_with_except()

    form do
      import IO.ANSI, except: _ignore
    end
  end

  feature "given code wasn't modified" do
    type :informative
    comment Constants.need_for_speed_do_not_modify_code()

    form do
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
  end
end
