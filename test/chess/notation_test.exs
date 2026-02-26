defmodule Chess.NotationTest do
  use ExUnit.Case
  alias Chess.{Board, GameContext, Notation, Pos}

  describe "parse" do
    test "should parse simple pawn move (e4)" do
      board = Board.from_shorthand!("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      assert {:ok, move} = Notation.parse(game_context, "e4")
      assert move.from == Pos.from_notation("e2")
      assert move.to == Pos.from_notation("e4")
    end

    test "should parse pawn capture (dxe5)" do
      # White pawn at d4 (index 4, 3), black pawn at e5 (index 3, 4)
      board = Board.from_shorthand!("8/8/8/4p3/3P4/8/8/8")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      assert {:ok, move} = Notation.parse(game_context, "dxe5")
      assert move.from == Pos.from_notation("d4")
      assert move.to == Pos.from_notation("e5")
    end

    test "should parse pawn capture from file (axb3)" do
      # White pawn at a2 (index 6, 0), black pawn at b3 (index 5, 1)
      board = Board.from_shorthand!("8/8/8/8/8/1p6/P7/8")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      assert {:ok, move} = Notation.parse(game_context, "axb3")
      assert move.from == Pos.from_notation("a2")
      assert move.to == Pos.from_notation("b3")
    end

    test "should parse piece move (Nf3)" do
      board = Board.from_shorthand!("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      assert {:ok, move} = Notation.parse(game_context, "Nf3")
      assert move.from == Pos.from_notation("g1")
      assert move.to == Pos.from_notation("f3")
    end

    test "should resolve ambiguity using file (Nbd7)" do
      # Knights at b6 (index 2, 1) and f6 (index 2, 5), both can reach d7 (index 1, 3)
      board = Board.from_shorthand!("8/8/1N3N2/8/8/8/8/8")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      assert {:ok, move} = Notation.parse(game_context, "Nbd7")
      assert move.from == Pos.from_notation("b6")
      assert move.to == Pos.from_notation("d7")
    end

    test "should parse promotion (e8=Q)" do
      # White pawn at e7 (index 1, 4)
      board = Board.from_shorthand!("8/4P3/8/8/8/8/8/8")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      assert {:ok, move} = Notation.parse(game_context, "e8=Q")
      assert move.from == Pos.from_notation("e7")
      assert move.to == Pos.from_notation("e8")
      assert {type, _} = Board.get_piece(move.board, move.to)
      assert type == :queen
    end
  end
end
