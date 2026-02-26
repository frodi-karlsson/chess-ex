defmodule Chess.Piece.RookTest do
  use ExUnit.Case
  alias Chess.{Board, GameContext, Piece, Pos}
  alias Chess.Piece.Rook

  describe "type" do
    test "should return :rook" do
      assert Piece.type(%Rook{}) == :rook
    end
  end

  describe "valid_moves" do
    test "should move along rank and file" do
      board = Board.from_shorthand!("8/8/8/8/3R4/8/8/8")
      pos = Pos.from_notation("d4")

      game_context = GameContext.new(board: board)

      moves = Piece.valid_moves(%Rook{}, game_context, pos)

      # d4 is {4, 3}
      # Up: d5, d6, d7, d8 (ranks 3, 2, 1, 0)
      # Down: d3, d2, d1 (ranks 5, 6, 7)
      # Left: c4, b4, a4 (files 2, 1, 0)
      # Right: e4, f4, g4, h4 (files 4, 5, 6, 7)
      # Total: 4 + 3 + 3 + 4 = 14 moves

      assert length(moves) == 14
    end

    test "should be blocked by own pieces" do
      board = Board.from_shorthand!("8/8/8/3P4/3R4/8/8/8")
      pos = Pos.from_notation("d4")

      game_context = GameContext.new(board: board)

      moves = Piece.valid_moves(%Rook{}, game_context, pos)

      # Blocked at d5 (rank 3, index 3).
      # d5 is occupied by white pawn, so d5 is NOT a valid move.
      # Other directions are free.
      # Up: 0
      # Down: 3
      # Left: 3
      # Right: 4
      # Total: 10

      assert length(moves) == 10
      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("d5") end)
    end

    test "should capture opponent pieces and stop" do
      board = Board.from_shorthand!("8/8/8/3p4/3R4/8/8/8")
      pos = Pos.from_notation("d4")

      game_context = GameContext.new(board: board)

      moves = Piece.valid_moves(%Rook{}, game_context, pos)

      # d5 is black pawn. Rook can capture d5 but cannot go further (d6, d7, d8).
      # Up: d5 (1)
      # Down: 3
      # Left: 3
      # Right: 4
      # Total: 11

      assert length(moves) == 11
      assert Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("d5") end)
      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("d6") end)
    end
  end
end
