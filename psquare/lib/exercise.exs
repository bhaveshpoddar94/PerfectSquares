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

# defmodule Master do
#   use Supervisor

#   def start_link(range, k) do
#     Supervisor.start_link(__MODULE__, [range, k])
#   end

#   def init([range, k]) do
#     lists = Enum.chunk_every(1..range, k, 1, :discard)
#     create_worker = fn(list) -> worker(PerfectSquare, [list], id: Enum.at(list, 0)) end
#     children = Enum.map(lists, create_worker)
#     supervise(children, strategy: :one_for_one)
#   end 
# end