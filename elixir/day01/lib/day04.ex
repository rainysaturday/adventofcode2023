defmodule Card do
  defstruct id: Integer, winning: %{}, holding: %{}
end

defmodule Day04 do
  @doc """
    iex> Day04.part1
    17803
  """
  def part1 do
    Helpers.read_input_by_lines("../../inputs/day04.txt")
    |> Enum.map(&parse_line/1)
    |> Enum.map(&matching_winning_numbers/1)
    |> Enum.map(&match_score/1)
    |> Enum.sum()
  end

  @doc """
    iex> Day04.part2
    5554894
  """
  def part2 do
    cards =
      Helpers.read_input_by_lines("../../inputs/day04.txt")
      |> Enum.map(&parse_line/1)

    # Start with 1 of each card
    card_counter = Enum.reduce(cards, %{}, fn c, acc -> Map.put(acc, c.id, 1) end)

    # Go over all cards, and check for winning
    cards
    |> Enum.reduce(card_counter, fn card, card_counter ->
      card_count = Map.get(card_counter, card.id)
      wins = matching_winning_numbers(card)

      if wins > 0 do
        Enum.reduce((card.id + 1)..(card.id + wins), card_counter, fn current_id, card_counter ->
          current_score = Map.get(card_counter, current_id)
          Map.put(card_counter, current_id, current_score + card_count)
        end)
      else
        card_counter
      end
    end)
    |> Map.values()
    |> Enum.sum()
  end

  def match_score(1) do
    1
  end

  def match_score(0) do
    0
  end

  @doc """
    iex> Day04.match_score(4)
    8
    iex> Day04.match_score(3)
    4
    iex> Day04.match_score(1)
    1
  """
  def match_score(num_matches) do
    Integer.pow(2, num_matches - 1)
  end

  @doc """
    iex> Day04.matching_winning_numbers(%Card{ id: 6, winning: %{ 11 => 1, 18 => 1, 13 => 1, 56 => 1, 72 => 1}, holding: %{ 74 => 1, 77 => 1, 10 => 1, 23 => 1, 35 => 1, 67 => 1, 36 => 1, 11 => 1 } })
    1
  """
  def matching_winning_numbers(card) do
    Map.keys(card.winning)
    |> Enum.filter(fn w -> Map.has_key?(card.holding, w) end)
    |> Enum.count()
  end

  @doc """
    iex> Day04.parse_line("Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11")
    %Card{ id: 6, winning: %{ 31 => 1, 18 => 1, 13 => 1, 56 => 1, 72 => 1}, holding: %{ 74 => 1, 77 => 1, 10 => 1, 23 => 1, 35 => 1, 67 => 1, 36 => 1, 11 => 1 } }
  """
  def parse_line(line) do
    [leading, numbers] = String.split(line, ":", global: false)
    [winning, holding] = String.split(numbers, "|", global: false)

    [_, id] =
      String.split(leading, " ", global: false) |> Enum.filter(fn s -> String.length(s) > 0 end)

    winning = parse_nums(winning)
    holding = parse_nums(holding)
    {id, _rest} = Integer.parse(id)

    %Card{
      id: id,
      winning: winning,
      holding: holding
    }
  end

  def parse_nums(str) do
    String.split(str, " ")
    |> Enum.filter(fn s -> String.length(s) > 0 end)
    |> Enum.map(fn s ->
      {val, _rest} = Integer.parse(s)
      val
    end)
    |> Enum.reduce(%{}, fn i, acc ->
      Map.put(acc, i, 1)
    end)
  end
end
