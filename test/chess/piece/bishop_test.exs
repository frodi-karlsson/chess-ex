defmodule Chess.Piece.BishopTest do
  use ExUnit.Case
  alias Chess.Board
  alias Chess.Piece
  alias Chess.Piece.Bishop
  alias Chess.Pos

  describe "type" do
    test "should return :bishop" do
      assert Piece.type(%Bishop{}) == :bishop
    end
  end

  describe "valid_moves" do
    test "should move diagonally" do
      board = Board.from_shorthand!("8/8/8/8/3B4/8/8/8")
      pos = Pos.from_notation("d4")
      moves = Piece.valid_moves(%Bishop{}, board, nil, pos, :white)

      # d4 is {4, 3}
      # Up-Left: c5, b6, a7 (3)
      # Up-Right: e5, f6, g7, h8 (4)
      # Down-Left: c3, b2, a1 (3)
      # Down-Right: e3, f2, g1 (3)
      # Total: 3 + 4 + 3 + 3 = 13 moves

      assert length(moves) == 13
    end

    test "should be blocked by own pieces" do
      # Block d5 with a white pawn (Up-Left-ish diagonal if we were rooks,
      # but let's block a real diagonal: e5 is Pos.from_notation("e5"))
      board = Board.from_shorthand!("8/8/8/4P3/3B4/8/8/8")
      pos = Pos.from_notation("d4")
      moves = Piece.valid_moves(%Bishop{}, board, nil, pos, :white)
      # Blocked at e5.
      # Up-Right: 0 (e5 is blocked)
      # Up-Left: 3
      # Down-Left: 3
      # Down-Right: 3
      # Total: 9

      assert length(moves) == 9
      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("e5") end)
    end

    test "should capture opponent pieces and stop" do
      # d4 Bishop, black pawn at f6 (Up-Right)
      board = Board.from_shorthand!("8/8/5p2/8/3B4/8/8/8")
      pos = Pos.from_notation("d4")
      moves = Piece.valid_moves(%Bishop{}, board, nil, pos, :white)

      # Up-Right: e5, f6 (2) - stops at f6
      # Up-Left: 3
      # Down-Left: 3
      # Down-Right: 3
      # Total: 11

      assert length(moves) == 11
      assert Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("f6") end)
      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("g7") end)
    end
  end
end
