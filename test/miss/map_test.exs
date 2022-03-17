defmodule Miss.MapTest do
  use ExUnit.Case, async: true

  alias Miss.Map, as: Subject

  # Structs also used in doctests.
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
    defstruct [:atom, :boolean, :decimal, :float, :integer, :map]
  end

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

  describe "from_nested_struct/2" do
    setup do
      struct = %Post{
        title: "My post",
        text: "Something really interesting.",
        date: ~D[2010-09-01],
        author: %Author{
          name: "Pedro Bonamides",
          metadata: %Metadata{
            atom: :my_atom,
            boolean: true,
            decimal: Decimal.new("456.78"),
            float: 987.54,
            integer: 2_345_678,
            map: %{
              comment: %Comment{text: "Comment one"},
              key: "value"
            }
          }
        },
        comments: [
          %Comment{text: "Comment one"},
          %Comment{text: "Comment two"}
        ]
      }

      {:ok, struct: struct}
    end

    test "converts to map going through all nested structs", %{struct: struct} do
      expected_map = %{
        title: "My post",
        text: "Something really interesting.",
        date: %{calendar: Calendar.ISO, day: 1, month: 9, year: 2010},
        author: %{
          name: "Pedro Bonamides",
          metadata: %{
            atom: :my_atom,
            boolean: true,
            decimal: %{coef: 45_678, exp: -2, sign: 1},
            float: 987.54,
            integer: 2_345_678,
            map: %{
              comment: %{text: "Comment one"},
              key: "value"
            }
          }
        },
        comments: [
          %{text: "Comment one"},
          %{text: "Comment two"}
        ]
      }

      assert Subject.from_nested_struct(struct) == expected_map
    end

    test "when transform is given with functions, " <>
           "converts to map going through all nested structs " <>
           "using the transformation functions in the given struct modules",
         %{struct: struct} do
      expected_map = %{
        title: "My post",
        text: "Something really interesting.",
        date: "2010-09-01",
        author: %{
          name: "Pedro Bonamides",
          metadata: %{
            atom: :my_atom,
            boolean: true,
            decimal: 456.78,
            float: 987.54,
            integer: 2_345_678,
            map: %{
              comment: "Comment one",
              key: "value"
            }
          }
        },
        comments: ["Comment one", "Comment two"]
      }

      assert Subject.from_nested_struct(
               struct,
               [
                 {Date, &to_string/1},
                 {Decimal, &Decimal.to_float/1},
                 {Comment, fn %{text: text} -> text end}
               ]
             ) == expected_map
    end

    test "when transform is given with :skip," <>
           "converts to map going through all nested structs " <>
           "skiping the conversion for the given struct types",
         %{struct: struct} do
      expected_map = %{
        title: "My post",
        text: "Something really interesting.",
        date: ~D[2010-09-01],
        author: %{
          name: "Pedro Bonamides",
          metadata: %{
            atom: :my_atom,
            boolean: true,
            decimal: Decimal.new("456.78"),
            float: 987.54,
            integer: 2_345_678,
            map: %{
              comment: %{text: "Comment one"},
              key: "value"
            }
          }
        },
        comments: [
          %{text: "Comment one"},
          %{text: "Comment two"}
        ]
      }

      assert Subject.from_nested_struct(struct, [{Date, :skip}, {Decimal, :skip}]) == expected_map
    end
  end

  describe "get!/2" do
    test "returns the value", %{map_atom_keys: map} do
      assert Subject.get!(map, :key1) == "one"
      assert Subject.get!(map, :key2) == 222
      assert Subject.get!(map, :key3) == 'tree'
    end

    test "when the key is not present, raises a KeyError", %{map_atom_keys: map} do
      assert_raise KeyError, "key :not_exist not found in: #{inspect(map)}", fn ->
        Subject.get!(map, :not_exist)
      end
    end

    test "when a map is not given, raises a BadMapError" do
      assert_raise BadMapError, "expected a map, got: [a: 1, b: 2]", fn ->
        Subject.get!([a: 1, b: 2], :key1)
      end
    end
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
      assert_raise BadMapError, "expected a map, got: [a: 1, b: 2]", fn ->
        Subject.rename_key([a: 1, b: 2], :key1, :one)
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
      assert_raise BadMapError, "expected a map, got: [a: 1, b: 2]", fn ->
        Subject.rename_keys([a: 1, b: 2], key1: :one)
      end
    end
  end
end
