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
  alias Chess.Board.State
  alias Chess.GameContext
  alias Chess.Pos

  @doc """
  Starts a new chess game under the BoardSupervisor.
  """
  def start_game do
    DynamicSupervisor.start_child(Chess.BoardSupervisor, {__MODULE__, State.new()})
  end

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  @spec init(State.t()) :: {:ok, State.t()}
  def init(%State{} = state) do
    {:ok, state}
  end

  @doc """
  Makes a move on the board.
  """
  @spec move(pid(), move()) :: :ok | {:error, any()}
  def move(pid, move_str) do
    GenServer.call(pid, {:move, move_str})
  end

  @doc """
  Returns the move history of the board.
  """
  @spec history(pid()) :: list(move())
  def history(pid) do
    GenServer.call(pid, {:history})
  end

  @impl true
  @spec handle_call({:move, move()} | {:history}, any(), State.t()) ::
          {:reply, :ok | {:error, any()} | list(move()), State.t()}
  def handle_call({:move, move_str}, _from, %State{} = state) do
    game_context = %GameContext{
      board: state.board,
      last_board: state.last_board,
      moves: state.moves,
      active_color: state.active_color,
      moved_positions: state.moved_positions
    }

    case Chess.Notation.parse(game_context, move_str) do
      {:ok, %{board: new_board, from: from_pos}} ->
        new_state = %{
          state
          | moves: state.moves ++ [move_str],
            board: new_board,
            last_board: state.board,
            active_color: Chess.opposite_color(state.active_color),
            moved_positions: MapSet.put(state.moved_positions, from_pos)
        }

        {:reply, :ok, new_state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:history}, _from, %State{} = state) do
    {:reply, state.moves, state}
  end

  @doc """
  Returns a new board state by moving a piece from the `from` position to the `to` position.

  Note on validation: this function does not perform any validation on the move.
  It assumes that the move is valid and simply updates the board state accordingly.
  """
  @spec as_unsafe_moved(
          board :: board(),
          from :: Pos.t(),
          to :: Pos.t(),
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
  @spec get_piece(board :: board(), pos :: Pos.t()) :: Chess.Piece.t() | nil
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
  Returns true if the square at `pos` is attacked by pieces of the active color in `game_context`.
  """
  @spec attacked?(GameContext.t(), Pos.t()) :: boolean()
  def attacked?(%GameContext{board: board, active_color: by_color} = game_context, pos) do
    all_pieces_with_pos(board)
    |> Enum.filter(fn {piece, _pos} -> match?({_type, ^by_color}, piece) end)
    |> Enum.any?(fn {{type, _}, piece_pos} ->
      piece_struct = to_piece_struct(type)
      attacks = Chess.Piece.attacks(piece_struct, game_context, piece_pos)
      pos in attacks
    end)
  end

  @doc """
  Returns true if the king of the current turn's color is in check.
  """
  @spec king_in_check?(GameContext.t()) :: boolean()
  def king_in_check?(%GameContext{board: board, active_color: color} = game_context) do
    king_pos = find_king_position(board, color)
    opponent_context = %GameContext{game_context | active_color: Chess.opposite_color(color)}
    king_pos && attacked?(opponent_context, king_pos)
  end

  @doc """
  Returns true if the given move (represented as {new_board, new_pos}) is safe,
  meaning it does not leave the king in check.
  """
  @spec move_safe?(GameContext.t(), Chess.Piece.new_state()) :: boolean()
  def move_safe?(%GameContext{} = game_context, {new_board, _new_pos}) do
    new_context = %GameContext{game_context | board: new_board}
    !king_in_check?(new_context)
  end

  defp find_king_position(board, color) do
    all_pieces_with_pos(board)
    |> Enum.find_value(fn {piece, pos} ->
      if piece == {:king, color} do
        pos
      else
        nil
      end
    end)
  end

  @doc """
  Returns a list of all legal moves for the active color in `game_context`.
  """
  @spec all_legal_moves(GameContext.t()) :: list(%{from: Pos.t(), to: Pos.t(), board: board()})
  def all_legal_moves(%GameContext{board: board, active_color: color} = game_context) do
    all_pieces_with_pos(board)
    |> Enum.filter(fn {piece, _pos} -> match?({_type, ^color}, piece) end)
    |> Enum.flat_map(fn {{type, _}, piece_pos} ->
      piece_struct = to_piece_struct(type)

      Chess.Piece.valid_moves(piece_struct, game_context, piece_pos)
      |> Enum.map(fn {new_board, target_pos} ->
        %{from: piece_pos, to: target_pos, board: new_board, piece_type: type}
      end)
    end)
  end

  defp all_pieces_with_pos(board) do
    board
    |> Enum.with_index()
    |> Enum.flat_map(fn {rank_pieces, rank_idx} ->
      rank_pieces
      |> Enum.with_index()
      |> Enum.map(fn {piece, file_idx} ->
        {piece, Pos.new(rank_idx, file_idx)}
      end)
    end)
    |> Enum.reject(fn {piece, _pos} -> is_nil(piece) end)
  end

  defp to_piece_struct(type) do
    case type do
      :pawn -> %Chess.Piece.Pawn{}
      :rook -> %Chess.Piece.Rook{}
      :knight -> %Chess.Piece.Knight{}
      :bishop -> %Chess.Piece.Bishop{}
      :queen -> %Chess.Piece.Queen{}
      :king -> %Chess.Piece.King{}
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
    |> Enum.map(fn rank_str ->
      rank_str
      |> String.graphemes()
      |> Enum.flat_map(&parse_shorthand_char/1)
    end)
  end

  defp parse_shorthand_char(char) do
    if char in ~w(1 2 3 4 5 6 7 8) do
      List.duplicate(nil, String.to_integer(char))
    else
      [{char_to_piece!(char), color_of_piece!(char)}]
    end
  end
end
