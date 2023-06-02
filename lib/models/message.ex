defmodule Models.Message do
  use TypeCheck

  @enforce_keys [:subject, :time, :size, :price]
  defstruct subject: nil, time: nil, size: nil, price: nil

  @type! t() :: %__MODULE__{
           subject: String.t(),
           time: DateTime.t(),
           size: integer(),
           price: float()
         }

  @spec! new(map()) :: %__MODULE__{}
  def new(%{subject: subject, time: time, size: size, price: price}) do
    %__MODULE__{
      subject: subject,
      time: time,
      size: size,
      price: price
    }
  end

  @spec! from_json_to_message(map()) :: %__MODULE__{}
  def from_json_to_message(json) do
    %{}
    |> Map.put(:subject, Map.get(json, "subject"))
    |> Map.put(:time, DateTime.from_unix!(get_in(json, ["data", "time"]), :millisecond))
    |> Map.put(:price, get_in(json, ["data", "price"]) |> cast_string_to_float())
    |> Map.put(:size, get_in(json, ["data", "size"]) |> cast_string_to_int())
    |> __MODULE__.new()
  end

  @spec! cast_string_to_int(String.t()) :: integer()
  defp cast_string_to_int(string) do
    {value, _} = string |> Integer.parse()

    value
  end

  @spec! cast_string_to_float(String.t()) :: float()
  defp cast_string_to_float(string) do
    {value, _} = string |> Float.parse()

    value
  end

  defimpl Inspect do
    def inspect(
          %Models.Message{
            subject: subject,
            time: time,
            size: size,
            price: price
          },
          _
        ) do
      "Subject:#{subject}\t Time:#{time}\t Size:#{size}\t Price:#{price}\t"
    end
  end
end
