defmodule Day1 do
  @moduledoc """
  Documentation for `Day1`.
  """

  @doc """
    iex> Day1.part1
    57346
  """
  def part1 do
    read_input_by_lines() |> Enum.map(&to_number/1) |> Enum.sum()
  end

  @doc """
    iex> Day1.part2
    57345
  """
  def part2 do
    read_input_by_lines()
    |> Enum.map(&replace_human_numbers/1)
    |> Enum.map(&to_number/1)
    |> Enum.sum()
  end

  @doc """

    iex> Day1.to_number("1.2.3")
    13

    iex> Day1.to_number("asdawd1wa.d2awd.3awd")
    13

    iex> Day1.to_number("7pqrst6teen")
    76
  """
  @spec to_number(charlist()) :: number
  def to_number(v) do
    v
    |> String.split("")
    |> Enum.map(fn string ->
      case Integer.parse(string) do
        {val, _rest} -> val
        :error -> -1
      end
    end)
    |> Enum.filter(fn a -> a >= 0 end)
    |> Enum.to_list()
    |> arr_to_number
  end

  @doc """
    iex> Day1.replace_human_numbers("2one")
    "21ne"

    iex> Day1.replace_human_numbers("2one22reight23")
    "21ne22r8ight23"
    iex> Day1.replace_human_numbers("7pqrstsixteen")
    "7pqrst6ixteen"
    iex> Day1.replace_human_numbers("sjtwonesix6cqbv4")
    "sj2w1ne6ix6cqbv4"
  """
  @spec replace_human_numbers(charlist()) :: charlist()
  def replace_human_numbers(str) do
    if String.length(str) == 0 do
      ""
    else
      str_numbers = [
        ~r/^one/,
        ~r/^two/,
        ~r/^three/,
        ~r/^four/,
        ~r/^five/,
        ~r/^six/,
        ~r/^seven/,
        ~r/^eight/,
        ~r/^nine/
      ]

      matching =
        str_numbers
        |> Enum.with_index(1)
        |> Enum.find(fn {s, _i} -> String.match?(str, s) end)

      case matching do
        {_s, i} ->
          {_h, tail} = String.split_at(str, 1)
          Integer.to_string(i) <> replace_human_numbers(tail)

        nil ->
          {h, tail} = String.split_at(str, 1)
          h <> replace_human_numbers(tail)
      end
    end
  end

  @doc """
    iex> Day1.arr_to_number([1,2,3])
    13
  """
  @spec arr_to_number(list()) :: number
  def arr_to_number(arr) do
    List.first(arr) * 10 + List.last(arr)
  end

  def read_input_by_lines do
    {:ok, contents} = File.read("../../inputs/day01.txt")
    contents |> String.split("\n", trim: true)
  end
end
