defmodule Game do
  defstruct frames: [], state: :ready

  def new do
    %Game{}
  end

  def roll(%Game{state: :done}, _pins), do: {:error, "Game is done"}

  def roll(game, pins) do
    game = %{game | frames: update_frames(game.frames, pins)}
    {:ok, update_game_state(game)}
  end

  def score(game), do: frame_score(game.frames)

  defp update_frames([%Frame{rolls: [roll_1, roll_2]} = f | rest] = frames, pins) when length(frames) == 10 and roll_1 + roll_2 == 10 do
    [Frame.new([roll_1, roll_2, pins], f.score + pins) | rest]
  end

  defp update_frames([%Frame{rolls: [10, 10]}, prev_f | rest] = frames, pins) when length(frames) == 10 do
    prev_f_score = prev_f.score + 10
    curr_f_score = prev_f_score + 20 + pins
    [Frame.new([10, 10, pins], curr_f_score), %{prev_f | score: prev_f_score} | rest]
  end

  defp update_frames([%Frame{rolls: [10]}, prev_f | rest] = frames, pins) when length(frames) == 10 do
    [Frame.new([10, pins], pins + 10 + prev_f.score), prev_f | rest]
  end

  defp update_frames([%Frame{rolls: [roll_1, roll_2]} = f | rest], pins) when roll_1 + roll_2 == 10 do
    [Frame.new(pins), %{f | score: f.score + pins} | rest]
  end

  defp update_frames([%Frame{rolls: [_roll_1, _roll_2]} = f | rest], pins) do
    [Frame.new(pins), f | rest]
  end

  defp update_frames([%Frame{rolls: [10]} = curr_strike, %Frame{rolls: [10]} = prev_strike | rest], pins) do
    prev_strike_score = prev_strike.score + pins
    curr_strike_score = prev_strike_score + 10 + pins

    [
      Frame.new([pins], pins + prev_strike_score + curr_strike_score),
      %{curr_strike | score: curr_strike_score},
      %{prev_strike | score: prev_strike_score}
      | rest
    ]
  end

  defp update_frames([%Frame{rolls: [10]} = f, prev_f | rest], pins) do
    [Frame.new(pins), %{f | score: pins + 10 + prev_f.score}, prev_f | rest]
  end

  defp update_frames([%Frame{rolls: [10]} = f | rest], pins) do
    [Frame.new(pins), %{f | score: pins + 10} | rest]
  end

  defp update_frames([%Frame{rolls: [first]}, %Frame{rolls: [10]} = strike | rest], pins) do
    strike_score = strike.score + pins
    [Frame.new([pins, first], pins + first + strike_score), %{strike | score: strike_score} | rest]
  end

  defp update_frames([%Frame{rolls: [first]}, prev_f | rest], pins) do
    [Frame.new([pins, first], pins + first + prev_f.score), prev_f | rest]
  end

  defp update_frames([%Frame{rolls: [first]} | rest], pins) do
    [Frame.new([pins, first], pins + first) | rest]
  end

  defp update_frames([], pins) do
    [Frame.new(pins)]
  end

  defp update_game_state(%Game{frames: [%Frame{rolls: [_one, _two, _three]} | _rest] = frames} = game) when length(frames) == 10 do
    %{game | state: :done}
  end

  defp update_game_state(%Game{frames: [%Frame{rolls: [one, two]} | _rest] = frames} = game) when length(frames) == 10 and one + two < 10 do
    %{game | state: :done}
  end

  defp update_game_state(game), do: game

  defp frame_score([]), do: nil
  defp frame_score([%Frame{score: nil}, %Frame{score: score} | _rest]), do: score
  defp frame_score([%Frame{score: score} | _rest]), do: score
end
