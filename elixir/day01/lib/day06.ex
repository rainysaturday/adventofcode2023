defmodule Run do
  defstruct time: Integer, dist: Integer
end

defmodule Day06 do
  @doc """
    iex> Day06.part1
    1195150
  """
  def part1 do
    lines = Helpers.read_input_by_lines("../../inputs/day06.txt")
    runs = parse(lines)

    runs
    |> Enum.map(fn run -> num_wins(run.time, run.dist) end)
    |> Enum.reduce(1, fn wins, acc -> wins * acc end)
  end

  @doc """
    iex> Day06.part2
    42550411
  """
  def part2 do
    lines =
      Helpers.read_input_by_lines("../../inputs/day06.txt")
      |> Enum.map(fn l -> String.replace(l, " ", "") end)
      |> Enum.map(fn l -> String.replace(l, ":", ": ") end)

    [run] = parse(lines)
    num_wins(run.time, run.dist)
  end

  @doc """
    iex> Day06.max_dist_for_run(7)   
    12
  """
  def max_dist_for_run(max_time) do
    Enum.reduce(1..max_time, 0, fn time, acc ->
      max(acc, dist_when_holding(time, max_time))
    end)
  end

  @doc """
    iex> Day06.num_wins(7, 9)   
    4
  """
  def num_wins(max_time, win_dist) do
    Enum.filter(1..max_time, fn time ->
      dist_when_holding(time, max_time) > win_dist
    end)
    |> Enum.count()
  end

  @doc """
    iex> Day06.dist_when_holding(2, 10)   
    16
    iex> Day06.dist_when_holding(6, 7)   
    6
    iex> Day06.dist_when_holding(7, 7)   
    0
    iex> Day06.dist_when_holding(3, 7)   
    12
    iex> Day06.dist_when_holding(4, 7)   
    12
  """
  def dist_when_holding(time, max_time) do
    time_left = max_time - time
    speed = time

    if time_left > 0 do
      speed * time_left
    else
      0
    end
  end

  # Time:        54     94     65     92
  # Distance:   302   1476   1029   1404
  def parse(lines) do
    [time_str, dist_str] = lines

    Enum.zip(parse_ints(time_str), parse_ints(dist_str))
    |> Enum.map(fn {t, d} -> %Run{time: t, dist: d} end)
  end

  def parse_ints(line) do
    String.split(line, " ")
    |> Enum.filter(fn s -> String.length(s) > 0 end)
    |> Enum.map(fn s ->
      case Integer.parse(s) do
        {val, _rest} -> val
        _ -> nil
      end
    end)
    |> Enum.filter(fn v -> v != nil end)
  end
end
