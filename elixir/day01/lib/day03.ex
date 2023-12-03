
defmodule Day03 do
  @doc """
    iex> Day03.part1
    539637
  """
  def part1 do
    lines = Helpers.read_input_by_lines("../../inputs/day03.txt")
    world = lines_to_map(lines)

    #traverse world
    parts = lines
    |> Enum.with_index(1)
    |> Enum.map(fn {l, y} -> {l, y - 1} end) # with_index starts at 1 :(
    |> Enum.reduce(%{}, fn {l, y}, acc ->
      0..String.length(l)
      |> Enum.reduce(acc, fn x, acc ->
        insert_if_part(world, x, y, acc)
      end)
    end)

    Map.values(parts)
    |> Enum.sum()
  end


  @doc """
    iex> Day03.part2
    82818007
  """
  def part2 do
    lines = Helpers.read_input_by_lines("../../inputs/day03.txt")
    world = lines_to_map(lines)

    #traverse world
    lines
    |> Enum.with_index(1)
    |> Enum.map(fn {l, y} -> {l, y - 1} end) # with_index starts at 1 :(
    |> Enum.reduce(0, fn {l, y}, acc ->
      Enum.reduce(0..String.length(l), acc, fn x, acc ->
        case world[y][x] do
          "*" -> surrounding = get_parts_surrounding(world, x, y)
          values = Map.values(surrounding)
          case length(values) do
            2 -> acc + (List.first(values) * List.last(values))
            _other -> acc
          end
          _other -> acc
        end
      end)
    end)
  end

  def get_parts_surrounding(world, x, y) do
    Enum.reduce((y - 1)..(y + 1), %{}, fn y, acc ->
      Enum.reduce((x - 1)..(x + 1), acc, fn x, acc ->
        insert_if_part(world, x, y, acc)
      end)
    end)
  end

  def insert_if_part(world, x, y, acc) do
    case get_num_from_map(world, x, y) do
      nil -> acc
      val ->
        if has_symbol_adjacent(world, x, y) do
          start = get_start_of_num(world[y], x)
          Map.put(acc, {start, y}, val)
        else
          acc
        end
    end
  end

   @doc """
    iex> Day03.has_symbol_adjacent(%{0 => %{0 => ".", 1 => "."}, 1 => %{0 => "1", 1 => "2"}}, 1, 1)
    false
    iex> Day03.has_symbol_adjacent(%{0 => %{0 => "=", 1 => "."}, 1 => %{0 => "1", 1 => "2"}}, 1, 1)
    true
  """
  def has_symbol_adjacent(m, x, y) do
    r = [-1, 0, 1]
    Enum.any?(r, fn dx ->
      Enum.any?(r, fn dy ->
        is_symbol(m, x + dx, y + dy)
       end)
    end)
  end

  @doc """
    iex> Day03.is_symbol(%{0 => %{0 => "=", 1 => "."}, 1 => %{0 => "1", 1 => "2"}}, 1, 1)
    false
    iex> Day03.is_symbol(%{0 => %{0 => "=", 1 => "."}, 1 => %{0 => "1", 1 => "2"}}, 0, 0)
    true
  """
  def is_symbol(m, x, y) do
    case m[y] do
      nil -> false
      line -> case line[x] do
        nil -> false
        "." -> false
        _other -> case get_num_from_map(m, x, y) do
          nil -> true # The current position is not outside, and also not a dot or a number, so must be a symbol
          _isnum -> false
        end
      end
    end
  end



  @doc """
    iex> Day03.get_num_from_map(%{0 => %{0 => ".", 1 => "."}, 1 => %{0 => "1", 1 => "2"}}, 1, 1)
    12
  """
  def get_num_from_map(m, x, y) do
    case m[y] do
      nil -> nil
      l -> case get_num_from_line(l, x, 0) do
        "" -> nil
        num -> {val, _rest} = Integer.parse(num)
          val
      end
    end
  end

  @doc """
    iex> Day03.get_num_from_line(%{0 => "1", 1 => "2"}, 1, 0)
    "12"
  """
  def get_num_from_line(l, x, dir) do
    case l[x] do
      nil -> ""
      c ->
        case {Integer.parse(c), dir} do
          {:error, _} -> ""
          {{_val, _rest}, 0} -> get_num_from_line(l, x - 1, -1) <> c <> get_num_from_line(l, x + 1, 1)
          {{_val, _rest}, -1} -> get_num_from_line(l, x - 1, dir) <> c
          {{_val, _rest}, 1} -> c <> get_num_from_line(l, x + 1, dir)
        end
    end
  end

  @doc """
    iex> Day03.get_start_of_num(%{0 => "1", 1 => "2"}, 1)
    0
  """
  def get_start_of_num(l, x) do
    case l[x] do
      nil -> nil
      c ->
        case Integer.parse(c) do
          :error -> nil
          {_val, _rest} -> case get_start_of_num(l, x - 1) do
            nil -> x
            otherwise -> otherwise
          end
        end
    end
  end

  @doc """
    iex> Day03.lines_to_map(["..", "--"])
    %{0 => %{0 => ".", 1 => "."}, 1 => %{0 => "-", 1 => "-"}}
  """
  def lines_to_map(lines) do
    lines
    |> Enum.with_index(1)
    |> Enum.reduce(%{}, fn {l, i}, acc ->
      l = line_to_map(l)
      Map.put(acc, i - 1, l)
    end)
  end

  @doc """
    iex> Day03.line_to_map("..1=")
    %{0 => ".", 1 => ".", 2 => "1", 3 => "="}
  """
  #spec line_to_map(str :: charlist()) :: map()
  def line_to_map(str) do
    String.split(str, "")
    |> Enum.filter(fn s -> String.length(s) > 0 end)
    |> Enum.with_index(1)
    |> Enum.map(fn {s, i} -> {i - 1, s} end)
    |> Enum.reduce(%{}, fn val, acc ->
      {key, val} = val
      Map.put(acc, key, val)
    end)
  end



end
