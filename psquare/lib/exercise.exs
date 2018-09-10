defmodule PSquare.CLI do
  def main(args) do
    case args |> parse_args do
      {:empty, err} -> IO.puts err
      {:lt2, err}   -> IO.puts err
      {:gt2, err}   -> IO.puts err
      {:valid, [range, k]} -> spawn_tasks(range, k)
    end
  end

  defp parse_args(args) do
    case length(args) do
      l when l == 0 -> {:empty, "Enter values for N and K in that order."}
      l when l < 2  -> {:lt2, "Enter both N and K values in that order."}
      l when l > 2  -> {:gt2, "Only two integer values of N and K are accepted in that order."}
      _ -> {:valid, Enum.map(args, &String.to_integer/1)}
    end
  end

  defp spawn_tasks(range, k) do
    work_unit =
      cond do
        range < 10 -> range
        range >= 10000000 -> 100
        true -> 10
      end
    Enum.filter(1..range, fn(x) -> (rem x, work_unit) == 1 end)
    |> Enum.map(&create_task(&1, k, work_unit, range))
    |> collect_results([])
    |> print_loop
  end

  defp create_task(start, k, work_unit, range) do
    [s, e] = input_loop(start, k, work_unit, [], [], range)
    Task.async(fn -> PerfectSquare.run(s, e)end)
  end

  defp input_loop(_start, _k, 0, s, e, _range), do: [s, e]
  defp input_loop(start, k, work_unit, s, e, range) do
    if start > range do
      [s, e]
    else
      s = [start|s]
      e = [start+k-1|e]
      input_loop(start+1, k, work_unit-1, s, e, range)
    end
  end

  defp collect_results([], res), do: res
  defp collect_results(tasks, res) do
    receive do
      msg ->
          case Task.find(tasks, msg) do
            {result, task} ->
              res = res ++ Enum.filter(result, fn x -> x > 0 end)
              collect_results(List.delete(tasks, task), res)
            nil ->
              collect_results(tasks, res)
          end
    end
  end

  defp print_loop([]), do: IO.puts ""
  defp print_loop([head | tail]) do
    IO.puts head
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

PSquare.CLI.main(System.argv())