defmodule Datalog.Example do
  alias Datalog.{Atom, Rule}

  @spec ancestor() :: Datalog.program()
  def ancestor do
    Enum.map(
      [
        {"Andrew Rice", "Mistral Contrastin"},
        {"Dominic Orchard", "Mistral Contrastin"},
        {"Andy Hopper", "Andrew Rice"},
        {"Alan Mycroft", "Dominic Orchard"},
        {"David Wheeler", "Andy Hopper"},
        {"Rod Burstall", "Alan Mycroft"},
        {"Robin Milner", "Alan Mycroft"}
      ],
      &%Rule{head: %Atom{predsym: "adviser", terms: [{:sym, elem(&1, 0)}, {:sym, elem(&1, 1)}]}}
    ) ++
      [
        %Rule{
          head: %Atom{predsym: "academicAncestor", terms: [{:var, "X"}, {:var, "Y"}]},
          body: [
            %Atom{predsym: "adviser", terms: [{:var, "X"}, {:var, "Y"}]}
          ]
        },
        %Rule{
          head: %Atom{predsym: "academicAncestor", terms: [{:var, "X"}, {:var, "Z"}]},
          body: [
            %Atom{predsym: "adviser", terms: [{:var, "X"}, {:var, "Y"}]},
            %Atom{predsym: "academicAncestor", terms: [{:var, "Y"}, {:var, "Z"}]}
          ]
        }
      ] ++
      [
        %Rule{
          head: %Atom{predsym: "query1", terms: [{:var, "Intermediate"}]},
          body: [
            %Atom{
              predsym: "academicAncestor",
              terms: [{:sym, "Robin Milner"}, {:var, "Intermediate"}]
            },
            %Atom{
              predsym: "academicAncestor",
              terms: [{:var, "Intermediate"}, {:sym, "Mistral Contrastin"}]
            }
          ]
        },
        %Rule{
          head: %Atom{predsym: "query2", terms: []},
          body: [
            %Atom{
              predsym: "academicAncestor",
              terms: [{:sym, "Alan Turing"}, {:sym, "Mistral Contrastin"}]
            }
          ]
        },
        %Rule{
          head: %Atom{predsym: "query3", terms: []},
          body: [
            %Atom{
              predsym: "academicAncestor",
              terms: [{:sym, "David Wheeler"}, {:sym, "Mistral Contrastin"}]
            }
          ]
        }
      ]
  end
end
