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
    work_unit = 8
    Enum.filter(1..range, fn(x) -> (rem x, work_unit) == 1 end)
    |> Enum.map(&create_task(&1, k, work_unit))
    |> collect_results
  end

  defp create_task(start, k, work_unit) do
    [s, e] = input_loop(start, k, work_unit, [], [])
    Task.async(fn -> PerfectSquare.run(s, e)end)
  end

  defp input_loop(_start, _k, 0, s, e), do: [s, e]
  defp input_loop(start, k, work_unit, s, e) do
    s = [start|s]
    e = [start+k-1|e]
    input_loop(start+1, k, work_unit-1, s, e)
  end

  defp collect_results([]), do: IO.puts ""
  defp collect_results(tasks) do
    receive do
      msg ->
        case Task.find(tasks, msg) do
          {result, task} ->
            collect_results(List.delete(tasks, task))
            print_loop result
          nil ->
            collect_results(tasks)
        end
    end
  end

  defp print_loop([]), do: nil
  defp print_loop([head | tail]) do
    if head > 0 do
      IO.puts head
    end
    print_loop(tail)
  end
end

defmodule PerfectSquare do
  def run(s, e) do
    loop(s, e, [])
  end

  defp loop([], [], result), do: result
  defp loop([shead | stail], [ehead | etail], result) do
    result = 
      if calculate_sum_of_squares(shead, ehead) |> is_perfect_square? do
        [shead|result]
      else
        [-1|result]
      end
    loop(stail, etail, result)
  end

  defp calculate_sum_of_squares(s, e) do
    sum_util(e) - sum_util(s-1)
  end

  defp is_perfect_square?(n) when is_integer(n) do
    :math.sqrt(n)
    |> :erlang.trunc()
    |> :math.pow(2) == n
  end

  defp sum_util(n) do
    numerator = n * (n+1) * (2*n + 1)
    div(numerator, 6)
  end
end