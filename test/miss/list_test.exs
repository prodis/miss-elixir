defmodule Miss.ListTest do
  use ExUnit.Case, async: true

  alias Miss.List, as: Subject

  doctest Subject

  describe "intersection/2" do
    test "returns the common elements" do
      list1 = Enum.to_list(1..10)
      list2 = Enum.to_list(5..15)

      assert Subject.intersection(list1, list2) == [5, 6, 7, 8, 9, 10]
      assert Subject.intersection(list2, list1) == [5, 6, 7, 8, 9, 10]
      assert Subject.intersection(list1, [0, 2, 4, 6, 8, 10, 12]) == [2, 4, 6, 8, 10]
      assert Subject.intersection(list1, [0, 12, 4, 8, 2, 10, 6]) == [2, 4, 6, 8, 10]
      assert Subject.intersection([0, 12, 4, 8, 2, 10, 6], list1) == [4, 8, 2, 10, 6]
      assert Subject.intersection(list1, list1) == list1
    end

    test "when there are no common elements, returns an empty list" do
      assert Subject.intersection([1, 2, 3], [4, 5, 6]) == []
      assert Subject.intersection([1, 2, 3], []) == []
      assert Subject.intersection([], [1, 2, 3]) == []
      assert Subject.intersection([], []) == []
    end
  end
end
