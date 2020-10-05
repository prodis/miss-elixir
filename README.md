# Miss Elixir

Some functions that ***I miss*** in Elixir core (and maybe you too).

<img height="300" src="https://raw.githubusercontent.com/prodis/miss-elixir/master/misc/miss-elixir-logo.jpg" alt="Miss Elixir">

---

[![Hex.pm](https://img.shields.io/hexpm/v/miss.svg)](https://hex.pm/packages/miss)
[![Docs](https://img.shields.io/badge/hex-docs-542581.svg)](https://hexdocs.pm/miss)
[![Build Status](https://travis-ci.org/prodis/miss-elixir.svg?branch=master)](https://travis-ci.org/prodis/miss-elixir)
[![Coverage Status](https://coveralls.io/repos/github/prodis/miss-elixir/badge.svg?branch=master)](https://coveralls.io/github/prodis/miss-elixir?branch=master)
[![License](https://img.shields.io/hexpm/l/miss.svg)](https://github.com/prodis/miss-elixir/blob/master/LICENSE)

*Miss Elixir* library brings in a non-intrusive way some extra functions that, for different reasons, are not part of the Elixir
core.

None of the functions in *Miss Elixir* has the same name of functions present in the correspondent Elixir module.

Read about the motivation to create this Elixir library in [this blog post](https://fernandohamasaki.com/miss-elixir).

## Installation

The package can be installed by adding `miss` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:miss, "~> 0.1.0"}
  ]
end
```

## Usage

The order of the `Miss` namespace preceding the existing Elixir modules to be extended was made by intention. For example,
`Miss.String`.

The modules in *Miss Elixir* are not intended to be used with aliases. Always use the entire namespace to make explicit that
module/function does not belong to Elixir core.

```elixir
# Do not do that!
alias Miss.Kernel
Kernel.div_rem(10, 2)

# Instead, use like that:
Miss.Kernel.div_rem(10, 2)
```

> Navigate in the [documentation of each module](https://hexdocs.pm/miss/api-reference.html) to find out all the available
> functions and detailed examples.

Below there are some examples.

### String

```elixir
iex> Miss.String.build(["string", 123, true])
"string123true"

iex> Miss.String.build("What ", "do you", " miss?")
"What do you miss?"
```

### Map

```elixir
iex> Miss.Map.rename_key(%{a: 1, b: 2, c: 3}, :b, :bbb)
%{a: 1, bbb: 2, c: 3}

iex> defmodule Post do
...>   defstruct [:title, :text, :date, :author, comments: []]
...>  end
...>
...>  defmodule Author do
...>    defstruct [:id, :name]
...>  end
...>
...>  defmodule Comment do
...>    defstruct [:text]
...>  end
...>
...> post = %Post{
...>   title: "My post",
...>   text: "Something really interesting",
...>   date: ~D[2010-09-01],
...>   author: %Author{
...>     id: 1234,
...>     name: "Pedro Bonamides"
...>   },
...>   comments: [
...>     %Comment{text: "Comment one"},
...>     %Comment{text: "Comment two"}
...>   ]
...> }
...> Miss.Map.from_nested_struct(post, [{Date, :skip}])
%{
  title: "My post",
  text: "Something really interesting",
  date: ~D[2010-09-01],
  author: %{
    id: 1234,
    name: "Pedro Bonamides"
  },
  comments: [
    %{text: "Comment one"},
    %{text: "Comment two"}
  ]
}
```

### Kernel

```elixir
iex> Miss.Kernel.div_rem(45, 2)
{22, 1}

iex> defmodule User do
...>   defstruct name: "User"
...> end
...>
...> Miss.Kernel.struct_list(User, [%{name: "Akira"}, %{name: "Fernando"}])
[%User{name: "Akira"}, %User{name: "Fernando"}]
```

### List

```elixir
iex> Miss.List.intersection([1, 2, 3, 4, 5], [0, 2, 4, 6, 8])
[2, 4]
```

## Full documentation

The full documentation is available at [https://hexdocs.pm/miss](https://hexdocs.pm/miss).

## Contributing

See the [contributing guide](https://github.com/prodis/miss-elixir/blob/master/CONTRIBUTING.md).

## License

*Miss Elixir* is released under the Apache 2.0 License. See the [LICENSE](https://github.com/prodis/miss-elixir/blob/master/LICENSE) file.

Copyright © 2020 Fernando Hamasaki de Amorim

## Author

[Fernando Hamasaki de Amorim (prodis)](https://github.com/prodis)

![Prodis](https://camo.githubusercontent.com/c01a3ebca1c000d7586a998bb07316c8cb784ce5/687474703a2f2f70726f6469732e6e65742e62722f696d616765732f70726f6469735f3135302e676966)
