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

  describe "charlist?/1" do
    @types_and_values [
      atom: :prodis,
      boolean: true,
      float: 123.45,
      integer: 123,
      string: "prodis"
    ]

    test "when a charlist is given, returns true" do
      assert Subject.charlist?('prodis') == true
      assert Subject.charlist?('córação dê mélão') == true
      assert Subject.charlist?('') == true
    end

    test "when a list of integers that represent Unicode code points is given, returns true" do
      assert Subject.charlist?([0, 55_295]) == true
      assert Subject.charlist?([57_344, 1_114_111]) == true
    end

    test "when a list of integers that does not represent Unicode code points is given, returns false" do
      assert Subject.charlist?([1_114_112]) == false
      assert Subject.charlist?([1_999_999]) == false
      assert Subject.charlist?([1_114_113, 1_114_114]) == false
    end

    test "when a list of integers that represent Unicode for UTF-16 is given, returns false" do
      assert Subject.charlist?([55_296]) == false
      assert Subject.charlist?([57_343]) == false
      assert Subject.charlist?([55_297, 57_342]) == false
    end

    test "when a list of negative integers is given, returns false" do
      assert Subject.charlist?([-1, -1]) == false
    end

    for {type, value} <- @types_and_values do
      test "when a #{type} is given, returns false" do
        assert Subject.charlist?(unquote(value)) == false
      end
    end

    for {type, value} when type != :integer <- @types_and_values do
      test "when a list of #{type}s is given, returns false" do
        assert Subject.charlist?([unquote(value), unquote(value)]) == false
      end
    end
  end

  describe "struct_inverse/2" do
    setup do
      default_struct = struct(User)
      struct = %User{name: "Fernando"}

      {:ok, default_struct: default_struct, struct: struct}
    end

    test "creates a struct", %{struct: expected_struct} do
      assert Subject.struct_inverse(%{name: "Fernando"}, User) == expected_struct
      assert Subject.struct_inverse([name: "Fernando"], User) == expected_struct
    end

    test "updates a struct", %{struct: expected_struct} do
      struct = %User{name: "Akira"}
      fields = %{name: "Fernando"}

      assert Subject.struct_inverse(fields, struct) == expected_struct
    end

    test "when some of the given keys are not present in the struct, " <>
           "ignores the unknown keys and creates the struct",
         %{
           struct: expected_struct
         } do
      fields = %{name: "Fernando", last_name: "Hamasaki"}

      assert Subject.struct_inverse(fields, User) == expected_struct
    end

    test "when the given keys are not present in the struct, " <>
           "ignores the unknown keys and creates a default struct",
         %{
           default_struct: expected_struct
         } do
      fields = %{last_name: "Hamasaki"}

      assert Subject.struct_inverse(fields, User) == expected_struct
    end

    test "when a map is given with string keys, " <>
           "ignores the string keys and creates a default struct",
         %{
           default_struct: expected_struct
         } do
      fields = %{"name" => "Akira"}

      assert Subject.struct_inverse(fields, User) == expected_struct
    end

    test "when the given fields are empty, creates a default struct", %{
      default_struct: expected_struct
    } do
      assert Subject.struct_inverse(%{}, User) == expected_struct
      assert Subject.struct_inverse([], User) == expected_struct
    end
  end

  describe "struct_inverse!/2" do
    setup do
      struct = %User{name: "Fernando"}

      {:ok, struct: struct}
    end

    test "creates a struct", %{struct: expected_struct} do
      assert Subject.struct_inverse!(%{name: "Fernando"}, User) == expected_struct
      assert Subject.struct_inverse!([name: "Fernando"], User) == expected_struct
    end

    test "updates a struct", %{struct: expected_struct} do
      struct = %User{name: "Akira"}
      fields = %{name: "Fernando"}

      assert Subject.struct_inverse!(fields, struct) == expected_struct
    end

    test "when some of the given keys are not present in the struct, " <>
           "ignores the unknown keys and creates the struct" do
      fields = %{name: "Fernando", last_name: "Hamasaki"}

      assert_raise KeyError, fn ->
        Subject.struct_inverse!(fields, User)
      end
    end

    test "when the given keys are not present in the struct, " <>
           "ignores the unknown keys and creates a default struct" do
      fields = %{last_name: "Hamasaki"}

      assert_raise KeyError, fn ->
        Subject.struct_inverse!(fields, User)
      end
    end

    test "when a map is given with string keys, " <>
           "ignores the string keys and creates a default struct" do
      fields = %{"name" => "Akira"}

      assert_raise KeyError, fn ->
        Subject.struct_inverse!(fields, User)
      end
    end

    test "when the given fields are empty, creates a default struct" do
      expected_struct = struct(User)

      assert Subject.struct_inverse!(%{}, User) == expected_struct
      assert Subject.struct_inverse!([], User) == expected_struct
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
      struct = %User{name: "Other"}

      list = [
        %{name: "Akira"},
        %{name: "Fernando"}
      ]

      assert Subject.struct_list(struct, list) == expected_structs
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
      structs = [
        %User{name: "Akira"},
        %User{name: "Fernando"}
      ]

      {:ok, structs: structs}
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
      struct = %User{name: "Other"}

      list = [
        %{name: "Akira"},
        %{name: "Fernando"}
      ]

      assert Subject.struct_list!(struct, list) == expected_structs
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
