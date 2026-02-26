defmodule Chess.Piece.Knight do
  @moduledoc """
  The Knight piece in chess.

  - Moves in an "L" shape: two squares in one cardinal direction and then one square perpendicularly.
  - Can jump over other pieces.
  - Captures by occupying the square of an opponent's piece.
  """
  alias Chess.{Board, Piece, Pos}
  defstruct []

  defimpl Piece do
    def valid_moves(%Chess.Piece.Knight{}, board, _last_board, pos, color) do
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

    def type(_piece), do: :knight

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
end
