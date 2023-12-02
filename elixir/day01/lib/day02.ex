defmodule Game do
  defstruct game: 0, sets: []
end

defmodule GameSet do
  defstruct blue: 0, red: 0, green: 0
end

defmodule Day02 do
  @moduledoc """
  Documentation for `Day02`.
  """

  @doc """
    iex> Day02.part1
    2156
  """
  def part1 do
    max_cubes = %GameSet{red: 12, green: 13, blue: 14}

    Helpers.read_input_by_lines("../../inputs/day02.txt")
    |> Enum.map(&line_to_obj/1)
    |> Enum.filter(&is_game_possible(&1, max_cubes))
    |> Enum.map(fn %{game: gid} -> gid end)
    |> Enum.sum()
  end

  @doc """
    iex> Day02.part2
    66909
  """
  def part2 do
    Helpers.read_input_by_lines("../../inputs/day02.txt")
    |> Enum.map(&line_to_obj/1)
    |> Enum.map(&minimum_game_set/1)
    |> Enum.map(&power_of/1)
    |> Enum.sum()
  end

  def minimum_game_set(%{sets: sets}) do
    Enum.reduce(sets, List.first(sets), fn set, acc ->
      %{red: r, green: g, blue: b} = set
      %{red: ar, green: ag, blue: ab} = acc

      %{
        red: max(r, ar),
        green: max(g, ag),
        blue: max(b, ab)
      }
    end)
  end

  def power_of(%{red: r, green: g, blue: b}) do
    r * g * b
  end

  @spec is_game_possible(Game, GameSet) :: boolean()
  def is_game_possible(game, available) do
    %{sets: sets} = game

    sets
    |> Enum.all?(fn s ->
      %{red: r, green: g, blue: b} = s
      %{red: ar, green: ag, blue: ab} = available
      ar >= r && ag >= g && ab >= b
    end)
  end

  @doc """
    iex> Day02.line_to_obj("Game 1: 4 blue, 4 red, 16 green; 14 green, 5 red; 1 blue, 3 red, 5 green")
    %Game { game: 1, sets: [%GameSet { blue: 4, red: 4, green: 16}, %GameSet {blue: 0, red: 5, green: 14}, %GameSet {blue: 1, red: 3, green: 5}] }
  """
  def line_to_obj(l) do
    [game_str, sets_str] = String.split(l, ":", global: false)
    sets = String.split(sets_str, ";")
    %Game{game: parse_game_str(game_str), sets: sets |> Enum.map(&parse_set_str/1)}
  end

  @doc """
    iex> Day02.parse_game_str("Game 1")
    1
  """
  def parse_game_str(str) do
    [_game, val] = String.split(str, " ")
    {val, _rest} = Integer.parse(val)
    val
  end

  @doc """
    iex> Day02.parse_set_str("4 blue, 4 red, 16 green")
    %GameSet{ blue: 4, red: 4, green: 16}
  """
  def parse_set_str(str) do
    %GameSet{
      blue: parse_set_given_str(str, "blue"),
      red: parse_set_given_str(str, "red"),
      green: parse_set_given_str(str, "green")
    }
  end

  @doc """
    iex> Day02.parse_set_given_str("4 blue, 4 red, 16 green", "blue")
    4
  """
  def parse_set_given_str(str, substr) do
    String.split(str, ",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn pick ->
      [val, s] = String.split(pick, " ", global: false)

      if s == substr do
        {val, _rest} = Integer.parse(val)
        val
      else
        0
      end
    end)
    |> Enum.sum()
  end
end
