alias Chess.{Board, Piece, Pos}

defmodule Piece.Queen do
  @moduledoc """
  The Queen piece in chess.

  - Moves any number of squares along a rank, file, or diagonal.
  - Cannot jump over other pieces.
  - Captures by occupying the square of an opponent's piece.
  """
  defstruct []
end

defimpl Piece, for: Piece.Queen do
  @impl true
  def valid_moves(%Piece.Queen{}, board, _last_board, pos, color) do
    # directions: 4 orthogonal + 4 diagonal
    directions = [
      {1, 0},
      {-1, 0},
      {0, 1},
      {0, -1},
      {1, 1},
      {1, -1},
      {-1, 1},
      {-1, -1}
    ]

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
            move = Board.as_unsafe_moved(board, original_pos, next_pos, {:queen, color})
            slide(board, original_pos, next_pos, dr, df, color, [move | acc])

          {_type, ^color} ->
            acc

          {_type, _other_color} ->
            [Board.as_unsafe_moved(board, original_pos, next_pos, {:queen, color}) | acc]
        end
    end
  end

  @impl true
  def type(_piece), do: :queen

  @impl true
  def attacks(_piece, board, pos, color) do
    # directions: 4 orthogonal + 4 diagonal
    directions = [
      {1, 0},
      {-1, 0},
      {0, 1},
      {0, -1},
      {1, 1},
      {1, -1},
      {-1, 1},
      {-1, -1}
    ]

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
