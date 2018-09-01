defmodule PSQUARETest do
  use ExUnit.Case
  doctest PSQUARE

  test "checks map method for empty list" do
    assert PSQUARE.map([], fn x -> x*x end) == []
  end

  test "checks map method with square func" do
    list = [1,2,3,4]
    func = fn x -> x*x end
    assert PSQUARE.map(list, func) == [1, 4, 9, 16]
  end

  test "checks sum method for integers" do
    list = []
    assert PSQUARE.sum(list) == 0
  end

  test "checks sum method for zero elements" do
    list = []
    assert PSQUARE.sum(list) == 0
  end

  test "checks sum method for one element" do
    list = [5]
    assert PSQUARE.sum(list) == 5
  end

  test "checks sum method for more than one elements" do
    list = [1,2,3,4,5]
    assert PSQUARE.sum(list) == 15
  end

  test "checks sum method for negative elements" do
    list = [-1,2,-3,4,-5]
    assert PSQUARE.sum(list) == -3
  end

end
