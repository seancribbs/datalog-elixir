defmodule Datalog.Atom do
  alias __MODULE__
  defstruct [:predsym, :terms]

  @type t :: %Atom{
          predsym: String.t(),
          terms: [Datalog.dterm()]
        }

  @spec vars(t()) :: MapSet.t(Datalog.variable())
  def vars(%Atom{terms: terms}) do
    terms
    |> Keyword.take([:var])
    |> MapSet.new()
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%@for{predsym: s, terms: terms}, opts) do
      concat([
        s,
        container_doc(
          "(",
          terms,
          ")",
          opts,
          fn
            {:var, v}, _ ->
              v

            {:sym, s}, _ ->
              @protocol.inspect(s, opts)
          end,
          separator: ","
        )
      ])
    end
  end
end
