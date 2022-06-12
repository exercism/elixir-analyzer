defmodule SquareRoot.Cheating do
  def calculate(n) do
    Float.pow(n / 1, 0.5) |> floor()
  end
end
