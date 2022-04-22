defmodule GameTest do
  use ExUnit.Case, async: true

  test "initial state" do
    game = Game.new()
    assert game.state == :ready
    assert Game.score(game) == nil
  end

  test "initial open frame" do
    game = Game.new()
    {:ok, game} = Game.roll(game, 3)

    assert Game.score(game) == nil
    assert hd(game.frames) == %Frame{rolls: [3], score: nil}

    {:ok, game} = Game.roll(game, 2)
    assert hd(game.frames) == %Frame{rolls: [2, 3], score: 5}
    assert Game.score(game) == 5
  end

  test "second open frame" do
    game = roll_em([8, 1, 3])
    assert game.frames == [%Frame{rolls: [3], score: nil}, %Frame{rolls: [1, 8], score: 9}]

    {:ok, game} = Game.roll(game, 4)

    assert game.frames == [%Frame{rolls: [4, 3], score: 16}, %Frame{rolls: [1, 8], score: 9}]
  end

  test "all open frames" do
    game = roll_em([3, 4, 2, 6, 9, 0, 2, 2, 2, 1, 0, 0, 0, 6, 2, 4, 2, 6, 2])

    assert game.state == :ready
    assert Game.score(game) == 51

    {:ok, game} = Game.roll(game, 1)

    assert hd(game.frames) == %Frame{rolls: [1, 2], score: 54}
    assert game.state == :done
    assert Game.score(game) == 54

    assert {:error, "Game is done"} = Game.roll(game, 8)
  end

  test "spare" do
    game = Game.new()
    {:ok, game} = Game.roll(game, 3)
    {:ok, game} = Game.roll(game, 7)
    assert hd(game.frames) == %Frame{rolls: [7, 3], score: 10}
    assert Game.score(game) == 10

    {:ok, game} = Game.roll(game, 2)
    assert game.frames == [%Frame{rolls: [2], score: nil}, %Frame{rolls: [7, 3], score: 12}]

    {:ok, game} = Game.roll(game, 6)
    assert game.frames == [%Frame{rolls: [6, 2], score: 20}, %Frame{rolls: [7, 3], score: 12}]
  end

  test "multiple spares" do
    game = roll_em([2, 8, 1, 9, 6, 4, 2, 2])
    assert Game.score(game) == 43
  end

  test "strike" do
    game = Game.new()
    {:ok, game} = Game.roll(game, 10)
    assert hd(game.frames) == %Frame{rolls: [10], score: nil}
    assert Game.score(game) == nil

    {:ok, game} = Game.roll(game, 2)
    assert game.frames == [%Frame{rolls: [2], score: nil}, %Frame{rolls: [10], score: 12}]

    {:ok, game} = Game.roll(game, 6)
    assert game.frames == [%Frame{rolls: [6, 2], score: 26}, %Frame{rolls: [10], score: 18}]
    assert Game.score(game) == 26
  end

  test "multiple strikes" do
    game = roll_em([10, 10, 10, 10, 10, 2, 3])
    assert Game.score(game) == 132
  end

  test "wild game" do
    game = roll_em([10, 10, 10, 10, 10, 10, 10, 10, 2, 3])
    assert Game.score(game) == 222
  end

  test "strikes and spares intermixed" do
    game = roll_em([10, 10, 3, 7, 10, 8, 2, 10, 0, 10, 7, 1])
    assert Game.score(game) == 148

    game = roll_em([3, 7, 10, 8, 2, 4, 5])
    assert Game.score(game) == 63
  end

  test "10th frame open" do
    game = roll_nine_strikes()

    {:ok, game} = Game.roll(game, 6)
    {:ok, game} = Game.roll(game, 1)

    assert Game.score(game) == 260
    assert game.state == :done
  end

  test "10th frame spare" do
    game = roll_nine_strikes()

    {:ok, game} = Game.roll(game, 6)
    {:ok, game} = Game.roll(game, 4)
    {:ok, game} = Game.roll(game, 7)

    assert Game.score(game) == 273
    assert game.state == :done
  end

  test "Another 10th frame spare" do
    game = roll_nine_strikes()

    {:ok, game} = Game.roll(game, 0)
    {:ok, game} = Game.roll(game, 10)
    {:ok, game} = Game.roll(game, 7)

    assert Game.score(game) == 267
    assert game.state == :done
  end

  test "10th frame strike" do
    game = roll_nine_strikes()

    {:ok, game} = Game.roll(game, 10)
    {:ok, game} = Game.roll(game, 10)
    {:ok, game} = Game.roll(game, 7)

    assert Game.score(game) == 297
    assert game.state == :done
  end

  test "perfect game" do
    game = roll_nine_strikes()

    {:ok, game} = Game.roll(game, 10)
    {:ok, game} = Game.roll(game, 10)
    {:ok, game} = Game.roll(game, 10)

    assert Game.score(game) == 300
    assert game.state == :done
  end

  defp roll_em(rolls), do: roll_em(Game.new(), rolls)

  defp roll_em(game, rolls) do
    Enum.reduce(rolls, game, fn each, acc ->
      {:ok, game} = Game.roll(acc, each)
      game
    end)
  end

  defp roll_nine_strikes do
    roll_em([10, 10, 10, 10, 10, 10, 10, 10, 10])
  end
end
