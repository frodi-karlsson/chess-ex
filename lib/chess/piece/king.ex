alias Chess.{Board, Piece, Pos}

defmodule Piece.King do
  @moduledoc """
  The King piece in chess.

  - Moves one square in any direction.
  - Cannot move into a square that is attacked by an opponent.
  - Castling is not yet implemented.
  """
  defstruct []
end

defimpl Piece, for: Piece.King do
  @impl true
  def valid_moves(%Piece.King{}, board, _last_board, pos, color) do
    directions = [{1, 0}, {-1, 0}, {0, 1}, {0, -1}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}]

    directions
    |> Enum.map(fn {dr, df} -> Pos.get_plus(pos, dr, df, :white) end)
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(fn target_pos ->
      can_move_to?(board, pos, target_pos, color)
    end)
    |> Enum.map(fn target_pos ->
      Board.as_unsafe_moved(board, pos, target_pos, {:king, color})
    end)
  end

  defp can_move_to?(board, original_pos, target_pos, color) do
    case Board.get_piece(board, target_pos) do
      {_type, ^color} ->
        false

      _ ->
        {new_board, _} = Board.as_unsafe_moved(board, original_pos, target_pos, {:king, color})
        !Board.attacked?(new_board, target_pos, Chess.opposite_color(color))
    end
  end

  @impl true
  def type(_piece), do: :king

  @impl true
  def attacks(_piece, _board, pos, _color) do
    directions = [{1, 0}, {-1, 0}, {0, 1}, {0, -1}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}]

    directions
    |> Enum.map(fn {dr, df} -> Pos.get_plus(pos, dr, df, :white) end)
    |> Enum.reject(&is_nil/1)
  end
end
