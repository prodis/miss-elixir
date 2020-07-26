defmodule Miss.MapTest do
  use ExUnit.Case, async: true

  alias Miss.Map, as: Subject

  doctest Subject

  setup do
    map_atom_keys = %{
      key1: "one",
      key2: 222,
      key3: 'tree'
    }

    map_string_keys = %{
      "key1" => "one",
      "key2" => 222,
      "key3" => 'tree'
    }

    {:ok, map_atom_keys: map_atom_keys, map_string_keys: map_string_keys}
  end

  describe "rename_key/3" do
    test "renames atom key", %{map_atom_keys: map} do
      assert Subject.rename_key(map, :key1, :key_one) == %{
               key_one: "one",
               key2: 222,
               key3: 'tree'
             }

      assert Subject.rename_key(map, :key2, :key_two) == %{
               key1: "one",
               key_two: 222,
               key3: 'tree'
             }

      assert Subject.rename_key(map, :key3, :tree) == %{
               key1: "one",
               key2: 222,
               tree: 'tree'
             }
    end

    test "renames string key", %{map_string_keys: map} do
      assert Subject.rename_key(map, "key1", "key_one") == %{
               "key_one" => "one",
               "key2" => 222,
               "key3" => 'tree'
             }

      assert Subject.rename_key(map, "key2", "key_two") == %{
               "key1" => "one",
               "key_two" => 222,
               "key3" => 'tree'
             }

      assert Subject.rename_key(map, "key3", "tree") == %{
               "key1" => "one",
               "key2" => 222,
               "tree" => 'tree'
             }
    end

    test "when a given key to rename does not exist, ignores the key", %{
      map_atom_keys: map_atom_keys,
      map_string_keys: map_string_keys
    } do
      assert Subject.rename_key(map_atom_keys, :not_exist, :nothing) == map_atom_keys
      assert Subject.rename_key(map_string_keys, "not_exist", "nothing") == map_string_keys
    end

    test "when the new key has the same name of an existing key, " <>
           "renames the key using the value of the old key",
         %{
           map_atom_keys: map_atom_keys,
           map_string_keys: map_string_keys
         } do
      assert Subject.rename_key(map_atom_keys, :key1, :key2) == %{
               key2: "one",
               key3: 'tree'
             }

      assert Subject.rename_key(map_string_keys, "key3", "key1") == %{
               "key1" => 'tree',
               "key2" => 222
             }
    end

    test "when a map is not given, raises a BadMapError" do
      assert_raise BadMapError, fn ->
        Subject.rename_key("not a map", :key1, :one)
      end
    end
  end

  describe "rename_keys/2" do
    test "renames atom keys", %{map_atom_keys: map} do
      assert Subject.rename_keys(map, key1: :key_one) == %{
               key_one: "one",
               key2: 222,
               key3: 'tree'
             }

      assert Subject.rename_keys(map, %{key1: :key_one}) == %{
               key_one: "one",
               key2: 222,
               key3: 'tree'
             }

      assert Subject.rename_keys(map, key1: :key_one, key2: :key_two) == %{
               key_one: "one",
               key_two: 222,
               key3: 'tree'
             }

      assert Subject.rename_keys(map, %{key1: :key_one, key2: :key_two}) == %{
               key_one: "one",
               key_two: 222,
               key3: 'tree'
             }

      assert Subject.rename_keys(map, key1: :key_one, key2: :key_two, key3: :tree) == %{
               key_one: "one",
               key_two: 222,
               tree: 'tree'
             }

      assert Subject.rename_keys(map, %{key1: :key_one, key2: :key_two, key3: :tree}) == %{
               key_one: "one",
               key_two: 222,
               tree: 'tree'
             }
    end

    test "renames string keys", %{map_string_keys: map} do
      assert Subject.rename_keys(map, [
               {"key1", "key_one"}
             ]) == %{
               "key_one" => "one",
               "key2" => 222,
               "key3" => 'tree'
             }

      assert Subject.rename_keys(map, %{
               "key1" => "key_one"
             }) == %{
               "key_one" => "one",
               "key2" => 222,
               "key3" => 'tree'
             }

      assert Subject.rename_keys(map, [
               {"key1", "key_one"},
               {"key2", "key_two"}
             ]) == %{
               "key_one" => "one",
               "key_two" => 222,
               "key3" => 'tree'
             }

      assert Subject.rename_keys(map, %{
               "key1" => "key_one",
               "key2" => "key_two"
             }) == %{
               "key_one" => "one",
               "key_two" => 222,
               "key3" => 'tree'
             }

      assert Subject.rename_keys(map, [
               {"key1", "key_one"},
               {"key2", "key_two"},
               {"key3", "tree"}
             ]) == %{
               "key_one" => "one",
               "key_two" => 222,
               "tree" => 'tree'
             }

      assert Subject.rename_keys(map, %{
               "key1" => "key_one",
               "key2" => "key_two",
               "key3" => "tree"
             }) == %{
               "key_one" => "one",
               "key_two" => 222,
               "tree" => 'tree'
             }
    end

    test "when a given key to rename does not exist, ignores the key", %{
      map_atom_keys: map_atom_keys,
      map_string_keys: map_string_keys
    } do
      assert Subject.rename_keys(map_atom_keys, not_exist: :nothing) == map_atom_keys
      assert Subject.rename_keys(map_atom_keys, %{not_exist: :nothing}) == map_atom_keys

      assert Subject.rename_keys(map_atom_keys, not_exist: :nothing, key3: :something) == %{
               key1: "one",
               key2: 222,
               something: 'tree'
             }

      assert Subject.rename_keys(map_atom_keys, %{not_exist: :nothing, key3: :something}) == %{
               key1: "one",
               key2: 222,
               something: 'tree'
             }

      assert Subject.rename_keys(map_string_keys, [{"not_exist", "nothing"}]) == map_string_keys
      assert Subject.rename_keys(map_string_keys, %{"not_exist" => "nothing"}) == map_string_keys

      assert Subject.rename_keys(map_string_keys, [
               {"not_exist", "nothing"},
               {"key1", "something"}
             ]) == %{
               "something" => "one",
               "key2" => 222,
               "key3" => 'tree'
             }

      assert Subject.rename_keys(map_string_keys, %{
               "not_exist" => "nothing",
               "key1" => "something"
             }) == %{
               "something" => "one",
               "key2" => 222,
               "key3" => 'tree'
             }
    end

    test "when a new key has the same name of an existing key, " <>
           "renames the keys and removes the duplicated keys using the value of the preceding one",
         %{
           map_atom_keys: map_atom_keys,
           map_string_keys: map_string_keys
         } do
      assert Subject.rename_keys(map_atom_keys, key1: :key2) == %{
               key2: "one",
               key3: 'tree'
             }

      assert Subject.rename_keys(map_atom_keys, %{key1: :key2}) == %{
               key2: "one",
               key3: 'tree'
             }

      assert Subject.rename_keys(map_string_keys, [{"key3", "key1"}]) == %{
               "key1" => "one",
               "key2" => 222
             }

      assert Subject.rename_keys(map_string_keys, %{"key3" => "key1"}) == %{
               "key1" => "one",
               "key2" => 222
             }
    end

    test "when empty keys are given, returns the same map", %{
      map_atom_keys: map_atom_keys,
      map_string_keys: map_string_keys
    } do
      assert Subject.rename_keys(map_atom_keys, []) == map_atom_keys
      assert Subject.rename_keys(map_atom_keys, %{}) == map_atom_keys
      assert Subject.rename_keys(map_string_keys, []) == map_string_keys
      assert Subject.rename_keys(map_string_keys, %{}) == map_string_keys
    end

    test "when a map is not given, raises a BadMapError" do
      assert_raise BadMapError, fn ->
        Subject.rename_keys("not a map", key1: :one)
      end
    end
  end
end
