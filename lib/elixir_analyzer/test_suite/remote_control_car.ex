defmodule ElixirAnalyzer.TestSuite.RemoteControlCar do
  @moduledoc """
  This is an exercise analyzer extension module for the exercise Remote Control Car
  """

  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTest

  feature "new uses default parameter" do
    find :any
    type :actionable
    comment Constants.remote_control_car_use_default_argument()

    # function header
    form do
      def new(_ignore \\ "none")
    end

    # function without a guard and with a do block
    form do
      def new(_ignore \\ "none") do
        _ignore
      end
    end

    # function with do block
    form do
      def new(_ignore \\ "none") when _ignore do
        _ignore
      end
    end
  end
end
