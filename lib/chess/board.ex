defmodule Chess.Board do
  @type move :: String.t()
  @type board :: list(list(Chess.Piece.t() | nil))
  @moduledoc """
  A chessboard. We think of it as a series of events, that
  we can replay on an empty board to get the current state.

  This is likely to work pretty fine. While databases need
  to take snapshots once in a while to avoid having to
  replay the entire history, chess games are not as long as
  a database serving many users.

  Internally, the board is also represented as a grid, as
  we can't easily reason about what's allowed with only the
  history of moves.
  """
  use GenServer

  @impl true
  @spec init(any()) :: {:ok, []}
  def init(_args) do
    {:ok, []}
  end

  @impl true
  @spec handle_call({:move, move()}, any(), list()) :: {:reply, :ok, list()}
  def handle_call({:move, move}, _from, moves) do
    # todo, validate. Probably `when is_valid_move(move, moves) do`
    {:reply, :ok, moves ++ [move]}
  end

  @impl true
  @spec handle_call({:history}, any(), list()) :: {:reply, list(), list()}
  def handle_call({:history}, _from, moves) do
    {:reply, moves, moves}
  end

  @doc """
  Returns a new board state by moving a piece from the `from` position to the `to` position.

  Note on validation: this function does not perform any validation on the move.
  It assumes that the move is valid and simply updates the board state accordingly.
  """
  @spec as_unsafe_moved(
          board :: board(),
          from :: %Chess.Pos{},
          to :: %Chess.Pos{},
          new_piece :: Chess.Piece.t()
        ) :: Chess.Piece.new_state()
  def as_unsafe_moved(board, from, to, new_piece) do
    board =
      board
      |> List.update_at(from.rank, fn rank ->
        List.update_at(rank, from.file, fn _ -> nil end)
      end)
      |> List.update_at(to.rank, fn rank ->
        List.update_at(rank, to.file, fn _ -> new_piece end)
      end)

    {board, to}
  end

  @doc """
  Returns the piece at the given position on the board, or nil if there is no piece at that position.
  """
  @spec get_piece(board :: board(), pos :: %Chess.Pos{}) :: Chess.Piece.t() | nil
  def get_piece(board, pos) do
    board
    |> Enum.at(pos.rank)
    |> Enum.at(pos.file)
  end

  @doc """
  Converts a piece character to its corresponding piece type atom.
  For example, "p" or "P" would return :pawn, "r" or "R" would return :rook, etc.

  Raises an ArgumentError if the character is not a valid piece character.
  """
  @spec char_to_piece!(String.t()) :: atom()
  def char_to_piece!(char) do
    case String.downcase(char) do
      "p" -> :pawn
      "r" -> :rook
      "n" -> :knight
      "b" -> :bishop
      "q" -> :queen
      "k" -> :king
      _ -> raise ArgumentError, "Invalid piece character: #{char}"
    end
  end

  @doc """
  Determines the color of a piece based on its character representation.
  For example, lowercase characters ("p", "r", "n", "b", "q", "k") would return :black, while uppercase characters ("P", "R", "N", "B", "Q", "K") would return :white.

  Raises an ArgumentError if the character is not a valid piece character.
  """

  @spec color_of_piece!(String.t()) :: atom()
  def color_of_piece!(char) do
    case char do
      c when c in ["p", "r", "n", "b", "q", "k"] -> :black
      c when c in ["P", "R", "N", "B", "Q", "K"] -> :white
      _ -> raise ArgumentError, "Invalid piece character: #{char}"
    end
  end

  @doc """
  Creates a board from a shorthand string representation.

  ## Examples

  iex> Chess.Board.from_shorthand!("8/8/8/4p3/8/8/8/8")
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
  """
  @spec from_shorthand!(String.t()) :: board()
  def from_shorthand!(shorthand) do
    shorthand
    |> String.split("/")
    |> Enum.map(fn rank ->
      rank
      |> String.graphemes()
      |> Enum.flat_map(fn char ->
        case char do
          "1" -> [nil]
          "2" -> [nil, nil]
          "3" -> [nil, nil, nil]
          "4" -> [nil, nil, nil, nil]
          "5" -> [nil, nil, nil, nil, nil]
          "6" -> [nil, nil, nil, nil, nil, nil]
          "7" -> [nil, nil, nil, nil, nil, nil, nil]
          "8" -> [nil, nil, nil, nil, nil, nil, nil, nil]
          _ -> [{char_to_piece!(char), color_of_piece!(char)}]
        end
      end)
    end)
  end
end
