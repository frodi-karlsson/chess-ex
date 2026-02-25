defmodule Chess.Piece.PawnTest do
  use ExUnit.Case
  alias Chess.Board
  alias Chess.Piece.Pawn
  alias Chess.Piece


  describe "type" do
    test "should return :pawn" do
      assert Piece.type(%Pawn{}) == :pawn
    end
  end

  describe "valid_moves" do
    @cases [
      {
        "first move, white pawn at starting position",
        Board.from_shorthand!("8/8/8/8/8/8/PPPPPPPP/RNBQKBNR"),
        nil,
        %Chess.Pos{rank: 6, file: 4},
        :white,
        [
          {Board.from_shorthand!("8/8/8/8/8/4P3/PPPP1PPP/RNBQKBNR"), %Chess.Pos{rank: 5, file: 4}},
          {Board.from_shorthand!("8/8/8/8/4P3/8/PPPP1PPP/RNBQKBNR"), %Chess.Pos{rank: 4, file: 4}}
        ]
      },
      {
        "first move, black pawn at starting position",
        Board.from_shorthand!("rnbqkbnr/pppppppp/8/8/8/8/8/8"),
        nil,
        %Chess.Pos{rank: 1, file: 4},
        :black,
        [
          {Board.from_shorthand!("rnbqkbnr/pppp1ppp/4p3/8/8/8/8/8"), %Chess.Pos{rank: 2, file: 4}},
          {Board.from_shorthand!("rnbqkbnr/pppp1ppp/8/4p3/8/8/8/8"), %Chess.Pos{rank: 3, file: 4}}
        ]
      },
      {
        "en passant capture, white",
        Board.from_shorthand!("8/8/8/3pP3/8/8/8/8"),
        Board.from_shorthand!("8/3p4/8/4P3/8/8/8/8"),
        %Chess.Pos{rank: 3, file: 4},
        :white,
        [
          {Board.from_shorthand!("8/8/4P3/3p4/8/8/8/8"), %Chess.Pos{rank: 2, file: 4}},
          {Board.from_shorthand!("8/8/3P4/8/8/8/8/8"), %Chess.Pos{rank: 2, file: 3}}
        ]
      },
      {
        "en passant capture, black",
        Board.from_shorthand!("8/8/8/8/3pP3/8/8/8"),
        Board.from_shorthand!("8/8/8/3P4/8/4p3/8/8"),
        %Chess.Pos{rank: 4, file: 3},
        :black,
        [
          {Board.from_shorthand!("8/8/8/8/4P3/3p4/8/8"), %Chess.Pos{rank: 5, file: 3}},
          {Board.from_shorthand!("8/8/8/8/8/4p3/8/8"), %Chess.Pos{rank: 5, file: 4}}
        ]
      },
      {
        "promotion move, white",
        Board.from_shorthand!("8/P7/8/8/8/8/8/8"),
        nil,
        %Chess.Pos{rank: 1, file: 0},
        :white,
        [
          {Board.from_shorthand!("Q7/8/8/8/8/8/8/8"), %Chess.Pos{rank: 0, file: 0}},
          {Board.from_shorthand!("R7/8/8/8/8/8/8/8"), %Chess.Pos{rank: 0, file: 0}},
          {Board.from_shorthand!("B7/8/8/8/8/8/8/8"), %Chess.Pos{rank: 0, file: 0}},
          {Board.from_shorthand!("N7/8/8/8/8/8/8/8"), %Chess.Pos{rank: 0, file: 0}}
        ]
      },
      {
        "promotion move, black",
        Board.from_shorthand!("8/8/8/8/8/8/p7/8"),
        nil,
        %Chess.Pos{rank: 6, file: 0},
        :black,
        [
          {Board.from_shorthand!("8/8/8/8/8/8/8/q7"), %Chess.Pos{rank: 7, file: 0}},
          {Board.from_shorthand!("8/8/8/8/8/8/8/r7"), %Chess.Pos{rank: 7, file: 0}},
          {Board.from_shorthand!("8/8/8/8/8/8/8/b7"), %Chess.Pos{rank: 7, file: 0}},
          {Board.from_shorthand!("8/8/8/8/8/8/8/n7"), %Chess.Pos{rank: 7, file: 0}}
        ]
      }
    ]

    for {description, board, last_board, from, color, expected_moves} <- @cases do
      test "should return valid moves for #{description}" do
        assert Piece.valid_moves(
                  %Pawn{},
                  unquote(Macro.escape(board)),
                  unquote(Macro.escape(last_board)),
                  unquote(Macro.escape(from)),
                  unquote(color)
                ) == unquote(Macro.escape(expected_moves))
      end
    end
  end
end
