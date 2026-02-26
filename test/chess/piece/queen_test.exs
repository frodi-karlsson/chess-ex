defmodule Chess.Piece.QueenTest do
  use ExUnit.Case
  alias Chess.Board
  alias Chess.Piece
  alias Chess.Piece.Queen
  alias Chess.Pos

  describe "type" do
    test "should return :queen" do
      assert Piece.type(%Queen{}) == :queen
    end
  end

  describe "valid_moves" do
    test "should move along rank, file, and diagonals" do
      board = Board.from_shorthand!("8/8/8/8/3Q4/8/8/8")
      pos = Pos.from_notation("d4")
      moves = Piece.valid_moves(%Queen{}, board, nil, pos, :white)

      # d4 is {4, 3}
      # Orthogonal (Rook-like): 14 moves
      # Diagonal (Bishop-like): 13 moves
      # Total: 14 + 13 = 27 moves

      assert length(moves) == 27
    end

    test "should be blocked by own pieces" do
      # Block d5 (Up) and e5 (Up-Right)
      board = Board.from_shorthand!("8/8/8/3PP3/3Q4/8/8/8")
      pos = Pos.from_notation("d4")
      moves = Piece.valid_moves(%Queen{}, board, nil, pos, :white)

      # Total 27 - (4 Up) - (4 Up-Right) = 19
      assert length(moves) == 19
      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("d5") end)
      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("e5") end)
    end

    test "should capture opponent pieces and stop" do
      # d4 Queen, black pawn at f6 (Up-Right) and d6 (Up)
      board = Board.from_shorthand!("8/8/3p1p2/8/3Q4/8/8/8")
      pos = Pos.from_notation("d4")
      moves = Piece.valid_moves(%Queen{}, board, nil, pos, :white)

      # Orthogonal:
      # Up: d5, d6 (2)
      # Down: 3
      # Left: 3
      # Right: 4
      # Subtotal Orth: 12

      # Diagonal:
      # Up-Right: e5, f6 (2)
      # Up-Left: 3
      # Down-Left: 3
      # Down-Right: 3
      # Subtotal Diag: 11

      # Total: 12 + 11 = 23 moves

      assert length(moves) == 23
      assert Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("d6") end)
      assert Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("f6") end)
      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("d7") end)
      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("g7") end)
    end
  end
end
