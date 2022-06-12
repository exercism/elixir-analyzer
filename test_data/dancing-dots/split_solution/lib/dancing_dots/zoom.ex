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
