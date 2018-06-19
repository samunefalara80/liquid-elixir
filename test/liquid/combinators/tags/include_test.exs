defmodule Liquid.Combinators.Tags.IncludeTest do
  use ExUnit.Case

  import Liquid.Helpers
  alias Liquid.NimbleParser, as: Parser

  test "include tag parser" do
    test_combinator(
      "{% include 'snippet', my_variable: 'apples', my_other_variable: 'oranges' %}",
      &Parser.include/1,
      include: [
        variable_name:  "snippet",
        params: [
          assignment: [variable_name: "my_variable", value: "apples"],
          assignment: [variable_name: "my_other_variable", value: "oranges"]
        ]
      ]
    )

    test_combinator(
      "{% include 'snippet' my_variable: 'apples', my_other_variable: 'oranges' %}",
      &Parser.include/1,
      include: [
        variable_name: "snippet",
        params: [
          assignment: [variable_name: "my_variable", value: "apples"],
          assignment: [variable_name: "my_other_variable", value: "oranges"]
        ]
      ]
    )

    test_combinator(
      "{% include 'pick_a_source' %}",
      &Parser.include/1,
      include: [variable_name: "pick_a_source"]
    )

    test_combinator(
      "{% include 'product' with products[0] %}",
      &Parser.include/1,
      include: [
        variable_name: "product",
        with: [
          variable: [parts: [part: "products", index: 0]]
        ]
      ]
    )

    test_combinator(
      "{% include 'product' with 'products' %}",
      &Parser.include/1,
      include: [variable_name: "product", with: ["products"]]
    )

    test_combinator(
      "{% include 'product' for 'products' %}",
      &Parser.include/1,
      include: [variable_name: "product", for: ["products"]]
    )
  end
end
