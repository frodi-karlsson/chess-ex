alias Chess.{Board, Piece, Pos}

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
      new_board = remove_piece(board, opponent_pos)
      Board.as_unsafe_moved(new_board, pos, capture_pos, {:pawn, color})
    end)
  end

  defp remove_piece(board, pos) do
    List.update_at(board, pos.rank, fn rank ->
      List.update_at(rank, pos.file, fn _ -> nil end)
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
      capture_pos && enemy_piece?(board, capture_pos, color)
    end)
    |> Enum.flat_map(fn capture_pos ->
      generate_capture_moves(board, pos, capture_pos, color, promotion_rank)
    end)
  end

  defp enemy_piece?(board, pos, color) do
    case Board.get_piece(board, pos) do
      nil -> false
      {_type, piece_color} -> piece_color != color
    end
  end

  defp generate_capture_moves(board, pos, capture_pos, color, promotion_rank) do
    if capture_pos.rank == promotion_rank do
      [:queen, :rook, :bishop, :knight]
      |> Enum.map(fn piece_type ->
        Board.as_unsafe_moved(board, pos, capture_pos, {piece_type, color})
      end)
    else
      [Board.as_unsafe_moved(board, pos, capture_pos, {:pawn, color})]
    end
  end

  defp forward_moves(board, pos, color) do
    one_step = Pos.get_plus(pos, 1, 0, color)
    two_steps = Pos.get_plus(pos, 2, 0, color)

    starting_rank = if color == :white, do: 6, else: 1
    promotion_rank = if color == :white, do: 0, else: 7

    if one_step && Board.get_piece(board, one_step) == nil && one_step.rank != promotion_rank do
      generate_forward_moves(board, pos, one_step, two_steps, starting_rank, color)
    else
      []
    end
  end

  defp generate_forward_moves(board, pos, one_step, two_steps, starting_rank, color) do
    res = [Board.as_unsafe_moved(board, pos, one_step, {:pawn, color})]

    if pos.rank == starting_rank && two_steps && Board.get_piece(board, two_steps) == nil do
      res ++ [Board.as_unsafe_moved(board, pos, two_steps, {:pawn, color})]
    else
      res
    end
  end

  @impl true
  def type(_piece) do
    :pawn
  end

  @impl true
  def attacks(_piece, _board, pos, color) do
    left_capture = Pos.get_plus(pos, 1, -1, color)
    right_capture = Pos.get_plus(pos, 1, 1, color)

    [left_capture, right_capture] |> Enum.reject(&is_nil/1)
  end
end
