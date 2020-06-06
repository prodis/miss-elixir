defmodule Miss.KernelTest do
  use ExUnit.Case, async: true

  alias Miss.Kernel, as: Subject

  # Struct also used in doctests.
  defmodule User, do: defstruct(name: "User")

  doctest Subject

  describe "div_rem/2" do
    test "returns the division result and the remainder" do
      assert Subject.div_rem(5, 2) == {2, 1}
      assert Subject.div_rem(6, -4) == {-1, 2}
      assert Subject.div_rem(-99, 2) == {-49, -1}
      assert Subject.div_rem(10, 5) == {2, 0}
      assert Subject.div_rem(0, 2) == {0, 0}
    end

    test "when the divisor is zero, raises an ArithmeticError" do
      assert_raise ArithmeticError, fn ->
        Subject.div_rem(2, 0)
      end
    end

    test "when the dividend is not an integer, raises an ArithmeticError" do
      assert_raise ArithmeticError, fn ->
        Subject.div_rem(10.0, 2)
      end
    end

    test "when the divisor is not an integer, raises an ArithmeticError" do
      assert_raise ArithmeticError, fn ->
        Subject.div_rem(10, 2.0)
      end
    end
  end

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

  describe "struct_list!/2" do
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

      assert Subject.struct_list!(User, list) == expected_structs
    end

    test "when a list of keywords is given, returns a list of structs", %{
      structs: expected_structs
    } do
      list = [
        [name: "Akira"],
        [name: "Fernando"]
      ]

      assert Subject.struct_list!(User, list) == expected_structs
    end

    test "when using an existing struct, returns a list of structs", %{
      structs: expected_structs
    } do
      user = %User{name: "Other"}

      list = [
        %{name: "Akira"},
        %{name: "Fernando"}
      ]

      assert Subject.struct_list!(user, list) == expected_structs
    end

    test "when some of the given keys are not present in the struct, raises a KeyError" do
      list = [
        %{name: "Akira", last_name: "Hamasaki"},
        %{name: "Fernando", last_name: "Hamasaki"}
      ]

      assert_raise KeyError, fn ->
        Subject.struct_list!(User, list)
      end
    end

    test "when the given keys are not present in the struct, raises a KeyError" do
      list = [
        %{first_name: "Akira"},
        %{last_name: "Hamasaki"}
      ]

      assert_raise KeyError, fn ->
        Subject.struct_list!(User, list)
      end
    end

    test "when a list of maps is given with string keys, raises a KeyError" do
      list = [
        %{"name" => "Akira"},
        %{"name" => "Fernando"}
      ]

      assert_raise KeyError, fn ->
        Subject.struct_list!(User, list)
      end
    end

    test "when a empty list is given, returns an empty list" do
      assert Subject.struct_list!(User, []) == []
    end
  end
end
