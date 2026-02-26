defmodule Chess.Notation do
  @moduledoc """
  Parses Standard Algebraic Notation (SAN) moves.
  """
  alias Chess.{Board, GameContext, Pos}

  @doc """
  Parses a SAN move string and returns the matching legal move.
  Returns {:ok, move} or {:error, reason}.
  """
  def parse(%GameContext{} = game_context, move_str) do
    all_moves = Board.all_legal_moves(game_context)

    case match_move(move_str, all_moves) do
      nil -> {:error, "Invalid or ambiguous move: #{move_str}"}
      move -> {:ok, move}
    end
  end

  defp match_move("O-O", all_moves) do
    # Castling is not yet implemented in pieces, but we can match the notation
    Enum.find(all_moves, fn m ->
      m.piece_type == :king && abs(m.to.file - m.from.file) == 2 && m.to.file > m.from.file
    end)
  end

  defp match_move("O-O-O", all_moves) do
    Enum.find(all_moves, fn m ->
      m.piece_type == :king && abs(m.to.file - m.from.file) == 2 && m.to.file < m.from.file
    end)
  end

  defp match_move(move_str, all_moves) do
    # Strip check/mate symbols
    move_str = String.trim_trailing(move_str, "+") |> String.trim_trailing("#")

    regex =
      ~r/^(?<piece>[KQRBN])?(?<from_file>[a-h])?(?<from_rank>[1-8])?x?(?<to>[a-h][1-8])(?<promotion>=[QRBN])?$/

    case Regex.named_captures(regex, move_str) do
      %{"piece" => p, "from_file" => ff, "from_rank" => fr, "to" => to_s, "promotion" => prom} ->
        to_pos = Pos.from_notation(to_s)
        piece_type = char_to_type(empty_to_nil(p))

        all_moves
        |> Enum.filter(&(&1.to == to_pos && &1.piece_type == piece_type))
        |> filter_by_origin(empty_to_nil(ff), empty_to_nil(fr))
        |> filter_by_promotion(empty_to_nil(prom))
        |> ensure_single_match()

      _ ->
        nil
    end
  end

  defp empty_to_nil(""), do: nil
  defp empty_to_nil(s), do: s

  defp char_to_type(nil), do: :pawn
  defp char_to_type("K"), do: :king
  defp char_to_type("Q"), do: :queen
  defp char_to_type("R"), do: :rook
  defp char_to_type("B"), do: :bishop
  defp char_to_type("N"), do: :knight

  defp filter_by_origin(moves, nil, nil), do: moves

  defp filter_by_origin(moves, file_str, nil) do
    file = hd(String.to_charlist(file_str)) - ?a
    Enum.filter(moves, &(&1.from.file == file))
  end

  defp filter_by_origin(moves, nil, rank_str) do
    rank = 8 - String.to_integer(rank_str)
    Enum.filter(moves, &(&1.from.rank == rank))
  end

  defp filter_by_origin(moves, file_str, rank_str) do
    file = hd(String.to_charlist(file_str)) - ?a
    rank = 8 - String.to_integer(rank_str)
    Enum.filter(moves, &(&1.from.file == file && &1.from.rank == rank))
  end

  defp filter_by_promotion(moves, ""), do: moves
  defp filter_by_promotion(moves, nil), do: moves

  defp filter_by_promotion(moves, "=" <> char) do
    type = char_to_type(char)
    # When promoting, the resulting board will have the new piece type at the target square
    Enum.filter(moves, fn m ->
      case Board.get_piece(m.board, m.to) do
        {^type, _} -> true
        _ -> false
      end
    end)
  end

  defp ensure_single_match([move]), do: move
  defp ensure_single_match(_), do: nil
end
