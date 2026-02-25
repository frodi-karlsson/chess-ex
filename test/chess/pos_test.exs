defmodule Chess.PosTest do
  use ExUnit.Case
  alias Chess.Pos

  describe "new" do
    test "should create a new position given valid rank and file" do
      pos = Pos.new(1, 2)
      assert pos.rank == 1
      assert pos.file == 2
    end

    test "should raise an error for invalid rank or file" do
      assert_raise ArgumentError, fn -> Pos.new(-1, 0) end
      assert_raise ArgumentError, fn -> Pos.new(0, -1) end
      assert_raise ArgumentError, fn -> Pos.new(8, 0) end
      assert_raise ArgumentError, fn -> Pos.new(0, 8) end
    end
  end

  describe "get_plus" do
    test "should return a new position with the given offsets for white" do
      pos = Pos.new(2, 2)
      new_pos = Pos.get_plus(pos, 1, 1, :white)
      assert new_pos.rank == 1
      assert new_pos.file == 3
    end

    test "should return a new position with the given offsets for black" do
      pos = Pos.new(2, 2)
      new_pos = Pos.get_plus(pos, 1, 1, :black)
      assert new_pos.rank == 3
      assert new_pos.file == 3
    end

    test "should return nil if the resulting position is out of bounds" do
      pos = Pos.new(0, 0)
      assert Pos.get_plus(pos, 1, 0, :white) == nil
      assert Pos.get_plus(pos, 0, -1, :white) == nil
      
      pos_black = Pos.new(7, 7)
      assert Pos.get_plus(pos_black, 1, 0, :black) == nil
      assert Pos.get_plus(pos_black, 0, 1, :black) == nil
    end
  end

  describe "from_notation" do
    test "should convert algebraic notation to a position" do
      assert Pos.from_notation("a1") == %Pos{rank: 7, file: 0}
      assert Pos.from_notation("h8") == %Pos{rank: 0, file: 7}
      assert Pos.from_notation("e4") == %Pos{rank: 4, file: 4}
    end
  end

  describe "to_notation" do
    test "should convert a position to algebraic notation" do
      assert Pos.to_notation(%Pos{rank: 7, file: 0}) == "a1"
      assert Pos.to_notation(%Pos{rank: 0, file: 7}) == "h8"
      assert Pos.to_notation(%Pos{rank: 4, file: 4}) == "e4"
    end
  end
end
