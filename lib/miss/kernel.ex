defmodule Miss.Kernel do
  @moduledoc """
  Functions to extend Elixir `Kernel` module.
  """

  @doc """
  Creates a list of structs similar to `Kernel.struct/2`.

  In the same way that `Kernel.struct/2`, the `struct` argument may be an atom (which defines
  `defstruct`) or a `struct` itself.

  The second argument is a list of any `Enumerable` that emits two-element tuples (key-value
  pairs) during enumeration.

  Keys in the `Enumerable` that do not exist in the struct are automatically discarded. Note that
  keys must be atoms, as only atoms are allowed when defining a struct. If keys in the
  `Enumerable` are duplicated, the last entry will be taken (same behaviour as `Map.new/1`).

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
end
