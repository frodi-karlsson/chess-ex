defmodule Chess.GameContext do
  @moduledoc """
  A struct to hold the necessary context for piece move generation and validation.
  """
  @type t :: %__MODULE__{
          board: list(list({atom(), atom()} | nil)),
          last_board: list(list({atom(), atom()} | nil)) | nil,
          moves: list(String.t()),
          active_color: Chess.color(),
          moved_positions: MapSet.t()
        }

  defstruct [
    :board,
    :last_board,
    :moves,
    :active_color,
    :moved_positions
  ]
end
