defmodule Miss.List do
  @moduledoc """
  Functions to extend the Elixir `List` module.
  """

  @doc """
  Returns a list containing only the elements that `list1` and `list2` have in common.

  ## Examples

      iex> Miss.List.intersection([1, 2, 3, 4, 5], [3, 4, 5, 6, 7])
      [3, 4, 5]

      iex> Miss.List.intersection([4, 2, 5, 3, 1], [12, 1, 9, 5, 0])
      [5, 1]

      iex> Miss.List.intersection([1, 2, 3, 4, 5], [6, 7, 8, 9, 0])
      []

  """
  @spec intersection(list(), list()) :: list()
  def intersection(list1, list2) do
    temp = list1 -- list2
    list1 -- temp
  end
end
