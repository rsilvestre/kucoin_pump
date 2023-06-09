defmodule Helpers.TableFormatter do
  use TypeCheck

  import Enum, only: [max: 1, zip: 2, join: 2]

  @header ~w(Symbol Time RSI RPCh NOE LP LTPCh LRPCh Slope Intercept Trend)
  @header_column_separator "-+-"

  # TODO: Refactor; try to find more uses for stdlib functions
  @spec! print_table(list(), list()) :: :ok
  def print_table(table, header \\ @header) do
    # the headers needs now to be a string
    header = header |> Enum.map(&String.Chars.to_string/1)
    columns_widths = [header | table] |> columns_widths

    hr = for _ <- 1..length(header), do: "-"

    hr |> print_row(columns_widths, @header_column_separator)
    header |> print_row(columns_widths)
    hr |> print_row(columns_widths, @header_column_separator)
    table |> Enum.map(&print_row(&1, columns_widths))
    hr |> print_row(columns_widths, @header_column_separator)
  end

  @spec! columns_widths(list()) :: list()
  def columns_widths(table) do
    table
    |> Matrix.transpose()
    |> Enum.map(fn cell ->
      cell
      |> Enum.map(&Kernel.inspect/1)
      |> Enum.map(&String.length/1)
      |> max
    end)
  end

  @spec! select_keys(map(), list()) :: map()
  def select_keys(dict, keys) do
    for entry <- dict do
      {dict1, _} = Map.split(entry, keys)
      dict1
    end
  end

  @spec! print_row(list(), list(), String.t()) :: :ok
  def print_row(row, column_widths, separator \\ " | ") do
    # Hack
    padding = separator |> String.to_charlist() |> List.first() |> (&List.to_string([&1])).()

    IO.puts(
      row
      |> zip(column_widths)
      |> Enum.map(fn {cell, column_width} ->
        cell
        |> Kernel.inspect()
        |> (&String.trim(&1, "\"")).()
        |> (&String.trim(&1, "'")).()
        |> String.pad_trailing(column_width, padding)
      end)
      |> join(separator)
    )
  end
end
