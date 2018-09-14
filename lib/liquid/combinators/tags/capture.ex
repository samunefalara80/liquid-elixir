defmodule Liquid.Combinators.Tags.Capture do
  @moduledoc """
  Stores the result of a block into a variable without rendering it in place.
  ```
    {% capture heading %}
      Monkeys!
    {% endcapture %}
    ...
    <h1>{{ heading }}</h1> <!-- then you can use the `heading` variable -->
  ```
  Capture is useful for saving content for use later in your template, such as in a sidebar or footer.
  """
  import NimbleParsec
  alias Liquid.Combinators.Tag

  @type t :: [capture: Capture.markup()]

  @type markup :: [
          variable_name: String.t(),
          parts: Liquid.NimbleParser.t()
        ]

  @doc """
  Parses a `Liquid` Capture tag, creates a Keyword list where the key is the name of the tag
  (capture in this case) and the value is another keyword list which represent the internal
  structure of the tag.
  """
  @spec tag() :: NimbleParsec.t()
  def tag do
    Tag.define_closed(
      "capture",
      fn combinator ->
        choice(combinator, [
          parsec(:quoted_variable_name),
          parsec(:variable_name)
        ])
      end,
      fn combinator -> optional(combinator, parsec(:__parse__) |> tag(:parts)) end
    )
  end

  def tag2 do
    Tag.define_open(
      "capture",
      fn combinator ->
        choice(combinator, [
              parsec(:quoted_variable_name),
              parsec(:variable_name)
            ])
      end
    )
    |> traverse({__MODULE__, :store_tag_in_context, []})
  end

  def store_tag_in_context(_rest, tag, %{tags: tags} = context, _line, _offset) do
    tag_name = tag |> Keyword.keys() |> hd()
    {[block: tag], %{context | tags: [tag_name | tags]}}
    {[block: tag], context}
  end
end
