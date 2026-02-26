defmodule Chess.Piece.King do
  @moduledoc """
  The King piece in chess.

  - Moves one square in any direction.
  - Cannot move into a square that is attacked by an opponent.
  - Castling is not yet implemented.
  """
  alias Chess.{Board, GameContext, Piece, Pos}
  defstruct []

  defimpl Piece do
    def valid_moves(
          %Chess.Piece.King{},
          %GameContext{board: board, active_color: color, moved_positions: moved_positions} =
            game_context,
          pos
        ) do
      directions = [{1, 0}, {-1, 0}, {0, 1}, {0, -1}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}]

      normal_moves =
        directions
        |> Enum.map(fn {dr, df} -> Pos.get_plus(pos, dr, df, :white) end)
        |> Enum.reject(&is_nil/1)
        |> Enum.filter(fn target_pos ->
          case Board.get_piece(board, target_pos) do
            {_type, ^color} -> false
            _ -> true
          end
        end)
        |> Enum.map(fn target_pos ->
          Board.as_unsafe_moved(board, pos, target_pos, {:king, color})
        end)
        |> Enum.filter(&Board.move_safe?(game_context, &1))

      normal_moves ++ castling_moves(game_context, pos, color, moved_positions)
    end

    defp castling_moves(%GameContext{} = game_context, pos, color, moved_positions) do
      starting_pos =
        if color == :white, do: Pos.from_notation("e1"), else: Pos.from_notation("e8")

      if pos != starting_pos || MapSet.member?(moved_positions, pos) ||
           Board.king_in_check?(game_context) do
        []
      else
        opponent_context = %GameContext{game_context | active_color: Chess.opposite_color(color)}

        [
          kingside_castle(game_context, opponent_context, pos, color, moved_positions),
          queenside_castle(game_context, opponent_context, pos, color, moved_positions)
        ]
        |> Enum.reject(&is_nil/1)
      end
    end

    defp kingside_castle(game_context, opponent_context, pos, color, moved_positions) do
      rook_pos = if color == :white, do: Pos.from_notation("h1"), else: Pos.from_notation("h8")
      transit_pos = if color == :white, do: Pos.from_notation("f1"), else: Pos.from_notation("f8")
      target_pos = if color == :white, do: Pos.from_notation("g1"), else: Pos.from_notation("g8")

      if Board.get_piece(game_context.board, rook_pos) == {:rook, color} &&
           !MapSet.member?(moved_positions, rook_pos) &&
           path_clear?(game_context.board, [transit_pos, target_pos]) &&
           !Board.attacked?(opponent_context, transit_pos) &&
           !Board.attacked?(opponent_context, target_pos) do
        # Move both king and rook
        {board_with_king, _} =
          Board.as_unsafe_moved(game_context.board, pos, target_pos, {:king, color})

        {final_board, _} =
          Board.as_unsafe_moved(board_with_king, rook_pos, transit_pos, {:rook, color})

        {final_board, target_pos}
      else
        nil
      end
    end

    defp queenside_castle(game_context, opponent_context, pos, color, moved_positions) do
      rook_pos = if color == :white, do: Pos.from_notation("a1"), else: Pos.from_notation("a8")
      # Square 'b' must be clear, but doesn't have to be safe from attack
      b_pos = if color == :white, do: Pos.from_notation("b1"), else: Pos.from_notation("b8")
      transit_pos = if color == :white, do: Pos.from_notation("d1"), else: Pos.from_notation("d8")
      target_pos = if color == :white, do: Pos.from_notation("c1"), else: Pos.from_notation("c8")

      if can_queenside_castle?(
           game_context,
           opponent_context,
           rook_pos,
           b_pos,
           transit_pos,
           target_pos,
           color,
           moved_positions
         ) do
        {board_with_king, _} =
          Board.as_unsafe_moved(game_context.board, pos, target_pos, {:king, color})

        {final_board, _} =
          Board.as_unsafe_moved(board_with_king, rook_pos, transit_pos, {:rook, color})

        {final_board, target_pos}
      else
        nil
      end
    end

    defp can_queenside_castle?(
           game_context,
           opponent_context,
           rook_pos,
           b_pos,
           transit_pos,
           target_pos,
           color,
           moved_positions
         ) do
      Board.get_piece(game_context.board, rook_pos) == {:rook, color} &&
        !MapSet.member?(moved_positions, rook_pos) &&
        path_clear?(game_context.board, [b_pos, target_pos, transit_pos]) &&
        !Board.attacked?(opponent_context, transit_pos) &&
        !Board.attacked?(opponent_context, target_pos)
    end

    defp path_clear?(board, positions) do
      Enum.all?(positions, fn p -> is_nil(Board.get_piece(board, p)) end)
    end

    def type(_piece), do: :king

    def attacks(_piece, %GameContext{active_color: _color}, pos) do
      directions = [{1, 0}, {-1, 0}, {0, 1}, {0, -1}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}]

      directions
      |> Enum.map(fn {dr, df} -> Pos.get_plus(pos, dr, df, :white) end)
      |> Enum.reject(&is_nil/1)
    end
  end
end
