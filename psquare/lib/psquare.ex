defmodule PSquare.CLI do
  def main(args) do
    case args |> parse_args do
      {:empty, err} -> IO.puts err
      {:lt2, err} -> IO.puts err
      {:gt2, err} -> IO.puts err
      {:valid, [range, k]} -> spawn_tasks(range, k)
    end
  end

  defp parse_args(args) do
    {_, args, _} =  OptionParser.parse(args, switches: [name: :string])
    l = length(args)
    case l do
      l when l == 0 -> {:empty, "Enter values for N and K in that order."}
      l when l < 2  -> {:lt2, "Enter both N and K values in that order."}
      l when l > 2  -> {:gt2, "Only two integer values of N and K are accepted in that order."}
      _ -> {:valid, Enum.map(args, &String.to_integer/1)}
    end
  end

  defp spawn_tasks(range, k) do
    Enum.map(1..range, &Task.async(fn -> PerfectSquare.run(&1, &1+k-1) end))
    |> collect_results
  end
  
  defp collect_results([]), do: IO.puts ""
  defp collect_results(tasks) do
    receive do
      msg ->
        case Task.find(tasks, msg) do
          {result, task} ->
            collect_results(List.delete(tasks, task))
            if result > 0 do
              IO.puts result
            end
          nil ->
            collect_results(tasks)
        end
    end
  end
end

defmodule PerfectSquare do
  def run(s, e) do
    if calculate_sum_of_squares(s, e) |> is_perfect_square? do
      s
    else
      -1
    end
  end

  def calculate_sum_of_squares(s, e) do
    sum_util(e) - sum_util(s-1)
  end

  defp is_perfect_square?(n) when is_integer(n) do
    :math.sqrt(n)
    |> :erlang.trunc()
    |> :math.pow(2) == n
  end

  def sum_util(n) do
    numerator = n * (n+1) * (2*n + 1)
    div(numerator, 6)
  end
end