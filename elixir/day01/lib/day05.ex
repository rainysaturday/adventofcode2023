defmodule SrcDest do
  defstruct src: Integer, dst: Integer, len: Integer
end

defmodule MNode do
  defstruct input: Chars, output: Chars, src_to_dest: [%SrcDest{}]
end

defmodule Day05 do
  @doc """
    iex> Day05.part1
    261668924
  """
  def part1 do
    lines = Helpers.read_input_by_lines("../../inputs/day05.txt")
    seeds = parse_seeds(lines)
    chunks = parse_chunks(lines)
    model = chunks_to_model(chunks)

    Enum.reduce(seeds, 10_000_000_000, fn seed, loc ->
      min(loc, find_dst_for_src(model, "seed", "location", seed))
    end)
  end

  # @doc """
  #   iex> Day05.part2
  #   24261545
  # """
  def part2 do
    lines = Helpers.read_input_by_lines("../../inputs/day05.txt")
    seeds = parse_seed_pairs(lines)
    chunks = parse_chunks(lines)
    model = chunks_to_rev_model(chunks)

    # Search backwards with brute force... :)
    loc =
      Enum.find(0..5_000_000_000, fn loc ->
        val = rev_seed_for_loc(model, "location", "seed", loc)

        Enum.any?(seeds, fn [start, len] ->
          if is_in_range(val, start, len) do
            IO.puts(
              "Found loc that matched range " <>
                Integer.to_string(start) <>
                "-" <> Integer.to_string(start + len) <> " with val " <> Integer.to_string(val)
            )

            true
          else
            false
          end
        end)
      end)

    IO.puts("Got best loc " <> Integer.to_string(loc))
    loc
  end

  def rev_seed_for_loc(model, coming_from_dst, going_to_src_name, pos) do
    mapping = model[coming_from_dst]
    src = rev_find_chunk(mapping, pos)

    if mapping.input == going_to_src_name do
      src
    else
      rev_seed_for_loc(model, mapping.input, going_to_src_name, src)
    end
  end

  def rev_find_chunk(chunk, val) do
    sel =
      chunk.src_to_dest
      |> Enum.find(fn m ->
        if m.dst <= val && val < m.dst + m.len do
          true
        else
          false
        end
      end)

    case sel do
      nil ->
        val

      sel ->
        sel.src + (val - sel.dst)
    end
  end

  def is_in_range(v, range_start, range_len) do
    v >= range_start && v < range_start + range_len
  end

  def find_dst_for_src(model, src_name, dst_name, val) do
    chunk = model[src_name]
    dst = find_dst_in_chunk(chunk, val)

    if chunk.output == dst_name do
      dst
    else
      find_dst_for_src(model, chunk.output, dst_name, dst)
    end
  end

  def find_dst_in_chunk(chunk, val) do
    sel =
      chunk.src_to_dest
      |> Enum.find(fn m ->
        if m.src <= val && val < m.src + m.len do
          true
        else
          false
        end
      end)

    case sel do
      nil ->
        val

      sel ->
        # Apply the offset to the dst
        sel.dst + (val - sel.src)
    end
  end

  def chunks_to_model(chunks) do
    Enum.reduce(chunks, %{}, fn c, acc ->
      Map.put(acc, c.input, c)
    end)
  end

  def chunks_to_rev_model(chunks) do
    Enum.reduce(chunks, %{}, fn c, acc ->
      Map.put(acc, c.output, c)
    end)
  end

  @doc """
    iex> Day05.parse_seed_pairs(["", "seeds: 1 2 3 4", ""])
    [[1, 2], [3, 4]]
  """
  def parse_seed_pairs(lines) do
    Enum.find(lines, fn s -> String.starts_with?(s, "seeds: ") end)
    |> String.split(" ")
    |> Enum.filter(fn s -> String.length(s) > 0 end)
    |> Enum.drop(1)
    |> Enum.map(fn s ->
      {val, _rest} = Integer.parse(s)
      val
    end)
    |> Enum.chunk_every(2)
  end

  @doc """
    iex> Day05.parse_seeds(["", "seeds: 1 2 3 4", ""])
    [1, 2, 3, 4]
  """
  def parse_seeds(lines) do
    Enum.find(lines, fn s -> String.starts_with?(s, "seeds: ") end)
    |> String.split(" ")
    |> Enum.filter(fn s -> String.length(s) > 0 end)
    |> Enum.drop(1)
    |> Enum.map(fn s ->
      {val, _rest} = Integer.parse(s)
      val
    end)
  end

  @doc """
    iex> Day05.parse_chunks(["seed-to-soil map:", "20 10 2", ""])
    [%MNode { input: "seed", output: "soil", src_to_dest: [%SrcDest{ src: 10, dst: 20, len: 2 }]}]
  """
  def parse_chunks(lines) do
    chunks =
      lines
      |> Enum.with_index()
      |> Enum.filter(fn {s, _i} -> String.contains?(s, " map:") end)
      |> Enum.map(fn {_s, i} -> i end)

    for chunk <- chunks do
      parse_chunk(lines, chunk)
    end
  end

  def parse_chunk(lines, offset) do
    [header | rest] = lines |> Enum.drop(offset)
    [mapping, _rest] = String.split(header, " ", global: false)
    [input, _to, output] = String.split(mapping, "-")

    src_to_dest =
      rest
      |> Enum.take_while(fn s -> String.length(s) > 0 end)
      |> Enum.take_while(fn s -> !String.contains?(s, "map:") end)
      |> Enum.map(fn s ->
        [dst, src, l] =
          String.split(s, " ")
          |> Enum.map(fn s ->
            {val, _rest} = Integer.parse(s)
            val
          end)

        %SrcDest{src: src, dst: dst, len: l}
      end)

    %MNode{
      input: input,
      output: output,
      src_to_dest: src_to_dest
    }
  end
end
