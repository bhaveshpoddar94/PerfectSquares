defmodule PerfectSquare do
  use Task

  def start_link(list) do
    Task.start_link(__MODULE__, :run, [list])
  end

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
      IO.puts Enum.at(list, 0)
    end
  end
end

defmodule Master do
  use Supervisor

  def start_link(range, k) do
    Supervisor.start_link(__MODULE__, [range, k])
  end

  def init([range, k]) do
    lists = Enum.chunk_every(1..range, k, 1, :discard)
    create_worker = fn(list) -> worker(PerfectSquare, [list], id: Enum.at(list, 0)) end
    children = Enum.map(lists, create_worker)
    supervise(children, strategy: :one_for_one)
  end
end
