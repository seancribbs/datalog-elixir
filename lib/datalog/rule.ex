defmodule Datalog.Rule do
  alias __MODULE__
  defstruct head: nil, body: []

  @type t :: %Rule{
          head: Datalog.Atom.t(),
          body: [Datalog.Atom.t()]
        }

  @spec is_range_restricted?(t()) :: boolean()
  def is_range_restricted?(%Rule{head: head, body: body}) do
    body_vars = Enum.reduce(body, MapSet.new(), &Enum.into(&2, Datalog.Atom.vars(&1)))

    head
    |> Datalog.Atom.vars()
    |> MapSet.subset?(body_vars)
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{head: h, body: []}, opts) do
      concat([@protocol.inspect(h, opts), "."])
    end

    def inspect(%@for{head: h, body: b}, opts) do
      concat([
        @protocol.inspect(h, opts),
        " :- ",
        container_doc("", b, ".", opts, &@protocol.inspect/2, separator: ",")
      ])
    end
  end
end
