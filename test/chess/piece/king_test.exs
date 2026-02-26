defmodule Chess.Piece.KingTest do
  use ExUnit.Case
  alias Chess.{Board, GameContext, Piece, Pos}
  alias Chess.Piece.King

  describe "type" do
    test "should return :king" do
      assert Piece.type(%King{}) == :king
    end
  end

  describe "valid_moves" do
    test "should move one square in any direction" do
      board = Board.from_shorthand!("8/8/8/8/3K4/8/8/8")
      pos = Pos.from_notation("d4")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      moves = Piece.valid_moves(%King{}, game_context, pos)

      # Neighbors: d5, d3, c4, e4, c5, e5, c3, e3
      assert length(moves) == 8
    end

    test "should not move into check (attacked by pawn)" do
      # King at d4, black pawn at e6 (index 2, 4).
      # e6 attacks d5 (index 3, 3) and f5 (index 3, 5).
      # Neighbors of d4:
      # d5 (3, 3) - attacked by e6
      # d3 (5, 3) - free
      # c4 (4, 2) - free
      # e4 (4, 4) - free
      # c5 (3, 2) - free
      # e5 (3, 4) - free
      # c3 (5, 2) - free
      # e3 (5, 4) - free
      # f5 (3, 5) - attacked (wait, f5 is NOT a neighbor of d4!
      # d is file 3, f is file 5. d4 to f5 is {1, 2} - that's a knight move!)

      # Correct neighbors of d4: d5, d3, c4, e4, c5, e5, c3, e3.
      # Black pawn at e6 (2, 4) attacks d5 (3, 3) and f5 (3, 5).
      # ONLY d5 is a neighbor of d4 that is attacked.
      # So 8 - 1 = 7 moves.

      board = Board.from_shorthand!("8/8/4p3/8/3K4/8/8/8")
      pos = Pos.from_notation("d4")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      moves = Piece.valid_moves(%King{}, game_context, pos)

      assert length(moves) == 7
      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("d5") end)
    end

    test "should not move into check (attacked by rook)" do
      # King at d4, black rook at d8 attacks the whole d-file.
      board = Board.from_shorthand!("3r4/8/8/8/3K4/8/8/8")
      pos = Pos.from_notation("d4")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      moves = Piece.valid_moves(%King{}, game_context, pos)

      # Neighbors of d4: d5, d3, c4, e4, c5, e5, c3, e3.
      # d5 and d3 are on the d-file, so they are attacked.
      # So 8 - 2 = 6 moves.
      assert length(moves) == 6
      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("d5") end)
      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("d3") end)
    end

    test "should be able to capture an unprotected piece" do
      # King at d4, black pawn at d5. Pawn is NOT protected.
      board = Board.from_shorthand!("8/8/8/3p4/3K4/8/8/8")
      pos = Pos.from_notation("d4")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      moves = Piece.valid_moves(%King{}, game_context, pos)

      # King can capture d5.
      assert Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("d5") end)
    end

    test "should NOT be able to capture a protected piece" do
      # King at d4, black pawn at d5, protected by black pawn at e6.
      board = Board.from_shorthand!("8/8/4p3/3p4/3K4/8/8/8")
      pos = Pos.from_notation("d4")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      moves = Piece.valid_moves(%King{}, game_context, pos)

      # King cannot capture d5 because it's attacked by e6.
      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("d5") end)
    end

    test "should allow kingside castling when valid" do
      # White King at e1, White Rook at h1, path clear
      board = Board.from_shorthand!("8/8/8/8/8/8/8/4K2R")
      pos = Pos.from_notation("e1")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      moves = Piece.valid_moves(%King{}, game_context, pos)

      # Should have O-O (g1)
      assert Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("g1") end)

      {new_board, _} = Enum.find(moves, fn {_, p} -> p == Pos.from_notation("g1") end)
      assert Board.get_piece(new_board, Pos.from_notation("g1")) == {:king, :white}
      assert Board.get_piece(new_board, Pos.from_notation("f1")) == {:rook, :white}
    end

    test "should allow queenside castling when valid" do
      # White King at e1, White Rook at a1, path clear
      board = Board.from_shorthand!("8/8/8/8/8/8/8/R3K3")
      pos = Pos.from_notation("e1")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      moves = Piece.valid_moves(%King{}, game_context, pos)

      # Should have O-O-O (c1)
      assert Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("c1") end)

      {new_board, _} = Enum.find(moves, fn {_, p} -> p == Pos.from_notation("c1") end)
      assert Board.get_piece(new_board, Pos.from_notation("c1")) == {:king, :white}
      assert Board.get_piece(new_board, Pos.from_notation("d1")) == {:rook, :white}
    end

    test "should NOT allow castling if path is blocked" do
      # White King at e1, White Rook at h1, Bishop at f1
      board = Board.from_shorthand!("8/8/8/8/8/8/8/4KB1R")
      pos = Pos.from_notation("e1")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: [],
        active_color: :white,
        moved_positions: MapSet.new()
      }

      moves = Piece.valid_moves(%King{}, game_context, pos)

      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("g1") end)
    end

    test "should NOT allow castling if king has moved" do
      board = Board.from_shorthand!("8/8/8/8/8/8/8/4K2R")
      pos = Pos.from_notation("e1")

      game_context = %GameContext{
        board: board,
        last_board: nil,
        moves: ["Kf1", "Ke1"],
        active_color: :white,
        moved_positions: MapSet.new([Pos.from_notation("e1")])
      }

      moves = Piece.valid_moves(%King{}, game_context, pos)

      refute Enum.any?(moves, fn {_, p} -> p == Pos.from_notation("g1") end)
    end
  end
end
