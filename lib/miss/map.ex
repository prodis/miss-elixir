defmodule Miss.Map do
  @moduledoc """
  Functions to extend the Elixir `Map` module.
  """

  @type renaming_keys :: [{actual_key :: Map.key(), new_key :: Map.key()}] | map()
  @typep map_to_list :: [{Map.key(), Map.value()}]

  @doc """
  Renames keys in the given `map`.

  Keys to be renamed are given through `renaming_keys` that accepts either:
  * a list of two-element tuples: `{actual_key, new_key}`; or
  * a map where the keys are the actual keys and the values are the new keys:
  `%{actual_key => new_key}`

  If `renaming_keys` contains keys that are not in `map`, they are simply ignored.

  After renaming the keys, duplicated keys are removed, the preceding one prevails.

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
  @spec rename_keys(map(), renaming_keys()) :: map()
  def rename_keys(map, []) when is_map(map), do: map

  def rename_keys(map, renaming_keys) when is_map(map) and renaming_keys == %{}, do: map

  def rename_keys(map, renaming_keys) when is_map(map) and is_list(renaming_keys),
    do: rename_keys(map, :maps.from_list(renaming_keys))

  def rename_keys(map, renaming_keys) when is_map(map) and is_map(renaming_keys) do
    map
    |> :maps.to_list()
    |> rename_keys(renaming_keys, _acc = [])
  end

  def rename_keys(non_map, _renaming_keys), do: :erlang.error({:badmap, non_map})

  @spec rename_keys(map_to_list(), map(), map_to_list()) :: map()
  defp rename_keys([], _keys_mapping, acc), do: :maps.from_list(acc)

  defp rename_keys([{key, value} | rest], keys_mapping, acc) do
    item =
      case keys_mapping do
        %{^key => new_key} -> {new_key, value}
        %{} -> {key, value}
      end

    rename_keys(rest, keys_mapping, [item | acc])
  end
end
