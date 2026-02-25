alias Chess.Board

defmodule Chess.BoardTest do
  use ExUnit.Case
  doctest Board

  describe "handle_call {:move, move}" do
    test "should handle valid move" do
      {:ok, pid} = GenServer.start_link(Board, nil)
      assert GenServer.call(pid, {:move, "e4"}) == :ok
      assert GenServer.call(pid, {:move, "e5"}) == :ok
    end
  end

  describe "handle_call {:history}" do
    test "should return the current history of the board" do
      {:ok, pid} = GenServer.start_link(Board, nil)
      GenServer.call(pid, {:move, "e4"})
      GenServer.call(pid, {:move, "e5"})
      assert GenServer.call(pid, {:history}) == ["e4", "e5"]
    end
  end

  describe "from_shorthand!" do
    @cases [
      {
        "initial position",
        "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
        [
          [{:rook, :black}, {:knight, :black}, {:bishop, :black}, {:queen, :black}, {:king, :black}, {:bishop, :black}, {:knight, :black}, {:rook, :black}],
          [{:pawn, :black}, {:pawn, :black}, {:pawn, :black}, {:pawn, :black}, {:pawn, :black}, {:pawn, :black}, {:pawn, :black}, {:pawn, :black}],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [{:pawn, :white}, {:pawn, :white}, {:pawn, :white}, {:pawn, :white}, {:pawn, :white}, {:pawn, :white}, {:pawn, :white}, {:pawn, :white}],
          [{:rook, :white}, {:knight, :white}, {:bishop, :white}, {:queen, :white}, {:king, :white}, {:bishop, :white}, {:knight, :white}, {:rook, :white}]
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
    test "should return the piece at the given position (0-indexed)" do
      board = [
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, {:pawn, :white}, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, {:pawn, :black}, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil
        ]
      ]

      assert Board.get_piece(board, %Chess.Pos{rank: 3, file: 4}) == {:pawn, :black}
      assert Board.get_piece(board, %Chess.Pos{rank: 1, file: 4}) == {:pawn, :white}
    end

    test "should return nil if there is no piece at the given position" do
      board = [
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, {:pawn, :white}, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, {:pawn, :black}, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil, nil],
        [
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil,
          nil
        ]
      ]

      assert Board.get_piece(board, %Chess.Pos{rank: 0, file: 0}) == nil
    end
  end

  describe "as_unsafe_moved" do
    @cases [
      {
        "white doing simple forward",
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, {:pawn, :white}, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [
            nil,
            nil,
            nil,
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black}
          ],
          [
            nil,
            {:rook, :black},
            {:knight, :black},
            {:bishop, :black},
            {:queen, :black},
            {:king, :black},
            {:bishop, :black},
            {:knight, :black}
          ]
        ],
        %Chess.Pos{rank: 1, file: 4},
        %Chess.Pos{rank: 2, file: 4},
        {:pawn, :white},
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, {:pawn, :white}, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [
            nil,
            nil,
            nil,
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black}
          ],
          [
            nil,
            {:rook, :black},
            {:knight, :black},
            {:bishop, :black},
            {:queen, :black},
            {:king, :black},
            {:bishop, :black},
            {:knight, :black}
          ]
        ]
      },
      {
        "white promotion",
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, {:pawn, :white}, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [
            nil,
            nil,
            nil,
            nil,
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black}
          ],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ],
        %Chess.Pos{rank: 1, file: 4},
        %Chess.Pos{rank: 0, file: 4},
        {:queen, :white},
        [
          [nil, nil, nil, nil, {:queen, :white}, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [
            nil,
            nil,
            nil,
            nil,
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black},
            {:pawn, :black}
          ],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      },
      {
        "black doing simple forward",
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, {:pawn, :white}, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, {:pawn, :black}, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ],
        %Chess.Pos{rank: 6, file: 4},
        %Chess.Pos{rank: 5, file: 4},
        {:pawn, :black},
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, {:pawn, :white}, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, {:pawn, :black}, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      },
      {
        "black promotion",
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, {:pawn, :black}, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ],
        %Chess.Pos{rank: 6, file: 4},
        %Chess.Pos{rank: 7, file: 4},
        {:queen, :black},
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, {:queen, :black}, nil, nil, nil]
        ]
      }
    ]

    for {description, board, from, to, new_piece, expected_board} <- @cases do
      test "should move piece correctly for #{description}" do
        assert Board.as_unsafe_moved(
                 unquote(Macro.escape(board)),
                 unquote(Macro.escape(from)),
                 unquote(Macro.escape(to)),
                 unquote(Macro.escape(new_piece))
               ) == {unquote(Macro.escape(expected_board)), unquote(Macro.escape(to))}
      end
    end
  end
end
