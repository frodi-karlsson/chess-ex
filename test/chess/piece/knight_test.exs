defmodule Chess.Piece.KnightTest do
  use ExUnit.Case
  alias Chess.{Board, GameContext, Piece, Pos}
  alias Chess.Piece.Knight

  describe "type" do
    test "should return :knight" do
      assert Piece.type(%Knight{}) == :knight
    end
  end

  describe "valid_moves" do
    test "should move in an L-shape from the center" do
      board = Board.from_shorthand!("8/8/8/8/3N4/8/8/8")
      pos = Pos.from_notation("d4")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      moves = Piece.valid_moves(%Knight{}, game_context, pos)

      # From d4 (4, 3), moves are:
      # (2, 1) -> (6, 4) -> "e2"
      # (2, -1) -> (6, 2) -> "c2"
      # (-2, 1) -> (2, 4) -> "e6"
      # (-2, -1) -> (2, 2) -> "c6"
      # (1, 2) -> (5, 5) -> "f3"
      # (1, -2) -> (5, 1) -> "b3"
      # (-1, 2) -> (3, 5) -> "f5"
      # (-1, -2) -> (3, 1) -> "b5"
      # Total: 8 moves

      assert length(moves) == 8

      expected_positions =
        ~w(e2 c2 e6 c6 f3 b3 f5 b5)
        |> Enum.map(&Pos.from_notation/1)
        |> MapSet.new()

      actual_positions =
        moves
        |> Enum.map(fn {_, p} -> p end)
        |> MapSet.new()

      assert actual_positions == expected_positions
    end

    test "should handle board boundaries" do
      # Knight at a1
      board = Board.from_shorthand!("8/8/8/8/8/8/8/N7")
      pos = Pos.from_notation("a1")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      moves = Piece.valid_moves(%Knight{}, game_context, pos)

      # From a1 (7, 0):
      # (2, 1) -> Out
      # (2, -1) -> Out
      # (-2, 1) -> (5, 1) -> b3
      # (-2, -1) -> Out
      # (1, 2) -> Out
      # (1, -2) -> Out
      # (-1, 2) -> (6, 2) -> c2
      # (-1, -2) -> Out
      # Only 2 moves: b3 and c2.

      assert length(moves) == 2

      expected_positions =
        ~w(b3 c2)
        |> Enum.map(&Pos.from_notation/1)
        |> MapSet.new()

      actual_positions =
        moves
        |> Enum.map(fn {_, p} -> p end)
        |> MapSet.new()

      assert actual_positions == expected_positions
    end

    test "should be blocked by own pieces" do
      # White Knight at d4, white pawn at f5 (index 3, 5)
      board = Board.from_shorthand!("8/8/8/5P2/3N4/8/8/8")
      pos = Pos.from_notation("d4")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      moves = Piece.valid_moves(%Knight{}, game_context, pos)

      # Total 8 moves - 1 (f5 is blocked) = 7 moves.
      assert length(moves) == 7
      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("f5") end)
    end

    test "should capture opponent pieces" do
      # White Knight at d4, black pawn at f5 (index 3, 5)
      board = Board.from_shorthand!("8/8/8/5p2/3N4/8/8/8")
      pos = Pos.from_notation("d4")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      moves = Piece.valid_moves(%Knight{}, game_context, pos)

      # Total 8 moves, one of them is capturing at f5.
      assert length(moves) == 8
      assert Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("f5") end)
    end
  end
end
