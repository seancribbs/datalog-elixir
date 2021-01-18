defmodule Datalog do
  alias Datalog.{Rule, Atom}
  @type program :: [Rule.t()]
  @type variable :: {:var, String.t()}
  @type sym :: {:sym, any()}
  @type dterm :: variable() | sym()
  @type knowledgebase :: [Atom.t()]
  @type substitution :: [{dterm, dterm}]

  @spec query(String.t(), program()) :: [substitution()]
  def query(predsym, program) do
    program
    |> Enum.filter(&(&1.head.predsym == predsym))
    |> Enum.map(& &1.head.terms)
    |> case do
      [query_vars] ->
        program
        |> solve()
        |> Enum.filter(&(&1.predsym == predsym))
        |> Enum.map(& &1.terms)
        |> Enum.map(&Enum.zip(query_vars, &1))

      [] ->
        raise "The query '#{predsym}' doesn't exist."

      _ ->
        raise "The query '#{predsym}' has multiple clauses."
    end
  end

  @empty []

  @spec solve(program) :: knowledgebase()
  def solve(rules) do
    if Enum.all?(rules, &Rule.is_range_restricted?/1) do
      step(rules, [])
    end
  end

  defp step(rules, current_kb) do
    case immediate_consequence(rules, current_kb) do
      ^current_kb ->
        current_kb

      next_kb ->
        step(rules, next_kb)
    end
  end

  @spec immediate_consequence(program(), knowledgebase()) :: knowledgebase()
  def immediate_consequence(rules, kb) do
    new_knowledge =
      rules
      |> Enum.map(&eval_rule(kb, &1))
      |> Enum.concat()

    Enum.uniq(kb ++ new_knowledge)
  end

  @spec eval_rule(knowledgebase(), Rule.t()) :: knowledgebase()
  def eval_rule(kb, %Rule{head: head, body: body}) do
    Enum.map(walk(kb, body), &substitute(head, &1))
  end

  @spec walk(knowledgebase, [Atom.t()]) :: [substitution()]
  def walk(kb, atoms) do
    List.foldr(atoms, [@empty], &eval_atom(kb, &1, &2))
  end

  @spec eval_atom(knowledgebase(), Atom.t(), [substitution()]) :: [substitution()]
  def eval_atom(kb, atom, substitutions) when is_list(substitutions) do
    for substitution <- substitutions do
      down_to_earth_atom = substitute(atom, substitution)

      for extension <- map_maybe(kb, &unify(down_to_earth_atom, &1)) do
        substitution ++ extension
      end
    end
    |> Enum.concat()
  end

  @spec substitute(Atom.t(), substitution()) :: Atom.t()
  def substitute(%Atom{terms: terms} = atom, substitution) when is_list(substitution) do
    subterms =
      Enum.map(terms, fn
        {:var, _v} = var ->
          case List.keyfind(substitution, var, 0) do
            nil -> var
            {^var, sub} -> sub
          end

        sym ->
          sym
      end)

    %{atom | terms: subterms}
  end

  @spec unify(Atom.t(), Atom.t()) :: {:ok, substitution} | nil
  def unify(%Atom{predsym: p, terms: t1}, %Atom{predsym: p, terms: t2})
      when length(t1) == length(t2) do
    unify(Enum.zip(t1, t2))
  end

  def unify(_, _) do
    nil
  end

  defp unify([]) do
    {:ok, @empty}
  end

  defp unify([{{:sym, s}, {:sym, s}} | rest]) do
    unify(rest)
  end

  defp unify([{{:sym, _}, {:sym, _}} | _]) do
    nil
  end

  defp unify([{{:var, _} = v, {:sym, s}} = pair | rest]) do
    with {:ok, incomplete_substitution} <- unify(rest) do
      case List.keyfind(incomplete_substitution, v, 0) do
        {:sym, s1} when s1 != s ->
          nil

        _ ->
          {:ok, [pair | incomplete_substitution]}
      end
    end
  end

  defp unify([{_, {:var, _}} = pair | _rest]) do
    raise "The second atom is assumed to be ground: #{inspect(pair)}"
  end

  ## Some things from haskell we don't have in elixir
  defp map_maybe([], _f) do
    []
  end

  defp map_maybe([i | rest], f) do
    case f.(i) do
      {:ok, thing} ->
        [thing | map_maybe(rest, f)]

      nil ->
        map_maybe(rest, f)
    end
  end
end
