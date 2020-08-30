defmodule Miss.String do
  @moduledoc """
  Functions to extend the Elixir `String` module.
  """

  @doc ~S"""
  Builds a string with the given values using IO lists.

  In Erlang and Elixir concatenating binaries will copy the concatenated binaries into a new
  binary. Every time you concatenate binaries (`<>`) or use interpolation (`#{}`) you are making
  copies of those binaries.

  To build a string, it is cheaper and more efficient to use IO lists to build the binary just
  once instead of concatenating along the way.

  See the [Elixir IO Data documentation](https://hexdocs.pm/elixir/IO.html#module-io-data) for
  more information.

  All elements in the list must be a binary or convertible to a binary, otherwise an error is
  raised.

  ## Examples

      iex> Miss.String.build(["akira", "hamasaki", "123", "pim", "2010-09-01", "99.99"])
      "akirahamasaki123pim2010-09-0199.99"

      iex> Miss.String.build([:akira, 'hamasaki', 123, [112, 105, 109], ~D[2010-09-01], 99.99])
      "akirahamasaki123pim2010-09-0199.99"

      iex> Miss.String.build(["akira", %{}])
      ** (Protocol.UndefinedError) protocol String.Chars not implemented for %{} of type Map. This protocol is implemented for the following type(s): Decimal, Float, DateTime, Time, List, Version.Requirement, Atom, Integer, Version, Date, BitString, NaiveDateTime, URI

  """
  @spec build(list()) :: String.t()
  def build(values) when is_list(values) do
    values
    |> Enum.map(&value_to_string/1)
    |> IO.iodata_to_binary()
  end

  @spec value_to_string(term()) :: String.t()
  defp value_to_string(value) when is_binary(value), do: value
  defp value_to_string(value), do: String.Chars.to_string(value)

  @doc """
  Builds a string with the given two values using IO lists similar to `Miss.String.build/1`.

  When both values are binary, `#{inspect(__MODULE__)}.build/2` is more efficient than
  `Miss.String.build/1` because it avoids to check if each value is a binary.

  ## Examples

      iex> Miss.String.build("akira", "hamasaki")
      "akirahamasaki"

      iex> Miss.String.build(:akira, 'hamasaki')
      "akirahamasaki"

      iex> Miss.String.build("akira", %{})
      ** (Protocol.UndefinedError) protocol String.Chars not implemented for %{} of type Map. This protocol is implemented for the following type(s): Decimal, Float, DateTime, Time, List, Version.Requirement, Atom, Integer, Version, Date, BitString, NaiveDateTime, URI

  """
  @spec build(term(), term()) :: String.t()
  def build(value1, value2)
      when is_binary(value1) and
             is_binary(value2),
      do: IO.iodata_to_binary([value1, value2])

  def build(value1, value2), do: build([value1, value2])

  @doc """
  Builds a string with the given three values using IO lists similar to `Miss.String.build/1`.

  When all the values are binary, `#{inspect(__MODULE__)}.build/3` is more efficient than
  `Miss.String.build/1` because it avoids to check if each value is a binary.

  ## Examples

      iex> Miss.String.build("akira", "hamasaki", "123")
      "akirahamasaki123"

      iex> Miss.String.build(:akira, 'hamasaki', 123)
      "akirahamasaki123"

      iex> Miss.String.build("akira", "hamasaki", %{})
      ** (Protocol.UndefinedError) protocol String.Chars not implemented for %{} of type Map. This protocol is implemented for the following type(s): Decimal, Float, DateTime, Time, List, Version.Requirement, Atom, Integer, Version, Date, BitString, NaiveDateTime, URI

  """
  @spec build(term(), term(), term()) :: String.t()
  def build(value1, value2, value3)
      when is_binary(value1) and
             is_binary(value2) and
             is_binary(value3),
      do: IO.iodata_to_binary([value1, value2, value3])

  def build(value1, value2, value3), do: build([value1, value2, value3])

  @doc """
  Builds a string with the given four values using IO lists similar to `Miss.String.build/1`.

  When all the values are binary, `#{inspect(__MODULE__)}.build/4` is more efficient than
  `Miss.String.build/1` because it avoids to check if each value is a binary.

  ## Examples

      iex> Miss.String.build("akira", "hamasaki", "123", "pim")
      "akirahamasaki123pim"

      iex> Miss.String.build(:akira, 'hamasaki', 123, [112, 105, 109])
      "akirahamasaki123pim"

      iex> Miss.String.build("akira", "hamasaki", "123", %{})
      ** (Protocol.UndefinedError) protocol String.Chars not implemented for %{} of type Map. This protocol is implemented for the following type(s): Decimal, Float, DateTime, Time, List, Version.Requirement, Atom, Integer, Version, Date, BitString, NaiveDateTime, URI

  """
  @spec build(term(), term(), term(), term()) :: String.t()
  def build(value1, value2, value3, value4)
      when is_binary(value1) and
             is_binary(value2) and
             is_binary(value3) and
             is_binary(value4),
      do: IO.iodata_to_binary([value1, value2, value3, value4])

  def build(value1, value2, value3, value4), do: build([value1, value2, value3, value4])

  @doc """
  Builds a string with the given five values using IO lists similar to `Miss.String.build/1`.

  When all the values are binary, `#{inspect(__MODULE__)}.build/5` is more efficient than
  `Miss.String.build/1` because it avoids to check if each value is a binary.

  ## Examples

      iex> Miss.String.build("akira", "hamasaki", "123", "pim", "2010-09-01")
      "akirahamasaki123pim2010-09-01"

      iex> Miss.String.build(:akira, 'hamasaki', 123, [112, 105, 109], ~D[2010-09-01])
      "akirahamasaki123pim2010-09-01"

      iex> Miss.String.build("akira", "hamasaki", "123", "pim", %{})
      ** (Protocol.UndefinedError) protocol String.Chars not implemented for %{} of type Map. This protocol is implemented for the following type(s): Decimal, Float, DateTime, Time, List, Version.Requirement, Atom, Integer, Version, Date, BitString, NaiveDateTime, URI

  """
  @spec build(term(), term(), term(), term(), term()) :: String.t()
  def build(value1, value2, value3, value4, value5)
      when is_binary(value1) and
             is_binary(value2) and
             is_binary(value3) and
             is_binary(value4) and
             is_binary(value5),
      do: IO.iodata_to_binary([value1, value2, value3, value4, value5])

  def build(value1, value2, value3, value4, value5),
    do: build([value1, value2, value3, value4, value5])
end
