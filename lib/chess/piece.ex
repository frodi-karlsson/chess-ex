alias Chess.{Board, Pos}

defprotocol Chess.Piece do
  @moduledoc """
  A protocol that defines the behavior of chess pieces.

  Since chess pieces are alike in the sense that they can move,
  but have different ways of moving, this protocol defines a
  way we can reason about them in a polymorphic way.
  """

  @type new_state :: {Board.board(), Pos.t()}

  @doc """
  Returns a list of valid future board states that can be reached
  by moving the given piece on the given board.
  board.
  """
  @spec valid_moves(
          piece :: any(),
          board :: Board.board(),
          last_board :: Board.board() | nil,
          pos :: Pos.t(),
          color :: Chess.color()
        ) :: list(new_state())
  def valid_moves(piece, board, last_board, pos, color)

  @doc """
  Returns a list of squares that the given piece is attacking from the given position.
  This is used for check detection and King movement.
  """
  @spec attacks(
          piece :: any(),
          board :: Board.board(),
          pos :: Pos.t(),
          color :: Chess.color()
        ) :: list(Pos.t())
  def attacks(piece, board, pos, color)

  @doc """
  Returns the type of the piece, e.g. :pawn, :rook, :knight, etc.
  """
  @spec type(piece :: atom()) :: atom()
  def type(piece)
end
