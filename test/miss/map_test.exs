defmodule Miss.MapTest do
  use ExUnit.Case, async: true

  alias Miss.Map, as: Subject

  doctest Subject

  setup do
    map_keys_atom = %{
      key1: "one",
      key2: 222,
      key3: 'tree'
    }

    map_keys_string = %{
      "key1" => "one",
      "key2" => 222,
      "key3" => 'tree'
    }

    {:ok, map_keys_atom: map_keys_atom, map_keys_string: map_keys_string}
  end

  describe "rename_keys/2" do
    test "renames atom keys", %{map_keys_atom: map} do
      assert Subject.rename_keys(map, key1: :key_one) ==
               %{key_one: "one", key2: 222, key3: 'tree'}

      assert Subject.rename_keys(map, %{key1: :key_one}) ==
               %{key_one: "one", key2: 222, key3: 'tree'}

      assert Subject.rename_keys(map, key1: :key_one, key2: :key_two) ==
               %{key_one: "one", key_two: 222, key3: 'tree'}

      assert Subject.rename_keys(map, %{key1: :key_one, key2: :key_two}) ==
               %{key_one: "one", key_two: 222, key3: 'tree'}

      assert Subject.rename_keys(map, key1: :key_one, key2: :key_two, key3: :tree) ==
               %{key_one: "one", key_two: 222, tree: 'tree'}

      assert Subject.rename_keys(map, %{key1: :key_one, key2: :key_two, key3: :tree}) ==
               %{key_one: "one", key_two: 222, tree: 'tree'}
    end

    test "renames string keys", %{map_keys_string: map} do
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
      map_keys_atom: map_keys_atom,
      map_keys_string: map_keys_string
    } do
      assert Subject.rename_keys(map_keys_atom, not_exist: :nothing) == map_keys_atom
      assert Subject.rename_keys(map_keys_atom, %{not_exist: :nothing}) == map_keys_atom

      assert Subject.rename_keys(map_keys_atom, not_exist: :nothing, key3: :something) ==
               %{
                 key1: "one",
                 key2: 222,
                 something: 'tree'
               }

      assert Subject.rename_keys(map_keys_atom, %{not_exist: :nothing, key3: :something}) ==
               %{
                 key1: "one",
                 key2: 222,
                 something: 'tree'
               }

      assert Subject.rename_keys(map_keys_string, [{"not_exist", "nothing"}]) == map_keys_string
      assert Subject.rename_keys(map_keys_string, %{"not_exist" => "nothing"}) == map_keys_string

      assert Subject.rename_keys(map_keys_string, [
               {"not_exist", "nothing"},
               {"key1", "something"}
             ]) == %{
               "something" => "one",
               "key2" => 222,
               "key3" => 'tree'
             }

      assert Subject.rename_keys(map_keys_string, %{
               "not_exist" => "nothing",
               "key1" => "something"
             }) == %{
               "something" => "one",
               "key2" => 222,
               "key3" => 'tree'
             }
    end

    test "when a new key has the same of an existing key, " <>
           "renames the key and removes the duplicated keys using the value of the preceding one",
         %{
           map_keys_atom: map_keys_atom,
           map_keys_string: map_keys_string
         } do
      assert Subject.rename_keys(map_keys_atom, key1: :key2) ==
               %{
                 key2: "one",
                 key3: 'tree'
               }

      assert Subject.rename_keys(map_keys_atom, %{key1: :key2}) ==
               %{
                 key2: "one",
                 key3: 'tree'
               }

      assert Subject.rename_keys(map_keys_string, [{"key3", "key1"}]) ==
               %{
                 "key1" => "one",
                 "key2" => 222
               }

      assert Subject.rename_keys(map_keys_string, %{"key3" => "key1"}) ==
               %{
                 "key1" => "one",
                 "key2" => 222
               }
    end

    test "when an empty keys are given, returns the same map", %{
      map_keys_atom: map_keys_atom,
      map_keys_string: map_keys_string
    } do
      assert Subject.rename_keys(map_keys_atom, []) == map_keys_atom
      assert Subject.rename_keys(map_keys_atom, %{}) == map_keys_atom
      assert Subject.rename_keys(map_keys_string, []) == map_keys_string
      assert Subject.rename_keys(map_keys_string, %{}) == map_keys_string
    end

    test "when a map is not given, raises a BadMapError" do
      assert_raise BadMapError, fn ->
        Subject.rename_keys("not a map", key1: :one)
      end
    end
  end
end
