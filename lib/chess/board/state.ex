defmodule Chess.Board.State do
  @moduledoc """
  Represents the full state of a chess board, including history and game metadata.
  """
  alias Chess.Board

  defstruct [
    :id,
    :moves,
    :board,
    :last_board,
    :active_color,
    :status,
    :white_player,
    :black_player,
    :moved_positions
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          moves: list(String.t()),
          board: Board.board(),
          last_board: Board.board() | nil,
          active_color: Chess.color(),
          status: :playing | :checkmate | :stalemate | :draw,
          white_player: any(),
          black_player: any(),
          moved_positions: MapSet.t()
        }

  @doc """
  Initializes a new Chess.Board.State for a fresh game.
  """
  def new do
    %__MODULE__{
      id: Ecto.UUID.generate(),
      moves: [],
      board: Board.from_shorthand!("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"),
      last_board: nil,
      active_color: :white,
      status: :playing,
      white_player: nil,
      black_player: nil,
      moved_positions: MapSet.new()
    }
  end
end
