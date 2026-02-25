defmodule Chess do
  @moduledoc """
  Documentation for `Chess`.
  """
  @type color :: :white | :black

  @doc """
  Returns the opposite color of the given color.
  """
  @spec opposite_color(color()) :: color()
  def opposite_color(:white), do: :black
  def opposite_color(:black), do: :white
end
