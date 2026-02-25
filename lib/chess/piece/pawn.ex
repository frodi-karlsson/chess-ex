alias Chess.{Piece, Board, Pos}

defmodule Piece.Pawn do
  @moduledoc """
  The Pawn piece in chess.

   - Moves forward one square, with the option to move two squares if it is the pawn's first move.
   - Captures diagonally forward one square.
   - When a pawn reaches the opposite end of the board, it can be promoted to any other piece (except a king).
   - En passant: a special capture that can occur immediately after a pawn moves two squares forward from its starting position, and an opponent's pawn could have captured it had it moved only one square forward.
  """
  defstruct []
end

defimpl Piece, for: Piece.Pawn do
  @impl true
  def valid_moves(%Chess.Piece.Pawn{}, board, last_board, pos, color) do
    forward_moves(board, pos, color) ++
      capture_moves(board, pos, color) ++
      promotion_moves(board, pos, color) ++
      en_passant_moves(board, last_board, pos, color)
  end

  defp en_passant_moves(board, last_board, pos, color) do
    left_opponent_pawn_pos = Pos.get_plus(pos, 0, -1, color)
    right_opponent_pawn_pos = Pos.get_plus(pos, 0, 1, color)

    [left_opponent_pawn_pos, right_opponent_pawn_pos]
    |> Enum.filter(fn opponent_pos ->
      opponent_pos && Board.get_piece(board, opponent_pos) == {:pawn, Chess.opposite_color(color)} &&
        last_board && Board.get_piece(last_board, opponent_pos) == nil
    end)
    |> Enum.map(fn opponent_pos ->
      capture_pos = Pos.get_plus(opponent_pos, 1, 0, color)

      # Remove the captured pawn manually, as it's not at the capture_pos
      new_board =
        board
        |> List.update_at(opponent_pos.rank, fn rank ->
          List.update_at(rank, opponent_pos.file, fn _ -> nil end)
        end)

      Board.as_unsafe_moved(new_board, pos, capture_pos, {:pawn, color})
    end)
  end

  defp promotion_moves(board, pos, color) do
    forward = Pos.get_plus(pos, 1, 0, color)
    promotion_rank = if color == :white, do: 0, else: 7

    if forward && Board.get_piece(board, forward) == nil && forward.rank == promotion_rank do
      [:queen, :rook, :bishop, :knight]
      |> Enum.map(fn piece_type ->
        Board.as_unsafe_moved(board, pos, forward, {piece_type, color})
      end)
    else
      []
    end
  end

  defp capture_moves(board, pos, color) do
    left_capture = Pos.get_plus(pos, 1, -1, color)
    right_capture = Pos.get_plus(pos, 1, 1, color)
    promotion_rank = if color == :white, do: 0, else: 7

    [left_capture, right_capture]
    |> Enum.filter(fn capture_pos ->
      if capture_pos do
        piece = Board.get_piece(board, capture_pos)
        piece && elem(piece, 1) != color
      else
        false
      end
    end)
    |> Enum.flat_map(fn capture_pos ->
      if capture_pos.rank == promotion_rank do
        [:queen, :rook, :bishop, :knight]
        |> Enum.map(fn piece_type ->
          Board.as_unsafe_moved(board, pos, capture_pos, {piece_type, color})
        end)
      else
        [Board.as_unsafe_moved(board, pos, capture_pos, {:pawn, color})]
      end
    end)
  end

  defp forward_moves(board, pos, color) do
    one_step = Pos.get_plus(pos, 1, 0, color)
    two_steps = Pos.get_plus(pos, 2, 0, color)

    starting_rank = if color == :white, do: 6, else: 1
    promotion_rank = if color == :white, do: 0, else: 7

    if one_step && Board.get_piece(board, one_step) == nil && one_step.rank != promotion_rank do
      res = [Board.as_unsafe_moved(board, pos, one_step, {:pawn, color})]

      if pos.rank == starting_rank && two_steps && Board.get_piece(board, two_steps) == nil do
        res ++ [Board.as_unsafe_moved(board, pos, two_steps, {:pawn, color})]
      else
        res
      end
    else
      []
    end
  end

  @impl true
  def type(_piece) do
    :pawn
  end
end
