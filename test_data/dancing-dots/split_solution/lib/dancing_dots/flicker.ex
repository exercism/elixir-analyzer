defmodule DancingDots.Flicker do
  use DancingDots.Animation

  @impl DancingDots.Animation
  def handle_frame(dot, frame_number, _opts) do
    opacity = if rem(frame_number, 4) == 0, do: dot.opacity / 2, else: dot.opacity
    %{dot | opacity: opacity}
  end
end
