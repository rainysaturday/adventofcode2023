defmodule Hand do
  defstruct hand: String, bid: Integer
end

defmodule Day07 do
  @doc """
    iex> Day07.part1
    251029473
  """
  def part1 do
    Helpers.read_input_by_lines("../../inputs/day07.txt")
    |> Enum.map(&parse/1)
    |> Enum.sort(&rank_compare(&1, &2))
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {hand, i}, acc ->
      hand.bid * i + acc
    end)
  end

  @doc """
    iex> Day07.part2
    251003917
  """
  def part2 do
    Helpers.read_input_by_lines("../../inputs/day07.txt")
    |> Enum.map(&parse/1)
    |> Enum.sort(&rank_compare2(&1, &2))
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {hand, i}, acc ->
      hand.bid * i + acc
    end)
  end

  def rank_compare2(hand_a, hand_b) do
    ta = hand_type2(hand_a.hand)
    tb = hand_type2(hand_b.hand)

    if ta == tb do
      la = String.split(hand_a.hand, "")
      lb = String.split(hand_b.hand, "")

      {va, vb} =
        Enum.zip(la, lb)
        |> Enum.map(fn {va, vb} -> {card_strength2(va), card_strength2(vb)} end)
        |> Enum.find(fn {va, vb} ->
          va != vb
        end)

      va < vb
    else
      ta < tb
    end
  end

  def rank_compare(hand_a, hand_b) do
    ta = hand_type(hand_a.hand)
    tb = hand_type(hand_b.hand)

    if ta == tb do
      la = String.split(hand_a.hand, "")
      lb = String.split(hand_b.hand, "")

      {va, vb} =
        Enum.zip(la, lb)
        |> Enum.map(fn {va, vb} -> {card_strength(va), card_strength(vb)} end)
        |> Enum.find(fn {va, vb} ->
          va != vb
        end)

      va < vb
    else
      ta < tb
    end
  end

  @doc """
    iex> Day07.card_strength2("J")
    1
    iex> Day07.card_strength2("2")
    2
    iex> Day07.card_strength2("A")
    13
  """
  def card_strength2(c) do
    {_v, i} =
      String.split("AKQT98765432J", "")
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.find(fn {v, _} -> v == c end)

    i
  end

  @doc """
    iex> Day07.card_strength("2")
    1
    iex> Day07.card_strength("A")
    13
  """
  def card_strength(c) do
    {_v, i} =
      String.split("AKQJT98765432", "")
      |> Enum.reverse()
      |> Enum.with_index()
      |> Enum.find(fn {v, _} -> v == c end)

    i
  end

  @doc """
  """
  def hand_type2(hand) do
    m =
      String.split(hand, "")
      |> Enum.filter(fn s -> String.length(s) > 0 end)
      |> Enum.reduce(%{}, fn c, acc ->
        case acc[c] do
          nil -> Map.put(acc, c, 1)
          val -> Map.put(acc, c, val + 1)
        end
      end)

    # Apply the joker value to the top one
    jokerval =
      case m["J"] do
        nil -> 0
        val -> val
      end

    values =
      Map.keys(m)
      |> Enum.filter(fn k -> k != "J" end)
      |> Enum.map(fn k -> m[k] end)
      |> Enum.sort()
      |> Enum.reverse()
      |> List.update_at(0, fn v -> v + jokerval end)

    case values do
      # "five"
      [] -> 6
      # "five"
      [5] -> 6
      # "four"
      [4, 1] -> 5
      # "house"
      [3, 2] -> 4
      # "three"
      [3, 1, 1] -> 3
      # "two_pair"
      [2, 2, 1] -> 2
      # "pair"
      [2, 1, 1, 1] -> 1
      # "high"
      [1, 1, 1, 1, 1] -> 0
      _ -> false
    end
  end

  @doc """
    iex> Day07.hand_type("QQQQQ")
    6
    iex> Day07.hand_type("QQQQA")
    5
    iex> Day07.hand_type("QQQAA")
    4
    iex> Day07.hand_type("QQQJA")
    3
    iex> Day07.hand_type("QQJAA")
    2
    iex> Day07.hand_type("QQJAB")
    1
    iex> Day07.hand_type("12345")
    0
  """
  def hand_type(hand) do
    m =
      String.split(hand, "")
      |> Enum.filter(fn s -> String.length(s) > 0 end)
      |> Enum.reduce(%{}, fn c, acc ->
        case acc[c] do
          nil -> Map.put(acc, c, 1)
          val -> Map.put(acc, c, val + 1)
        end
      end)

    values =
      Map.values(m)
      |> Enum.sort()
      |> Enum.reverse()

    case values do
      # "five"
      [5] -> 6
      # "four"
      [4, 1] -> 5
      # "house"
      [3, 2] -> 4
      # "three"
      [3, 1, 1] -> 3
      # "two_pair"
      [2, 2, 1] -> 2
      # "pair"
      [2, 1, 1, 1] -> 1
      # "high"
      [1, 1, 1, 1, 1] -> 0
      _ -> false
    end
  end

  @doc """
    iex> Day07.parse("QQQJA 483")
    %Hand{ hand: "QQQJA", bid: 483 }
  """
  def parse(l) do
    [hand, bid_str] = String.split(l, " ")
    {bid, _} = Integer.parse(bid_str)
    %Hand{hand: hand, bid: bid}
  end
end
