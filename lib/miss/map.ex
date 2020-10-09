defmodule Miss.Map do
  @moduledoc """
  Functions to extend the Elixir `Map` module.
  """

  @type keys_to_rename :: [{actual_key :: Map.key(), new_key :: Map.key()}] | map()
  @type transform :: [{module(), (module() -> term()) | :skip}]
  @typep map_to_list :: [{Map.key(), Map.value()}]

  @doc """
  Converts a `struct` to map going through all nested structs, different from `Map.from_struct/1`
  that only converts the root struct.

  The optional parameter `transform` receives a list of tuples with the struct module and a
  function to be called instead of converting to a map. The transforming function will receive the
  struct as a single parameter.

  If you want to skip the conversion of a nested struct, just pass the atom `:skip` instead of a
  transformation function.

  `Date` or `Decimal` values are common examples where their map representation could be not so
  useful when converted to a map. See the examples for more details.

  ## Examples

      # Given the following structs

      defmodule Post do
        defstruct [:title, :text, :date, :author, comments: []]
      end

      defmodule Author do
        defstruct [:name, :metadata]
      end

      defmodule Comment do
        defstruct [:text]
      end

      defmodule Metadata do
        defstruct [:atom, :boolean, :decimal, :float, :integer]
      end

      # Convert all nested structs including the Date and Decimal values:

      iex> post = %Post{
      ...>   title: "My post",
      ...>   text: "Something really interesting",
      ...>   date: ~D[2010-09-01],
      ...>   author: %Author{
      ...>     name: "Pedro Bonamides",
      ...>     metadata: %Metadata{
      ...>       atom: :my_atom,
      ...>       boolean: true,
      ...>       decimal: Decimal.new("456.78"),
      ...>       float: 987.54,
      ...>       integer: 2_345_678
      ...>     }
      ...>   },
      ...>   comments: [
      ...>     %Comment{text: "Comment one"},
      ...>     %Comment{text: "Comment two"}
      ...>   ]
      ...> }
      ...> #{inspect(__MODULE__)}.from_nested_struct(post)
      %{
        title: "My post",
        text: "Something really interesting",
        date: %{calendar: Calendar.ISO, day: 1, month: 9, year: 2010},
        author: %{
          name: "Pedro Bonamides",
          metadata: %{
            atom: :my_atom,
            boolean: true,
            decimal: %{coef: 45678, exp: -2, sign: 1},
            float: 987.54,
            integer: 2_345_678
          }
        },
        comments: [
          %{text: "Comment one"},
          %{text: "Comment two"}
        ]
      }

      # Convert all nested structs skipping the Date values and transforming Decimal values to string:

      iex> post = %Post{
      ...>   title: "My post",
      ...>   text: "Something really interesting",
      ...>   date: ~D[2010-09-01],
      ...>   author: %Author{
      ...>     name: "Pedro Bonamides",
      ...>     metadata: %Metadata{
      ...>       atom: :my_atom,
      ...>       boolean: true,
      ...>       decimal: Decimal.new("456.78"),
      ...>       float: 987.54,
      ...>       integer: 2_345_678
      ...>     }
      ...>   },
      ...>   comments: [
      ...>     %Comment{text: "Comment one"},
      ...>     %Comment{text: "Comment two"}
      ...>   ]
      ...> }
      ...> #{inspect(__MODULE__)}.from_nested_struct(post, [{Date, :skip}, {Decimal, &to_string/1}])
      %{
        title: "My post",
        text: "Something really interesting",
        date: ~D[2010-09-01],
        author: %{
          name: "Pedro Bonamides",
          metadata: %{
            atom: :my_atom,
            boolean: true,
            decimal: "456.78",
            float: 987.54,
            integer: 2_345_678
          }
        },
        comments: [
          %{text: "Comment one"},
          %{text: "Comment two"}
        ]
      }

  """
  @spec from_nested_struct(struct(), transform()) :: map()
  def from_nested_struct(struct, transform \\ []) when is_struct(struct),
    do: to_map(struct, transform)

  @spec to_map(term(), transform()) :: term()
  defp to_map(%module{} = struct, transform) do
    transform
    |> Keyword.get(module)
    |> case do
      nil -> to_nested_map(struct, transform)
      fun when is_function(fun, 1) -> fun.(struct)
      :skip -> struct
    end
  end

  defp to_map(list, transform) when is_list(list),
    do: Enum.map(list, fn item -> to_map(item, transform) end)

  defp to_map(value, _transform), do: value

  @spec to_nested_map(struct(), transform()) :: map()
  defp to_nested_map(struct, transform) do
    struct
    |> Map.from_struct()
    |> Map.keys()
    |> Enum.reduce(%{}, fn key, map ->
      value =
        struct
        |> Map.get(key)
        |> to_map(transform)

      Map.put(map, key, value)
    end)
  end

  @doc """
  Gets the value for a specific `key` in `map`.

  If `key` is present in `map`, the corresponding value is returned. Otherwise, a `KeyError` is
  raised.

  `Miss.Map.get!/2` is similar to `Map.fetch!/2` but more efficient. Using pattern matching is the
  fastest way to access maps. `Miss.Map.get!/2` uses pattern matching, but `Map.fetch!/2` not.

  ## Examples

      iex> Miss.Map.get!(%{a: 1, b: 2}, :a)
      1

      iex> Miss.Map.get!(%{a: 1, b: 2}, :c)
      ** (KeyError) key :c not found in: %{a: 1, b: 2}

  """
  @spec get!(map(), Map.key()) :: Map.value()
  def get!(map, key) do
    case map do
      %{^key => value} -> value
      %{} -> :erlang.error({:badkey, key, map})
      non_map -> :erlang.error({:badmap, non_map})
    end
  end

  @doc """
  Renames a single key in the given `map`.

  If `actual_key` does not exist in `map`, it is simply ignored.

  If a key is renamed to an existing key, the value of the actual key remains.

  ## Examples

      iex> Miss.Map.rename_key(%{a: 1, b: 2, c: 3}, :b, :bbb)
      %{a: 1, bbb: 2, c: 3}

      iex> Miss.Map.rename_key(%{"a" => 1, "b" => 2, "c" => 3}, "b", "bbb")
      %{"a" => 1, "bbb" => 2, "c" => 3}

      iex> Miss.Map.rename_key(%{a: 1, b: 2, c: 3}, :z, :zzz)
      %{a: 1, b: 2, c: 3}

      iex> Miss.Map.rename_key(%{a: 1, b: 2, c: 3}, :a, :c)
      %{b: 2, c: 1}

      iex> Miss.Map.rename_key(%{a: 1, b: 2, c: 3}, :c, :a)
      %{a: 3, b: 2}

  """
  @spec rename_key(map(), Map.key(), Map.key()) :: map()
  def rename_key(map, actual_key, new_key) when is_map(map) do
    case :maps.take(actual_key, map) do
      {value, new_map} -> :maps.put(new_key, value, new_map)
      :error -> map
    end
  end

  def rename_key(non_map, _actual_key, _new_key), do: :erlang.error({:badmap, non_map})

  @doc """
  Renames keys in the given `map`.

  Keys to be renamed are given through `keys_to_rename` that accepts either:
  * a list of two-element tuples: `{actual_key, new_key}`; or
  * a map where the keys are the actual keys and the values are the new keys: `%{actual_key => new_key}`

  If `keys_to_rename` contains keys that are not in `map`, they are simply ignored.

  It is not recommended to use `#{inspect(__MODULE__)}.rename_keys/2` to rename keys to existing
  keys. But if you do it, after renaming the keys, duplicate keys are removed and the value of the
  preceding one prevails. See the examples for more details.

  ## Examples

      iex> Miss.Map.rename_keys(%{a: 1, b: 2, c: 3}, %{a: :aaa, c: :ccc})
      %{aaa: 1, b: 2, ccc: 3}

      iex> Miss.Map.rename_keys(%{a: 1, b: 2, c: 3}, a: :aaa, c: :ccc)
      %{aaa: 1, b: 2, ccc: 3}

      iex> Miss.Map.rename_keys(%{"a" => 1, "b" => 2, "c" => 3}, %{"a" => "aaa", "b" => "bbb"})
      %{"aaa" => 1, "bbb" => 2, "c" => 3}

      iex> Miss.Map.rename_keys(%{"a" => 1, "b" => 2, "c" => 3}, [{"a", "aaa"}, {"b", "bbb"}])
      %{"aaa" => 1, "bbb" => 2, "c" => 3}

      iex> Miss.Map.rename_keys(%{a: 1, b: 2, c: 3}, a: :aaa, z: :zzz)
      %{aaa: 1, b: 2, c: 3}

      iex> Miss.Map.rename_keys(%{a: 1, b: 2, c: 3}, a: :c)
      %{b: 2, c: 1}

      iex> Miss.Map.rename_keys(%{a: 1, b: 2, c: 3}, c: :a)
      %{a: 1, b: 2}

      iex> Miss.Map.rename_keys(%{a: 1, b: 2, c: 3}, [])
      %{a: 1, b: 2, c: 3}

  """
  @spec rename_keys(map(), keys_to_rename()) :: map()
  def rename_keys(map, []) when is_map(map), do: map

  def rename_keys(map, keys_to_rename) when is_map(map) and keys_to_rename == %{}, do: map

  def rename_keys(map, keys_to_rename) when is_map(map) and is_list(keys_to_rename),
    do: rename_keys(map, :maps.from_list(keys_to_rename))

  def rename_keys(map, keys_to_rename) when is_map(map) and is_map(keys_to_rename) do
    map
    |> :maps.to_list()
    |> do_rename_keys(keys_to_rename, _acc = [])
  end

  def rename_keys(non_map, _keys_to_rename), do: :erlang.error({:badmap, non_map})

  @spec do_rename_keys(map_to_list(), map(), map_to_list()) :: map()
  defp do_rename_keys([], _keys_mapping, acc), do: :maps.from_list(acc)

  defp do_rename_keys([{key, value} | rest], keys_mapping, acc) do
    item =
      case keys_mapping do
        %{^key => new_key} -> {new_key, value}
        %{} -> {key, value}
      end

    do_rename_keys(rest, keys_mapping, [item | acc])
  end
end
