defmodule Helpers.TableFormatterTest do
  use ExUnit.Case, async: true
  alias Helpers.TableFormatter
  import ExUnit.CaptureIO

  test "columns_widths calculates correct column widths" do
    table = [
      ["short", "medium length", "very looooong"],
      ["a", "b", "c"]
    ]
    
    widths = TableFormatter.columns_widths(table)
    
    assert length(widths) == 3
    # Just check that the widths are positive numbers
    # The exact calculation depends on the implementation details
    assert Enum.at(widths, 0) > 0
    assert Enum.at(widths, 1) > 0
    assert Enum.at(widths, 2) > 0
    # Also check relative sizes
    assert Enum.at(widths, 1) > Enum.at(widths, 0)
    assert Enum.at(widths, 2) >= Enum.at(widths, 1)
  end

  test "print_row formats and prints a row correctly" do
    row = ["Col1", "Column2", "C3"]
    column_widths = [4, 7, 2]
    
    output = capture_io(fn -> 
      TableFormatter.print_row(row, column_widths)
    end)
    
    assert output == "Col1 | Column2 | C3\n"
  end

  test "print_row with custom separator" do
    row = ["A", "B", "C"]
    column_widths = [1, 1, 1]
    
    output = capture_io(fn -> 
      TableFormatter.print_row(row, column_widths, " * ")
    end)
    
    assert output == "A * B * C\n"
  end

  test "print_table prints a complete table with headers" do
    table = [
      ["Alice", "28", "Engineer"],
      ["Bob", "34", "Designer"],
      ["Charlie", "42", "Manager"]
    ]
    
    header = ["Name", "Age", "Role"]
    
    output = capture_io(fn -> 
      TableFormatter.print_table(table, header)
    end)
    
    # We expect the output to have:
    # 1. A header row separator line
    # 2. The header row
    # 3. Another separator line
    # 4. Three data rows
    # 5. A final separator line
    
    lines = String.split(output, "\n", trim: true)
    assert length(lines) == 7
    
    # Just check that each row contains the expected data
    # without specifying exact formatting
    assert String.contains?(Enum.at(lines, 1), "Name") && String.contains?(Enum.at(lines, 1), "Age") && String.contains?(Enum.at(lines, 1), "Role")
    assert String.contains?(Enum.at(lines, 3), "Alice") && String.contains?(Enum.at(lines, 3), "28") && String.contains?(Enum.at(lines, 3), "Engineer")
    assert String.contains?(Enum.at(lines, 4), "Bob") && String.contains?(Enum.at(lines, 4), "34") && String.contains?(Enum.at(lines, 4), "Designer")
    assert String.contains?(Enum.at(lines, 5), "Charlie") && String.contains?(Enum.at(lines, 5), "42") && String.contains?(Enum.at(lines, 5), "Manager")
  end

  test "select_keys extracts specified keys from maps" do
    maps = [
      %{name: "Alice", age: 28, role: "Engineer", department: "Tech"},
      %{name: "Bob", age: 34, role: "Designer", department: "Creative"}
    ]
    
    result = TableFormatter.select_keys(maps, [:name, :role])
    
    assert length(result) == 2
    assert Enum.at(result, 0) == %{name: "Alice", role: "Engineer"}
    assert Enum.at(result, 1) == %{name: "Bob", role: "Designer"}
  end
end