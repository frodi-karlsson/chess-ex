alias Chess.{Board, GameContext, Pos}

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
  """
  @spec valid_moves(
          piece :: any(),
          game_context :: GameContext.t(),
          pos :: Pos.t()
        ) :: list(new_state())
  def valid_moves(piece, game_context, pos)

  @doc """
  Returns a list of squares that the given piece is attacking from the given position.
  This is used for check detection and King movement.
  """
  @spec attacks(
          piece :: any(),
          game_context :: GameContext.t(),
          pos :: Pos.t()
        ) :: list(Pos.t())
  def attacks(piece, game_context, pos)

  @doc """
  Returns the type of the piece, e.g. :pawn, :rook, :knight, etc.
  """
  @spec type(piece :: atom()) :: atom()
  def type(piece)
end
