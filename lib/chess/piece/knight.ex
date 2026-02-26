defmodule Chess.Piece.Knight do
  @moduledoc """
  The Knight piece in chess.

  - Moves in an "L" shape: two squares in one cardinal direction and then one square perpendicularly.
  - Can jump over other pieces.
  - Captures by occupying the square of an opponent's piece.
  """
  alias Chess.{Board, GameContext, Piece, Pos}
  defstruct []

  defimpl Piece do
    def valid_moves(
          %Chess.Piece.Knight{},
          %GameContext{board: board, active_color: color} = game_context,
          pos
        ) do
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
      |> Enum.filter(&Board.move_safe?(game_context, &1))
    end

    def type(_piece), do: :knight

    def attacks(_piece, %GameContext{active_color: _color}, pos) do
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
