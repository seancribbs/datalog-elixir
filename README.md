# Datalog

A toy implementation of naive-evaluated Datalog in Elixir, based on the blog
post [The Essence of
Datalog](https://dodisturb.me/posts/2018-12-25-The-Essence-of-Datalog.html). The
Datalog program given the blog post is included in the `Datalog.Example** module.

**DO NOT USE THIS IN PRODUCTION, THIS IS FOR EDUCATIONAL PURPOSES ONLY.**

## Some differences from the Haskell version

* *No abstract types.* I use structs for `Rule` (`%Datalog.Rule{}`) and `Atom`
  (`%Datalog.Atom{}`), and two-tuples for the two variants of `Term`: `Var` and
  `Sym`.

* *No monadic do-notation.* In a few places, I had to unpack the implicit
  iteration and flat-mapping that monadic notation and make it explicit. The
  code looks a little strange as a result, with some `++` and `Enum.concat/1` to
  get the desired level of list-nesting. See `eval_atom/3` for an example of
  this.

* *No inline named-functions.* When the blog author uses Haskell `where` clauses
  to define local functions inside a function scope, I've substituted `for`
  comprehensions or functions of the same name but different arities. Example:
  `unify/2` takes two atoms, and `unify/1` (local function `go` in the blog
  post) works over the zipped list of terms to unify from the inputs of
  `unify/2`.

* *No free-to-use fixpoint combinator.* I have to tail-recurse, comparing the
  inputs to the outputs for equality. See `solve/1`.

* *Pretty-printed data-structures.* I wanted the `inspect` output to look like a
  Datalog program, so I implemented the `Inspect` protocol for the included
  structs.

## Executing the example

```shell
$ iex -S mix
Erlang/OTP 22 [erts-10.7.2.1] [source] [64-bit] [smp:12:12] [ds:12:12:10] [async-threads:1] [hipe]

Interactive Elixir (1.10.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> Datalog.Example.ancestor
[
  adviser("Andrew Rice", "Mistral Contrastin").,
  adviser("Dominic Orchard", "Mistral Contrastin").,
  adviser("Andy Hopper", "Andrew Rice").,
  adviser("Alan Mycroft", "Dominic Orchard").,
  adviser("David Wheeler", "Andy Hopper").,
  adviser("Rod Burstall", "Alan Mycroft").,
  adviser("Robin Milner", "Alan Mycroft").,
  academicAncestor(X, Y) :- adviser(X, Y).,
  academicAncestor(X, Z) :- adviser(X, Y), academicAncestor(Y, Z).,
  query1(Intermediate) :-
    academicAncestor("Robin Milner", Intermediate),
    academicAncestor(Intermediate, "Mistral Contrastin")
  .,
  query2() :- academicAncestor("Alan Turing", "Mistral Contrastin").,
  query3() :- academicAncestor("David Wheeler", "Mistral Contrastin").
]
iex(2)> Datalog.solve(v(1))
[
  adviser("Andrew Rice", "Mistral Contrastin"),
  adviser("Dominic Orchard", "Mistral Contrastin"),
  adviser("Andy Hopper", "Andrew Rice"),
  adviser("Alan Mycroft", "Dominic Orchard"),
  adviser("David Wheeler", "Andy Hopper"),
  adviser("Rod Burstall", "Alan Mycroft"),
  adviser("Robin Milner", "Alan Mycroft"),
  academicAncestor("Andrew Rice", "Mistral Contrastin"),
  academicAncestor("Dominic Orchard", "Mistral Contrastin"),
  academicAncestor("Andy Hopper", "Andrew Rice"),
  academicAncestor("Alan Mycroft", "Dominic Orchard"),
  academicAncestor("David Wheeler", "Andy Hopper"),
  academicAncestor("Rod Burstall", "Alan Mycroft"),
  academicAncestor("Robin Milner", "Alan Mycroft"),
  academicAncestor("Andy Hopper", "Mistral Contrastin"),
  academicAncestor("Alan Mycroft", "Mistral Contrastin"),
  academicAncestor("David Wheeler", "Andrew Rice"),
  academicAncestor("Rod Burstall", "Dominic Orchard"),
  academicAncestor("Robin Milner", "Dominic Orchard"),
  academicAncestor("David Wheeler", "Mistral Contrastin"),
  academicAncestor("Rod Burstall", "Mistral Contrastin"),
  academicAncestor("Robin Milner", "Mistral Contrastin"),
  query1("Dominic Orchard"),
  query1("Alan Mycroft"),
  query3()
]
iex(3)> Datalog.query("query1", v(1))
[
  [{{:var, "Intermediate"}, {:sym, "Dominic Orchard"}}],
  [{{:var, "Intermediate"}, {:sym, "Alan Mycroft"}}]
]
iex(4)> Datalog.query("query2", v(1))
[]
iex(5)> Datalog.query("query3", v(1))
[[]]
iex(6)>
```
