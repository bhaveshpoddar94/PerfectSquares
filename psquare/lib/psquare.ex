defmodule PSQUARE do
  @moduledoc """
  Documentation for PSQUARE.
  contains code for Project 1
  """

  @doc """
  map function
  takes a list of elements and a function as input
  applies the function to each element of the list
  returns the list
  """
  def map([], _func), do: []
  def map([head | tail], func) do
    [func.(head) | map(tail, func)]
  end

end

IO.inspect PSQUARE.sum PSQUARE.map [1,3,2,6,4], fn x -> x*x end