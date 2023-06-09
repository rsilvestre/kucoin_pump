defmodule Helpers.TableFormatter do
  import Enum, only: [map: 2, max: 1, zip: 2, join: 2]

  @header ~w(Symbol Time RSI RPCh NOE LP LTPCh LRPCh Slope Intercept Trend)
  @header_column_separator "-+-"

  # TODO: Refactor; try to find more uses for stdlib functions
  def print_table(rows, header \\ @header) do
    # table = rows |> to_table(header)
    table = rows
    # the headers needs now to be a string
    header = header |> map(&String.Chars.to_string/1)
    columns_widths = [header | table] |> columns_widths

    hr = for _ <- 1..length(header), do: "-"

    hr |> print_row(columns_widths, @header_column_separator)
    header |> print_row(columns_widths)
    hr |> print_row(columns_widths, @header_column_separator)
    table |> map(&print_row(&1, columns_widths))
    hr |> print_row(columns_widths, @header_column_separator)
  end

  def to_table(list_of_dicts, header) do
    list_of_dicts
    |> select_keys(header)
    |> map(fn dict ->
      dict
      |> Map.values()
      |> map(&String.Chars.to_string/1)
    end)
  end

  def columns_widths(table) do
    table
    |> Matrix.transpose()
    |> map(fn cell ->
      cell
      |> map(&Kernel.inspect/1)
      |> map(&String.length/1)
      |> max
    end)
  end

  def select_keys(dict, keys) do
    for entry <- dict do
      {dict1, _} = Map.split(entry, keys)
      dict1
    end
  end

  def print_row(row, column_widths, separator \\ " | ") do
    # Hack
    padding = separator |> String.to_charlist() |> List.first()

    IO.puts(
      row
      |> zip(column_widths)
      |> map(fn {cell, column_width} ->
        cell |> Kernel.inspect() |> String.ljust(column_width, padding)
      end)
      |> join(separator)
    )
  end
end
