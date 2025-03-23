defmodule Helpers.Types do
  @moduledoc """
  Utility module for type checking and comparison functions.
  Provides functions to determine the type of a term and compare types.
  """
  @doc """
  ## Examples:

    iex>Types.typeof("Hello World")
    "binary"

    iex>Types.typeof(1)
    "integer"

    iex>Types.typeof(self())
    "pid"

    iex>Types.typeof('this is char list')
    "list"

  """
  def typeof(term) when is_atom(term), do: "atom"
  def typeof(term) when is_boolean(term), do: "boolean"
  def typeof(term) when is_function(term), do: "function"
  def typeof(term) when is_list(term), do: "list"
  def typeof(term) when is_map(term), do: "map"
  def typeof(term) when is_nil(term), do: "nil"
  def typeof(term) when is_pid(term), do: "pid"
  def typeof(term) when is_port(term), do: "port"
  def typeof(term) when is_reference(term), do: "reference"
  def typeof(term) when is_tuple(term), do: "tuple"

  def typeof(term) when is_binary(term), do: "binary"
  def typeof(term) when is_bitstring(term), do: "bitstring"

  def typeof(term) when is_integer(term), do: "integer"
  def typeof(term) when is_float(term), do: "float"
  def typeof(term) when is_number(term), do: "number"

  def typeof(_), do: :error

  #################
  # other example #
  #################

  def type_of(term) do
    # Use pattern matching function clauses instead of a large cond block
    do_type_of(term)
  end

  # Atom-like types
  defp do_type_of(term) when is_atom(term), do: "atom"
  defp do_type_of(term) when is_boolean(term), do: "boolean"
  defp do_type_of(nil), do: "nil"

  # Collection types
  defp do_type_of(term) when is_list(term), do: "list"
  defp do_type_of(term) when is_map(term), do: "map"
  defp do_type_of(term) when is_tuple(term), do: "tuple"

  # Process/Reference types
  defp do_type_of(term) when is_pid(term), do: "pid"
  defp do_type_of(term) when is_port(term), do: "port"
  defp do_type_of(term) when is_reference(term), do: "reference"
  defp do_type_of(term) when is_function(term), do: "function"

  # String types
  defp do_type_of(term) when is_binary(term), do: "binary"
  defp do_type_of(term) when is_bitstring(term), do: "bitstring"

  # Number types
  defp do_type_of(term) when is_integer(term), do: "integer"
  defp do_type_of(term) when is_float(term), do: "float"
  defp do_type_of(term) when is_number(term), do: "number"

  # Default
  defp do_type_of(_), do: :error

  @equal_types %{
    "number" => ["integer", "float"],
    "string" => ["binary", "bitstring"]
  }

  @doc """
  ## Examples:

    iex> Specs.type_compare(1.3, "number" )
    true
    iex> Specs.type_compare(1.3, "integer")
    false
    iex> Specs.type_compare(1.3, "float")
    true

  """
  @spec type_compare(any, binary) :: boolean
  def type_compare(term, type) when is_binary(type) do
    term_type = typeof(term)
    term_type == type or term_type in (@equal_types[type] || [])
  end
end
