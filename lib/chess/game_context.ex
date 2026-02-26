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

  @doc """
  Creates a new GameContext with default values and optional overrides.
  """
  @spec new(Enum.t()) :: t()
  def new(attrs \\ []) do
    defaults = %__MODULE__{
      board: nil,
      last_board: nil,
      moves: [],
      active_color: :white,
      moved_positions: MapSet.new()
    }

    struct!(defaults, attrs)
  end
end
