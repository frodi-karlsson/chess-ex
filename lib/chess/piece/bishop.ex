defmodule Chess.Piece.Bishop do
  @moduledoc """
  The Bishop piece in chess.

  - Moves any number of squares diagonally.
  - Cannot jump over other pieces.
  - Captures by occupying the square of an opponent's piece.
  """
  alias Chess.{Board, Piece, Pos}
  defstruct []

  defimpl Piece do
    def valid_moves(%Chess.Piece.Bishop{}, board, _last_board, pos, color) do
      # directions: absolute diagonal offsets
      directions = [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}]

      Enum.flat_map(directions, fn {dr, df} ->
        slide(board, pos, pos, dr, df, color, [])
      end)
    end

    defp slide(board, original_pos, current_pos, dr, df, color, acc) do
      # Using :white for absolute board indexing
      case Pos.get_plus(current_pos, dr, df, :white) do
        nil ->
          acc

        next_pos ->
          case Board.get_piece(board, next_pos) do
            nil ->
              move = Board.as_unsafe_moved(board, original_pos, next_pos, {:bishop, color})
              slide(board, original_pos, next_pos, dr, df, color, [move | acc])

            {_type, ^color} ->
              acc

            {_type, _other_color} ->
              [Board.as_unsafe_moved(board, original_pos, next_pos, {:bishop, color}) | acc]
          end
      end
    end

    def type(_piece), do: :bishop

    def attacks(_piece, board, pos, color) do
      directions = [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}]

      Enum.flat_map(directions, fn {dr, df} ->
        slide_attacks(board, pos, dr, df, color, [])
      end)
    end

    defp slide_attacks(board, current_pos, dr, df, color, acc) do
      case Pos.get_plus(current_pos, dr, df, :white) do
        nil ->
          acc

        next_pos ->
          case Board.get_piece(board, next_pos) do
            nil -> slide_attacks(board, next_pos, dr, df, color, [next_pos | acc])
            _ -> [next_pos | acc]
          end
      end
    end
  end
end
