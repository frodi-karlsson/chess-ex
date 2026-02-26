defmodule Chess.BoardAttackedTest do
  use ExUnit.Case
  alias Chess.Board
  alias Chess.Pos

  describe "attacked?" do
    test "should detect pawn attacks" do
      # White pawn at e2 attacks d3 and f3
      board = Board.from_shorthand!("8/8/8/8/8/8/4P3/8")
      assert Board.attacked?(board, Pos.from_notation("d3"), :white)
      assert Board.attacked?(board, Pos.from_notation("f3"), :white)
      refute Board.attacked?(board, Pos.from_notation("e3"), :white)
    end

    test "should detect knight attacks" do
      # White knight at d4 attacks c6, e6, b5, f5, b3, f3, c2, e2
      board = Board.from_shorthand!("8/8/8/8/3N4/8/8/8")
      assert Board.attacked?(board, Pos.from_notation("c6"), :white)
      assert Board.attacked?(board, Pos.from_notation("e6"), :white)
      assert Board.attacked?(board, Pos.from_notation("b5"), :white)
      assert Board.attacked?(board, Pos.from_notation("f5"), :white)
      assert Board.attacked?(board, Pos.from_notation("b3"), :white)
      assert Board.attacked?(board, Pos.from_notation("f3"), :white)
      assert Board.attacked?(board, Pos.from_notation("c2"), :white)
      assert Board.attacked?(board, Pos.from_notation("e2"), :white)
      refute Board.attacked?(board, Pos.from_notation("d5"), :white)
    end

    test "should detect sliding attacks (rook)" do
      # White rook at d4
      board = Board.from_shorthand!("8/8/8/8/3R4/8/8/8")
      assert Board.attacked?(board, Pos.from_notation("d8"), :white)
      assert Board.attacked?(board, Pos.from_notation("a4"), :white)
      assert Board.attacked?(board, Pos.from_notation("h4"), :white)
      assert Board.attacked?(board, Pos.from_notation("d1"), :white)
      refute Board.attacked?(board, Pos.from_notation("c3"), :white)
    end

    test "should be blocked by pieces" do
      # White rook at d4, blocked by pawn at d6
      board = Board.from_shorthand!("8/8/3P4/8/3R4/8/8/8")
      assert Board.attacked?(board, Pos.from_notation("d6"), :white)
      # d7 is beyond d6, so it's not attacked
      refute Board.attacked?(board, Pos.from_notation("d7"), :white)
    end

    test "should detect bishop attacks" do
      # White bishop at d4
      board = Board.from_shorthand!("8/8/8/8/3B4/8/8/8")
      assert Board.attacked?(board, Pos.from_notation("a1"), :white)
      assert Board.attacked?(board, Pos.from_notation("g7"), :white)
      assert Board.attacked?(board, Pos.from_notation("a7"), :white)
      assert Board.attacked?(board, Pos.from_notation("g1"), :white)
      refute Board.attacked?(board, Pos.from_notation("d5"), :white)
    end
  end
end
