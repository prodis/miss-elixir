defmodule Miss.Kernel do
  @moduledoc """
  Functions to extend the Elixir `Kernel` module.
  """

  @doc """
  Returns `true` if `term` is a charlist. Otherwise returns `false`.

  A charlist is a list made of non-negative integers, where each integer represents a Unicode code
  point. These integers must be:
  - within the range `0..0x10FFFF` (`0..1_114_111`);
  - out of the range `0xD800..0xDFFF` (`55_296..57_343`), which is reserved in Unicode for UTF-16
  surrogate pairs.

  Elixir uses single quotes to define charlists:

      'córação dê mélão'
      [99, 243, 114, 97, 231, 227, 111, 32, 100, 234, 32, 109, 233, 108, 227, 111]

  Check the [Elixir Charlists documentation](https://hexdocs.pm/elixir/List.html#module-charlists)
  for more details.

  Note that `Miss.Kernel.charlist?/1` CANNOT be used as a guard.

  ## Examples

      iex> Miss.Kernel.charlist?('prodis')
      true

      iex> Miss.Kernel.charlist?([112, 114, 111, 100, 105, 115])
      true

      iex> Miss.Kernel.charlist?([112, 114, 111, 100, 105, 115, 55_296])
      false

      iex> Miss.Kernel.charlist?("prodis")
      false

      iex> Miss.Kernel.charlist?(:prodis)
      false

      iex> Miss.Kernel.charlist?(true)
      false

      iex> Miss.Kernel.charlist?(123)
      false

      iex> Miss.Kernel.charlist?(123.45)
      false

  """
  @spec charlist?(term()) :: boolean()
  def charlist?(term) when is_list(term) do
    Enum.all?(term, fn item ->
      item in 0..55_295 or item in 57_344..1_114_111
    end)
  end

  def charlist?(_term), do: false

  @doc """
  Performs an integer division and computes the remainder.

  `Miss.Kernel.div_rem/2` uses truncated division, which means:
  - the result of the division is always rounded towards zero;
  - the remainder will always have the sign of the `dividend`.

  Raises an `ArithmeticError` if one of the arguments is not an integer, or when the `divisor` is
  `0`.

  ## Examples

      iex> Miss.Kernel.div_rem(5, 2)
      {2, 1}

      iex> Miss.Kernel.div_rem(6, -4)
      {-1, 2}

      iex> Miss.Kernel.div_rem(-99, 2)
      {-49, -1}

      iex> Miss.Kernel.div_rem(10, 5)
      {2, 0}

      iex> Miss.Kernel.div_rem(0, 2)
      {0, 0}

      iex> Miss.Kernel.div_rem(5, 0)
      ** (ArithmeticError) bad argument in arithmetic expression

      iex> Miss.Kernel.div_rem(10.0, 2)
      ** (ArithmeticError) bad argument in arithmetic expression

      iex> Miss.Kernel.div_rem(10, 2.0)
      ** (ArithmeticError) bad argument in arithmetic expression

  """
  @spec div_rem(integer(), neg_integer() | pos_integer()) :: {integer(), integer()}
  def div_rem(dividend, divisor), do: {div(dividend, divisor), rem(dividend, divisor)}

  @doc """
  Creates and updates a struct in the same way of `Kernel.struct/2`, but receiving the parameters
  in the inverse order, first the `fields` and second the `struct`.  Useful when building the
  fields using the pipe operator `|>`.

  In the following example, a hypothetical function `build/2` builds a `Map` to create a
  `MyStruct` struct.

  Using `Kernel.struct/2` it is necessary to assign the map to a variable before creating the
  struct:

      def build(param1, param2) do
        fields =
          %{
            key1: param1.one,
            key2: param1.two,
            key3: :a_default_value
          }
          |> Map.merge(build_more_fields(param2))

        struct(MyStruct, fields)
      end

  Using `Miss.Kernel.struct_inverse/2` the map can be piped when creating the struct:

      def build(param1, param2) do
        %{
          key1: param1.one,
          key2: param1.two,
          key3: :a_default_value
        }
        |> Map.merge(build_more_fields(param2))
        |> Miss.Kernel.struct_inverse(MyStruct)
      end

  ## Examples

      defmodule User do
        defstruct name: "User"
      end

      # Using a map
      iex> Miss.Kernel.struct_inverse(%{name: "Akira"}, User)
      %User{name: "Akira"}

      # Using keywords
      iex> Miss.Kernel.struct_inverse([name: "Akira"], User)
      %User{name: "Akira"}

      # Updating an existing struct
      iex> user = %User{name: "Other"}
      ...> Miss.Kernel.struct_inverse(%{name: "Akira"}, user)
      %User{name: "Akira"}

      # Known keys are used and unknown keys are ignored
      iex> Miss.Kernel.struct_inverse(%{name: "Akira", last_name: "Hamasaki"}, User)
      %User{name: "Akira"}

      # Unknown keys are ignored
      iex> Miss.Kernel.struct_inverse(%{last_name: "Hamasaki"}, User)
      %User{name: "User"}

      # String keys are ignored
      iex> Miss.Kernel.struct_inverse(%{"name" => "Akira"}, User)
      %User{name: "User"}

      # Using empty fields
      iex> Miss.Kernel.struct_inverse(%{}, User)
      %User{name: "User"}

  """
  @spec struct_inverse(Enum.t(), module() | struct()) :: struct()
  def struct_inverse(fields, struct), do: struct(struct, fields)

  @doc """
  Similar to `Miss.Kernel.struct_inverse/2` but checks for key validity emulating the compile time
  behaviour of structs.

  ## Examples

      defmodule User do
        defstruct name: "User"
      end

      # Using a map
      iex> Miss.Kernel.struct_inverse!(%{name: "Akira"}, User)
      %User{name: "Akira"}

      # Using keywords
      iex> Miss.Kernel.struct_inverse!([name: "Akira"], User)
      %User{name: "Akira"}

      # Updating an existing struct
      iex> user = %User{name: "Other"}
      ...> Miss.Kernel.struct_inverse!(%{name: "Akira"}, user)
      %User{name: "Akira"}

      # Unknown keys raises KeyError
      iex> Miss.Kernel.struct_inverse!(%{name: "Akira", last_name: "Hamasaki"}, User)
      ** (KeyError) key :last_name not found in: %Miss.KernelTest.User{name: "User"}

      # String keys raises KeyError
      iex> Miss.Kernel.struct_inverse!(%{"name" => "Akira"}, User)
      ** (KeyError) key "name" not found in: %Miss.KernelTest.User{name: "User"}

      # Using empty fields
      iex> Miss.Kernel.struct_inverse!(%{}, User)
      %User{name: "User"}

  """
  @spec struct_inverse!(Enum.t(), module() | struct()) :: struct()
  def struct_inverse!(fields, struct), do: struct!(struct, fields)

  @doc """
  Creates a list of structs similar to `Kernel.struct/2`.

  In the same way that `Kernel.struct/2`, the `struct` argument may be an atom (which defines
  `defstruct`) or a `struct` itself.

  The second argument is a list of any `Enumerable` that emits two-element tuples (key-value
  pairs) during enumeration.

  Keys in the `Enumerable` that do not exist in the struct are automatically discarded. Note that
  keys must be atoms, as only atoms are allowed when defining a struct. If keys in the
  `Enumerable` are duplicated, the last entry will be taken (the same behaviour as `Map.new/1`).

  This function is useful for dynamically creating a list of structs, as well as for converting a
  list of maps to a list of structs.

  ## Examples

      defmodule User do
        defstruct name: "User"
      end

      # Using a list of maps
      iex> Miss.Kernel.struct_list(User, [
      ...>   %{name: "Akira"},
      ...>   %{name: "Fernando"}
      ...> ])
      [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      # Using a list of keywords
      iex> Miss.Kernel.struct_list(User, [
      ...>   [name: "Akira"],
      ...>   [name: "Fernando"]
      ...> ])
      [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      # Using an existing struct
      iex> user = %User{name: "Other"}
      ...> Miss.Kernel.struct_list(user, [
      ...>   %{name: "Akira"},
      ...>   %{name: "Fernando"}
      ...> ])
      [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      # Known keys are used and unknown keys are ignored
      iex> Miss.Kernel.struct_list(User, [
      ...>   %{name: "Akira", last_name: "Hamasaki"},
      ...>   %{name: "Fernando", last_name: "Hamasaki"}
      ...> ])
      [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      # Unknown keys are ignored
      iex> Miss.Kernel.struct_list(User, [
      ...>   %{first_name: "Akira"},
      ...>   %{last_name: "Hamasaki"}
      ...> ])
      [
        %User{name: "User"},
        %User{name: "User"}
      ]

      # String keys are ignored
      iex> Miss.Kernel.struct_list(User, [
      ...>   %{"name" => "Akira"},
      ...>   %{"name" => "Fernando"}
      ...> ])
      [
        %User{name: "User"},
        %User{name: "User"}
      ]

  """
  @spec struct_list(module() | struct(), [Enum.t()]) :: [struct()]
  def struct_list(struct, list), do: Enum.map(list, &struct(struct, &1))

  @doc """
  Creates a list of structs similar to `Miss.Kernel.struct_list/2`, but checks for key
  validity emulating the compile time behaviour of structs.

  ## Examples

      defmodule User do
        defstruct name: "User"
      end

      # Using a list of maps
      iex> Miss.Kernel.struct_list!(User, [
      ...>   %{name: "Akira"},
      ...>   %{name: "Fernando"}
      ...> ])
      [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      # Using a list of keywords
      iex> Miss.Kernel.struct_list!(User, [
      ...>   [name: "Akira"],
      ...>   [name: "Fernando"]
      ...> ])
      [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      # Using an existing struct
      iex> user = %User{name: "Other"}
      ...> Miss.Kernel.struct_list!(user, [
      ...>   %{name: "Akira"},
      ...>   %{name: "Fernando"}
      ...> ])
      [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      # Unknown keys raises KeyError
      iex> Miss.Kernel.struct_list!(User, [
      ...>   %{name: "Akira", last_name: "Hamasaki"},
      ...>   %{name: "Fernando", last_name: "Hamasaki"}
      ...> ])
      ** (KeyError) key :last_name not found in: %Miss.KernelTest.User{name: "User"}

      # String keys raises KeyError
      iex> Miss.Kernel.struct_list!(User, [
      ...>   %{"name" => "Akira"},
      ...>   %{"name" => "Fernando"}
      ...> ])
      ** (KeyError) key "name" not found in: %Miss.KernelTest.User{name: "User"}

  """
  @spec struct_list!(module() | struct(), [Enum.t()]) :: [struct()]
  def struct_list!(struct, list), do: Enum.map(list, &struct!(struct, &1))
end
