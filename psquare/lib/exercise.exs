defmodule Perfectsquare do
  def run(list) do
    calculate_sum_of_squares(list) |> is_perfect_square? |> return_first_element(list)
  end

  defp calculate_sum_of_squares(list) do
    Enum.map(list, &Task.async(fn -> &1 * &1 end))
    |> Enum.map(&Task.await/1)
    |> Enum.sum()
  end

  defp is_perfect_square?(n) when is_integer(n) do
    :math.sqrt(n)
    |> :erlang.trunc()
    |> :math.pow(2) == n
  end

  defp return_first_element(is_perfect_square, list) do
    if is_perfect_square do
      Enum.at(list, 0)
    else 
      ""
    end
  end
end

