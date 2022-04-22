defmodule Frame do
  defstruct rolls: [], score: nil

  def new(roll) do
    %Frame{rolls: [roll]}
  end

  def new(rolls, score) do
    %Frame{rolls: rolls, score: score}
  end
end
