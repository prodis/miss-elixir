defmodule Miss.Sigils do
  @moduledoc ~S"""
  Additional sigils.

  ## List of atoms

  The `~a` and `~A` sigils are used to generate lists of atoms separated by whitespace.
  * `~w` Generates a list of atoms **with** escaping and interpolation
  * `~W` Generates a list of atoms **with no** escaping or interpolation

  ## Examples

      iex> import Miss.Sigils
      ...> ~a(akira hamasaki#{11} \x26 123)
      [:akira, :hamasaki11, :&, :"123"]

      iex> import Miss.Sigils
      ...>
      ...> ~A(akira hamasaki#{11} \x26 123)
      [:akira, :hamasaki11, :&, :"123"]

  """

  @doc """
  Handles the sigil `~a` for list of atoms.

  It returns a list of atoms split by whitespace. Character unescaping and interpolation happens for each atom.

  ## Examples

      iex> import Miss.Sigils
      ...>
      ...> ~a(akira hamasaki#{11} \x26 123)
      [:akira, :hamasaki11, :&, :"123"]

  """
  @spec sigil_a(String.t(), []) :: [atom()]
  # def sigil_a(string, _modifiers), do: to_list_of_atoms(string)
  def sigil_a(string, _modifiers), do: ~w(#{string})a

  @doc ~S"""
  Handles the sigil `~a` for list of atoms.

  It returns a list of atoms split by whitespace. Character unescaping and interpolation happens for each atom.

  ## Examples

      iex> import Miss.Sigils
      ...>
      ...> some_number = 11
      ...> ~A(akira hamasaki#{11} \x26 123)
      [:akira, :hamasaki11, :"\\x26", :"123"]

  """
  @spec sigil_A(String.t(), []) :: [atom()]
  def sigil_A(string, _modifiers), do: to_list_of_atoms(string)

  @spec to_list_of_atoms(String.t()) :: [atom()]
  defp to_list_of_atoms(string) when is_binary(string) do
    string
    |> IO.inspect()
    |> String.split()
    |> Enum.map(&String.to_atom/1)
  end
end
