defmodule Helpers.StdLibTest do
  use ExUnit.Case, async: true

  test "Matrix.transpose works as expected" do
    # Original matrix
    matrix = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9]
    ]
    
    # Expected result after transposition
    expected = [
      [1, 4, 7],
      [2, 5, 8],
      [3, 6, 9]
    ]
    
    result = Matrix.transpose(matrix)
    
    assert result == expected
  end
  
  test "String operations work as expected" do
    # Test padding
    assert String.pad_trailing("abc", 5) == "abc  "
    assert String.pad_leading("abc", 5) == "  abc"
    
    # Test trimming
    assert String.trim("  abc  ") == "abc"
    assert String.trim_leading("  abc  ") == "abc  "
    assert String.trim_trailing("  abc  ") == "  abc"
    
    # Test replacement
    assert String.replace("hello world", "world", "elixir") == "hello elixir"
    
    # Test splitting
    assert String.split("a,b,c", ",") == ["a", "b", "c"]
    
    # Test joining
    assert Enum.join(["a", "b", "c"], ",") == "a,b,c"
  end
  
  test "Enum functions work as expected" do
    list = [1, 2, 3, 4, 5]
    
    # Test map
    assert Enum.map(list, &(&1 * 2)) == [2, 4, 6, 8, 10]
    
    # Test filter
    assert Enum.filter(list, &(rem(&1, 2) == 0)) == [2, 4]
    
    # Test reduce
    assert Enum.reduce(list, 0, &(&1 + &2)) == 15
    
    # Test sort
    assert Enum.sort([3, 1, 2]) == [1, 2, 3]
    
    # Test at
    assert Enum.at(list, 2) == 3
    
    # Test count
    assert Enum.count(list) == 5
    
    # Test sum
    assert Enum.sum(list) == 15
    
    # Test zip
    assert Enum.zip([:a, :b, :c], [1, 2, 3]) == [a: 1, b: 2, c: 3]
  end
  
  test "Map operations work as expected" do
    map = %{a: 1, b: 2, c: 3}
    
    # Test get
    assert Map.get(map, :a) == 1
    assert Map.get(map, :d, :default) == :default
    
    # Test put
    assert Map.put(map, :d, 4) == %{a: 1, b: 2, c: 3, d: 4}
    
    # Test delete
    assert Map.delete(map, :a) == %{b: 2, c: 3}
    
    # Test update
    assert Map.update(map, :a, 0, &(&1 + 10)) == %{a: 11, b: 2, c: 3}
    
    # Test keys
    assert Map.keys(map) |> Enum.sort() == [:a, :b, :c]
    
    # Test values
    assert Map.values(map) |> Enum.sort() == [1, 2, 3]
  end
  
  test "Integer/Float operations work as expected" do
    # Test parsing
    assert Integer.parse("123") == {123, ""}
    assert Float.parse("3.14") == {3.14, ""}
    
    # Test conversion
    assert Float.round(3.14159, 2) == 3.14
    
    # Test math operations
    assert abs(-5) == 5
    assert max(3, 7) == 7
    assert min(3, 7) == 3
  end
  
  test "DateTime operations work as expected" do
    # Test now
    now = DateTime.utc_now()
    assert %DateTime{} = now
    
    # Test comparison
    earlier = ~U[2020-01-01 00:00:00Z]
    later = ~U[2021-01-01 00:00:00Z]
    assert DateTime.compare(earlier, later) == :lt
    
    # Test add
    one_hour_later = DateTime.add(earlier, 3600, :second)
    assert one_hour_later.hour == 1
  end
end