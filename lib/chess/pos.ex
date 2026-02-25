defmodule Chess.Pos do
  @moduledoc """
  Defines the position of a piece on the chess board.

  Represents the position as rank and file, where rank
  means rows (0 to 7) and file means columns (0 to 7).
  (e.g., a1 is {0, 0}, h8 is {7, 7}).
  """

  defstruct [:rank, :file]

  @doc """
  Creates a new position with the given rank and file.

  On invalid input (rank or file not between 0 and 7), it raises an ArgumentError.
  """
  @spec new(rank :: integer(), file :: integer()) :: %Chess.Pos{}
  def new(rank, file) when rank in 0..7 and file in 0..7 do
    %Chess.Pos{rank: rank, file: file}
  end

  def new(_rank, _file) do
    raise ArgumentError, "Rank and file must be between 0 and 7"
  end

  @doc """
  Converts algebraic notation (e.g., "a1") to a position.
  In FEN/standard chess:
  - 'a' to 'h' maps to file 0 to 7.
  - '1' to '8' maps to rank 7 to 0 (since rank 8 is at the top/index 0).
  """
  @spec from_notation(String.t()) :: %Chess.Pos{}
  def from_notation(<<file_char, rank_char>>) when file_char in ?a..?h and rank_char in ?1..?8 do
    file = file_char - ?a
    rank = 8 - (rank_char - ?0)
    new(rank, file)
  end

  @doc """
  Converts a position to algebraic notation (e.g., "a1").
  """
  @spec to_notation(%Chess.Pos{}) :: String.t()
  def to_notation(%Chess.Pos{rank: rank, file: file}) do
    file_char = <<?a + file>>
    rank_char = <<?0 + (8 - rank)>>
    file_char <> rank_char
  end

  @doc """
  Returns a new position by applying the given rank and file offsets to the current position.
  If the resulting position is out of bounds (not between 0 and 7 for both rank and file), it returns nil.
  """
  @spec get_plus(
          pos :: %Chess.Pos{},
          rank_offset :: integer(),
          file_offset :: integer(),
          color :: Chess.color()
        ) :: %Chess.Pos{} | nil
  def get_plus(pos, rank_offset, file_offset, color) do
    case color do
      :white -> get_plus(pos, -rank_offset, file_offset)
      :black -> get_plus(pos, rank_offset, file_offset)
    end
  end

  defp get_plus(pos, rank_offset, file_offset) do
    new_rank = pos.rank + rank_offset
    new_file = pos.file + file_offset

    if new_rank in 0..7 and new_file in 0..7 do
      %Chess.Pos{rank: new_rank, file: new_file}
    else
      nil
    end
  end
end
