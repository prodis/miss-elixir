defmodule Miss.KernelTest do
  use ExUnit.Case, async: true

  alias Miss.Kernel, as: Subject

  # Struct also used in doctests.
  defmodule User, do: defstruct(name: "User")

  doctest Subject

  describe "struct_list/2" do
    setup do
      default_structs = [
        struct(User),
        struct(User)
      ]

      structs = [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      {:ok, default_structs: default_structs, structs: structs}
    end

    test "when a list of maps is given, returns a list of structs", %{
      structs: expected_structs
    } do
      list = [
        %{name: "Akira"},
        %{name: "Fernando"}
      ]

      assert Subject.struct_list(User, list) == expected_structs
    end

    test "when a list of keywords is given, returns a list of structs", %{
      structs: expected_structs
    } do
      list = [
        [name: "Akira"],
        [name: "Fernando"]
      ]

      assert Subject.struct_list(User, list) == expected_structs
    end

    test "when using an existing struct, returns a list of structs", %{
      structs: expected_structs
    } do
      user = %User{name: "Other"}

      list = [
        %{name: "Akira"},
        %{name: "Fernando"}
      ]

      assert Subject.struct_list(user, list) == expected_structs
    end

    test "when some of the given keys are not present in the struct, " <>
           "ignores the unknown keys and returns a list of structs",
         %{
           structs: expected_structs
         } do
      list = [
        %{name: "Akira", last_name: "Hamasaki"},
        %{name: "Fernando", last_name: "Hamasaki"}
      ]

      assert Subject.struct_list(User, list) == expected_structs
    end

    test "when the given keys are not present in the struct, " <>
           "ignores the unknown keys and returns a list of structs",
         %{
           default_structs: expected_structs
         } do
      list = [
        %{first_name: "Akira"},
        %{last_name: "Hamasaki"}
      ]

      assert Subject.struct_list(User, list) == expected_structs
    end

    test "when a list of maps is given with string keys, " <>
           "ignores the string keys and returns a list of structs",
         %{
           default_structs: expected_structs
         } do
      list = [
        %{"name" => "Akira"},
        %{"name" => "Fernando"}
      ]

      assert Subject.struct_list(User, list) == expected_structs
    end

    test "when a empty list is given, returns an empty list" do
      assert Subject.struct_list(User, []) == []
    end
  end
end
