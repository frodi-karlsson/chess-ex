alias Chess.Board

defmodule Chess.BoardTest do
  use ExUnit.Case
  alias Chess.Board
  alias Chess.Pos
  doctest Board

  describe "handle_call {:move, move}" do
    test "should handle valid move" do
      {:ok, pid} = Board.start_game()
      assert Board.move(pid, "e4") == :ok
      assert Board.move(pid, "e5") == :ok
    end

    test "should return error for invalid move" do
      {:ok, pid} = Board.start_game()
      # Black move first
      assert {:error, _} = Board.move(pid, "e5")
      # King can't jump to e4
      assert {:error, _} = Board.move(pid, "Ke4")
    end
  end

  describe "move/2 client function" do
    test "should handle valid move" do
      {:ok, pid} = Board.start_game()
      assert Board.move(pid, "e4") == :ok
      assert Board.move(pid, "e5") == :ok
    end

    test "should return error for invalid move" do
      {:ok, pid} = Board.start_game()
      # Black moves first
      assert {:error, _} = Board.move(pid, "e5")
      # King can't jump to e4
      assert {:error, _} = Board.move(pid, "Ke4")
    end
  end

  describe "handle_call {:history}" do
    test "should return the current history of the board" do
      {:ok, pid} = Board.start_game()
      Board.move(pid, "e4")
      Board.move(pid, "e5")
      assert Board.history(pid) == ["e4", "e5"]
    end
  end

  describe "from_shorthand!" do
    @cases [
      {
        "initial position",
        "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
        [
          [
            {:rook, :black},
            {:knight, :black},
            {:bishop, :black},
            {:queen, :black},
            {:king, :black},
            {:bishop, :black},
            {:knight, :black},
            {:rook, :black}
          ],
          [
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black}
          ],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [
            {:pawn, :white},
            {:pawn, :white},
            {:pawn, :white},
            {:pawn, :white},
            {:pawn, :white},
            {:pawn, :white},
            {:pawn, :white},
            {:pawn, :white}
          ],
          [
            {:rook, :white},
            {:knight, :white},
            {:bishop, :white},
            {:queen, :white},
            {:king, :white},
            {:bishop, :white},
            {:knight, :white},
            {:rook, :white}
          ]
        ]
      },
      {
        "empty board",
        "8/8/8/8/8/8/8/8",
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      },
      {
        "position with some pieces",
        "8/8/8/4p3/8/8/8/8",
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, {:pawn, :black}, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      }
    ]

    for {description, shorthand, expected_board} <- @cases do
      test "should create correct board for #{description}" do
        assert Board.from_shorthand!(unquote(shorthand)) == unquote(Macro.escape(expected_board))
      end
    end
  end

  describe "get_piece" do
    test "should return the piece at the given position" do
      board = Board.from_shorthand!("8/4P3/8/4p3/8/8/8/8")

      assert Board.get_piece(board, Pos.from_notation("e5")) == {:pawn, :black}
      assert Board.get_piece(board, Pos.from_notation("e7")) == {:pawn, :white}
    end

    test "should return nil if there is no piece at the given position" do
      board = Board.from_shorthand!("8/4P3/8/4p3/8/8/8/8")

      assert Board.get_piece(board, Pos.from_notation("a1")) == nil
    end
  end

  describe "as_unsafe_moved" do
    @cases [
      {
        "white doing simple forward",
        "8/4P3/8/8/8/8/3ppppp/1rnbqkbn",
        Pos.from_notation("e7"),
        Pos.from_notation("e6"),
        {:pawn, :white},
        "8/8/4P3/8/8/8/3ppppp/1rnbqkbn"
      },
      {
        "white promotion",
        "8/4P3/8/8/8/4pppp/8/8",
        Pos.from_notation("e7"),
        Pos.from_notation("e8"),
        {:queen, :white},
        "4Q3/8/8/8/8/4pppp/8/8"
      },
      {
        "black doing simple forward",
        "8/4P3/8/8/8/8/4p3/8",
        Pos.from_notation("e2"),
        Pos.from_notation("e1"),
        {:pawn, :black},
        "8/4P3/8/8/8/8/8/4p3"
      },
      {
        "black promotion",
        "8/8/8/8/8/8/4p3/8",
        Pos.from_notation("e2"),
        Pos.from_notation("e1"),
        {:queen, :black},
        "8/8/8/8/8/8/8/4q3"
      }
    ]

    for {description, board_shorthand, from, to, new_piece, expected_shorthand} <- @cases do
      test "should move piece correctly for #{description}" do
        board = Board.from_shorthand!(unquote(board_shorthand))
        expected_board = Board.from_shorthand!(unquote(expected_shorthand))

        assert Board.as_unsafe_moved(
                 board,
                 unquote(Macro.escape(from)),
                 unquote(Macro.escape(to)),
                 unquote(Macro.escape(new_piece))
               ) == {expected_board, unquote(Macro.escape(to))}
      end
    end
  end
end
