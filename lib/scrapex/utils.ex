defmodule Scrapex.Utils do
  @spec reduce_with(Enum.t, any, (Enum.element, any -> {:cont, {:ok, any}} | {:halt, any})) :: any
  def reduce_with(enumerable, acc, fun) do
    Enum.reduce_while enumerable, {:ok, acc}, fn (val, {:ok, acc}) ->
      case fun.(val, acc) do
        error = {:error, _} -> {:halt, error}
        value = {:ok, _}    -> {:cont, value}
        value               -> {:cont, {:ok, value}}
      end
    end
  end
end
