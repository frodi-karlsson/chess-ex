alias Chess.{Board, Piece, Pos}

defmodule Piece.Knight do
  @moduledoc """
  The Knight piece in chess.

  - Moves in an "L" shape: two squares in one cardinal direction and then one square perpendicularly.
  - Can jump over other pieces.
  - Captures by occupying the square of an opponent's piece.
  """
  defstruct []
end

defimpl Piece, for: Piece.Knight do
  @impl true
  def valid_moves(%Piece.Knight{}, board, _last_board, pos, color) do
    # L-shape offsets
    offsets = [
      {2, 1},
      {2, -1},
      {-2, 1},
      {-2, -1},
      {1, 2},
      {1, -2},
      {-1, 2},
      {-1, -2}
    ]

    offsets
    |> Enum.map(fn {dr, df} -> Pos.get_plus(pos, dr, df, :white) end)
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(fn target_pos ->
      case Board.get_piece(board, target_pos) do
        nil -> true
        {_type, piece_color} -> piece_color != color
      end
    end)
    |> Enum.map(fn target_pos ->
      Board.as_unsafe_moved(board, pos, target_pos, {:knight, color})
    end)
  end

  @impl true
  def type(_piece), do: :knight

  @impl true
  def attacks(_piece, _board, pos, _color) do
    # L-shape offsets
    offsets = [
      {2, 1},
      {2, -1},
      {-2, 1},
      {-2, -1},
      {1, 2},
      {1, -2},
      {-1, 2},
      {-1, -2}
    ]

    offsets
    |> Enum.map(fn {dr, df} -> Pos.get_plus(pos, dr, df, :white) end)
    |> Enum.reject(&is_nil/1)
  end
end
