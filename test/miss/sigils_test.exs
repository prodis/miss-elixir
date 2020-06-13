defmodule Miss.SigilsTest do
  use ExUnit.Case, async: true

  alias Miss.Sigils, as: Subject

  import Subject
  doctest Subject

  describe "~w" do
    test "generates a list of atoms with escaping and interpolation" do
      atoms_a = ~a(akira hamasaki#{11} \x26 123)
      atoms_A = ~A(akira hamasaki#{11} \x26 123)

      IO.inspect(atoms_a, label: "a")
      IO.inspect(atoms_A, label: "A")

      # assert atoms == [:akira, :hamasaki11, :&, :"123"]
    end
  end
end
