defmodule Chess.Piece.PawnTest do
  use ExUnit.Case
  alias Chess.{Board, GameContext, Piece, Pos}
  alias Chess.Piece.Pawn

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
        Pos.from_notation("e2"),
        :white,
        [
          {Board.from_shorthand!("8/8/8/8/8/4P3/PPPP1PPP/RNBQKBNR"), Pos.from_notation("e3")},
          {Board.from_shorthand!("8/8/8/8/4P3/8/PPPP1PPP/RNBQKBNR"), Pos.from_notation("e4")}
        ]
      },
      {
        "first move, black pawn at starting position",
        Board.from_shorthand!("rnbqkbnr/pppppppp/8/8/8/8/8/8"),
        nil,
        Pos.from_notation("e7"),
        :black,
        [
          {Board.from_shorthand!("rnbqkbnr/pppp1ppp/4p3/8/8/8/8/8"), Pos.from_notation("e6")},
          {Board.from_shorthand!("rnbqkbnr/pppp1ppp/8/4p3/8/8/8/8"), Pos.from_notation("e5")}
        ]
      },
      {
        "en passant capture, white",
        Board.from_shorthand!("8/8/8/3pP3/8/8/8/8"),
        Board.from_shorthand!("8/3p4/8/4P3/8/8/8/8"),
        Pos.from_notation("e5"),
        :white,
        [
          {Board.from_shorthand!("8/8/4P3/3p4/8/8/8/8"), Pos.from_notation("e6")},
          {Board.from_shorthand!("8/8/3P4/8/8/8/8/8"), Pos.from_notation("d6")}
        ]
      },
      {
        "en passant capture, black",
        Board.from_shorthand!("8/8/8/8/3pP3/8/8/8"),
        Board.from_shorthand!("8/8/8/8/8/8/4P3/8"),
        Pos.from_notation("d4"),
        :black,
        [
          {Board.from_shorthand!("8/8/8/8/4P3/3p4/8/8"), Pos.from_notation("d3")},
          {Board.from_shorthand!("8/8/8/8/8/4p3/8/8"), Pos.from_notation("e3")}
        ]
      },
      {
        "promotion move, white",
        Board.from_shorthand!("8/P7/8/8/8/8/8/8"),
        nil,
        Pos.from_notation("a7"),
        :white,
        [
          {Board.from_shorthand!("Q7/8/8/8/8/8/8/8"), Pos.from_notation("a8")},
          {Board.from_shorthand!("R7/8/8/8/8/8/8/8"), Pos.from_notation("a8")},
          {Board.from_shorthand!("B7/8/8/8/8/8/8/8"), Pos.from_notation("a8")},
          {Board.from_shorthand!("N7/8/8/8/8/8/8/8"), Pos.from_notation("a8")}
        ]
      },
      {
        "promotion move, black",
        Board.from_shorthand!("8/8/8/8/8/8/p7/8"),
        nil,
        Pos.from_notation("a2"),
        :black,
        [
          {Board.from_shorthand!("8/8/8/8/8/8/8/q7"), Pos.from_notation("a1")},
          {Board.from_shorthand!("8/8/8/8/8/8/8/r7"), Pos.from_notation("a1")},
          {Board.from_shorthand!("8/8/8/8/8/8/8/b7"), Pos.from_notation("a1")},
          {Board.from_shorthand!("8/8/8/8/8/8/8/n7"), Pos.from_notation("a1")}
        ]
      }
    ]

    for {description, board, last_board, from, color, expected_moves} <- @cases do
      test "should return valid moves for #{description}" do
        game_context =
          GameContext.new(
            board: unquote(Macro.escape(board)),
            last_board: unquote(Macro.escape(last_board)),
            active_color: unquote(color)
          )

        assert Piece.valid_moves(
                 %Pawn{},
                 game_context,
                 unquote(Macro.escape(from))
               ) == unquote(Macro.escape(expected_moves))
      end
    end
  end
end
