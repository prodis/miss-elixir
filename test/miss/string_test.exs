defmodule Miss.StringTest do
  use ExUnit.Case, async: true

  alias Miss.String, as: Subject

  doctest Subject

  describe "build/1" do
    test "when a list of strings is given, builds a new string" do
      assert Subject.build([
               "akira",
               "hamasaki",
               "123",
               "pim",
               "2010-09-01",
               "99.99"
             ]) == "akirahamasaki123pim2010-09-0199.99"
    end

    test "when a list of non strings is given, builds a new string" do
      assert Subject.build([
               :akira,
               'hamasaki',
               123,
               [112, 105, 109],
               ~D[2010-09-01],
               99.99
             ]) == "akirahamasaki123pim2010-09-0199.99"
    end

    test "when an item in the given list cannot be converted to string, " <>
           "raises Protocol.UndefinedError" do
      assert_raise Protocol.UndefinedError, fn ->
        Subject.build(["akira", %{}])
      end
    end

    test "when an item in the given list is a list that cannot be converted to string, " <>
           "raises ArgumentError" do
      assert_raise ArgumentError, fn ->
        Subject.build(["akira", [true]])
      end
    end
  end

  describe "build/2" do
    test "when two strings are given, builds a new string" do
      assert Subject.build("akira", "hamasaki") == "akirahamasaki"
    end

    test "when non string values are given, builds a new string" do
      assert Subject.build(:akira, 'hamasaki') == "akirahamasaki"
    end

    test "when a value that cannot be converted to string is given, " <>
           "raises Protocol.UndefinedError" do
      assert_raise Protocol.UndefinedError, fn ->
        Subject.build("akira", %{})
      end
    end

    test "when a list that cannot be converted to string is given, " <>
           "raises ArgumentError" do
      assert_raise ArgumentError, fn ->
        Subject.build("akira", [true])
      end
    end
  end

  describe "build/3" do
    test "when three strings are given, builds a new string" do
      assert Subject.build("akira", "hamasaki", "123") == "akirahamasaki123"
    end

    test "when non string values are given, builds a new string" do
      assert Subject.build(:akira, 'hamasaki', 123) == "akirahamasaki123"
    end

    test "when a value that cannot be converted to string is given, " <>
           "raises Protocol.UndefinedError" do
      assert_raise Protocol.UndefinedError, fn ->
        Subject.build("akira", "hamasaki", %{})
      end
    end

    test "when a list that cannot be converted to string is given, " <>
           "raises ArgumentError" do
      assert_raise ArgumentError, fn ->
        Subject.build("akira", "hamasaki", [true])
      end
    end
  end

  describe "build/4" do
    test "when four strings are given, builds a new string" do
      assert Subject.build("akira", "hamasaki", "123", "pim") == "akirahamasaki123pim"
    end

    test "when non string values are given, builds a new string" do
      assert Subject.build(:akira, 'hamasaki', 123, [112, 105, 109]) == "akirahamasaki123pim"
    end

    test "when a value that cannot be converted to string is given, " <>
           "raises Protocol.UndefinedError" do
      assert_raise Protocol.UndefinedError, fn ->
        Subject.build("akira", "hamasaki", "123", %{})
      end
    end

    test "when a list that cannot be converted to string is given, " <>
           "raises ArgumentError" do
      assert_raise ArgumentError, fn ->
        Subject.build("akira", "hamasaki", "123", [true])
      end
    end
  end

  describe "build/5" do
    test "when five strings are given, builds a new string" do
      assert Subject.build("akira", "hamasaki", "123", "pim", "2010-09-01") ==
               "akirahamasaki123pim2010-09-01"
    end

    test "when non string values are given, builds a new string" do
      assert Subject.build(:akira, 'hamasaki', 123, [112, 105, 109], ~D[2010-09-01]) ==
               "akirahamasaki123pim2010-09-01"
    end

    test "when a value that cannot be converted to string is given, " <>
           "raises Protocol.UndefinedError" do
      assert_raise Protocol.UndefinedError, fn ->
        Subject.build("akira", "hamasaki", "123", "pim", %{})
      end
    end

    test "when a list that cannot be converted to string is given, " <>
           "raises ArgumentError" do
      assert_raise ArgumentError, fn ->
        Subject.build("akira", "hamasaki", "123", "pim", [true])
      end
    end
  end
end
