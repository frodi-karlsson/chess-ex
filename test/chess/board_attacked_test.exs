defmodule Chess.BoardAttackedTest do
  use ExUnit.Case
  alias Chess.{Board, GameContext, Pos}

  describe "attacked?" do
    test "should detect pawn attacks" do
      # White pawn at e2 attacks d3 and f3
      board = Board.from_shorthand!("8/8/8/8/8/8/4P3/8")
      # Checking if squares are attacked by white
      game_context_white = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      assert Board.attacked?(game_context_white, Pos.from_notation("d3"))
      assert Board.attacked?(game_context_white, Pos.from_notation("f3"))
      refute Board.attacked?(game_context_white, Pos.from_notation("e3"))
    end

    test "should detect knight attacks" do
      # White knight at d4 attacks c6, e6, b5, f5, b3, f3, c2, e2
      board = Board.from_shorthand!("8/8/8/8/3N4/8/8/8")

      game_context_white = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      assert Board.attacked?(game_context_white, Pos.from_notation("c6"))
      assert Board.attacked?(game_context_white, Pos.from_notation("e6"))
      assert Board.attacked?(game_context_white, Pos.from_notation("b5"))
      assert Board.attacked?(game_context_white, Pos.from_notation("f5"))
      assert Board.attacked?(game_context_white, Pos.from_notation("b3"))
      assert Board.attacked?(game_context_white, Pos.from_notation("f3"))
      assert Board.attacked?(game_context_white, Pos.from_notation("c2"))
      assert Board.attacked?(game_context_white, Pos.from_notation("e2"))
      refute Board.attacked?(game_context_white, Pos.from_notation("d5"))
    end

    test "should detect sliding attacks (rook)" do
      # White rook at d4
      board = Board.from_shorthand!("8/8/8/8/3R4/8/8/8")

      game_context_white = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      assert Board.attacked?(game_context_white, Pos.from_notation("d8"))
      assert Board.attacked?(game_context_white, Pos.from_notation("a4"))
      assert Board.attacked?(game_context_white, Pos.from_notation("h4"))
      assert Board.attacked?(game_context_white, Pos.from_notation("d1"))
      refute Board.attacked?(game_context_white, Pos.from_notation("c3"))
    end

    test "should be blocked by pieces" do
      # White rook at d4, blocked by pawn at d6
      board = Board.from_shorthand!("8/8/3P4/8/3R4/8/8/8")

      game_context_white = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      assert Board.attacked?(game_context_white, Pos.from_notation("d6"))
      # d7 is beyond d6, so it's not attacked
      refute Board.attacked?(game_context_white, Pos.from_notation("d7"))
    end

    test "should detect bishop attacks" do
      # White bishop at d4
      board = Board.from_shorthand!("8/8/8/8/3B4/8/8/8")

      game_context_white = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      assert Board.attacked?(game_context_white, Pos.from_notation("a1"))
      assert Board.attacked?(game_context_white, Pos.from_notation("g7"))
      assert Board.attacked?(game_context_white, Pos.from_notation("a7"))
      assert Board.attacked?(game_context_white, Pos.from_notation("g1"))
      refute Board.attacked?(game_context_white, Pos.from_notation("d5"))
    end
  end
end
