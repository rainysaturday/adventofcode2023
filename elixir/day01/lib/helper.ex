defmodule Helpers do
  @spec read_input_by_lines(charlist()) :: [charlist()]
  def read_input_by_lines(path) do
    {:ok, contents} = File.read(path)
    contents |> String.split("\n", trim: true)
  end
end
