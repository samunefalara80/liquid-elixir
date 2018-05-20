defmodule Liquid.Combinators.Tags.Unless do
  import NimbleParsec

  @doc "Open if tag: {% if variable ==  value %}"

  def open_tag do
    empty()
    |> parsec(:start_tag)
    |> ignore(string("unless"))
    |> concat(parsec(:ignore_whitespaces))
    |> choice([
      parsec(:conditions),
      parsec(:variable_definition),
      parsec(:value_definition),
      parsec(:token)
    ])
    |> optional(times(parsec(:logical_conditions), min: 1))
    |> concat(parsec(:end_tag))
    |> concat(parsec(:output_text))
  end

  @doc "Close if tag: {% endif %}"
  def close_tag do
    parsec(:start_tag)
    |> ignore(string("endunless"))
    |> concat(parsec(:end_tag))
  end

  def tag do
    empty()
    |> parsec(:open_tag_unless)
    |> concat(parsec(:if_content))
    |> parsec(:close_tag_unless)
    |> tag(:unless)
    |> optional(parsec(:__parse__))
  end
end