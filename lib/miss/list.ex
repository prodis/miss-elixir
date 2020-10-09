defmodule Miss.List do
  @moduledoc """
  Functions to extend the Elixir `List` module.
  """

  @doc """
  Returns a list containing only the elements that `list1` and `list2` have in common.

  `Miss.List.intersection/2` uses the [list subtraction operator](https://hexdocs.pm/elixir/Kernel.html#--/2)
  that before Erlang/OTP 22 it would be very slow if both lists to intersect are long. In such
  cases, consider converting each list to a `MapSet`, using `MapSet.intersection/2`, and
  converting back to a list.

  As of Erlang/OTP 22, this list subtraction operation is significantly faster even if both lists
  are very long, that means `Miss.List.intersection/2` is usually faster and uses less memory than
  using the MapSet-based alternative mentioned above.

  That is also mentioned in the [Erlang Efficiency Guide](https://erlang.org/doc/efficiency_guide/retired_myths.html#myth--list-subtraction-------operator--is-slow):

  > List subtraction used to have a run-time complexity proportional to the product of the length
  > of its operands, so it was extremely slow when both lists were long.
  >
  > As of OTP 22 the run-time complexity is "n log n" and the operation will complete quickly even
  > when both lists are very long. In fact, it is faster and uses less memory than the commonly
  > used workaround to convert both lists to ordered sets before subtracting them with
  >`ordsets:subtract/2`.

  ## Examples

      iex> Miss.List.intersection([1, 2, 3, 4, 5], [3, 4, 5, 6, 7])
      [3, 4, 5]

      iex> Miss.List.intersection([4, 2, 5, 3, 1], [12, 1, 9, 5, 0])
      [5, 1]

      iex> Miss.List.intersection([1, 2, 3, 4, 5], [6, 7, 8, 9, 0])
      []

  """
  @spec intersection(list(), list()) :: list()
  def intersection(list1, list2), do: list1 -- list1 -- list2
end
