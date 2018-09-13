defmodule Liquid.Combinators.Tags.Case do
  @moduledoc """
  Creates a switch statement to compare a variable against different values.
  `case` initializes the switch statement, and `when` compares its values.
  Input:
  ```
    {% assign handle = 'cake' %}
    {% case handle %}
    {% when 'cake' %}
      This is a cake
    {% when 'cookie' %}
      This is a cookie
    {% else %}
      This is not a cake nor a cookie
    {% endcase %}
  ```
  Output:
  ```
    This is a cake
  ```
  """
  import NimbleParsec
  alias Liquid.Combinators.{Tag, General}
  alias Liquid.Combinators.Tags.Generic

  @type t :: [case: Case.markup()]

  @type markup :: [
          variable: LexicalToken.value(),
          clauses: [
            String.t()
            | [
                when: [
                  conditions: [LexicalToken.value() | {:logical, [or: LexicalToken.value()]}],
                  body: Liquid.NimbleParser.t()
                ]
              ]
          ]
        ]

  @doc """
  Parses a `Liquid` Case tag, creates a Keyword list where the key is the name of the tag
  (case in this function) and the value is another keyword list which represents the internal
  structure of the tag.
  """
  @spec tag() :: NimbleParsec.t()
  def tag, do: Tag.define_closed("case", &General.conditions/1, &body/1)

  @doc """
  Parse When tag clauses.
  """
  @spec clauses() :: NimbleParsec.t()
  def clauses do
    empty()
    |> times(when_tag(), min: 1)
    |> tag(:clauses)
  end

  defp when_tag do
    "when"
    |> Tag.open_tag(&General.conditions/1)
    |> tag(:conditions)
    |> concat(tag(optional(parsec(:__parse__)), :body))
    |> tag(:when)
  end

  defp body(combinator) do
    combinator
    |> optional(parsec(:__parse__))
    |> optional(clauses())
    |> concat(General.ignore_whitespaces())
    |> optional(repeat(Generic.else_tag()))
  end
end
