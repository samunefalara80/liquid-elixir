defmodule Liquid.ParserTest do
  use ExUnit.Case
  import Liquid.Helpers

  test "only literal" do
    test_parse("Hello", ["Hello"])
  end

  test "test liquid open tag" do
    test_parse("{% assign a = 5 %}", assign: [variable_name: "a", value: 5])
  end

  test "test literal + liquid open tag" do
    test_parse(
      "Hello {% assign a = 5 %}",
      ["Hello ", {:assign, [variable_name: "a", value: 5]}]
    )
  end

  test "test liquid open tag + literal" do
    test_parse(
      "{% assign a = 5 %} Hello",
      [{:assign, [variable_name: "a", value: 5]}, " Hello"]
    )
  end

  test "test literal + liquid open tag + literal" do
    test_parse(
      "Hello {% assign a = 5 %} Hello",
      ["Hello ", {:assign, [variable_name: "a", value: 5]}, " Hello"]
    )
  end

  test "test multiple open tags" do
    test_parse(
      "{% assign a = 5 %}{% increment a %}",
      [{:assign, [variable_name: "a", value: 5]}, {:increment, [variable: [parts: [part: "a"]]]}]
    )
  end

  test "unclosed block must fails" do
    test_combinator_error(
      "{% capture variable %}"
    )
  end

  test "empty closed tag" do
    test_parse(
      "{% capture variable %}{% endcapture %}",
      [{:capture, [body: [], variable_name: "variable"]}]
    )
  end

  @tag :skip
  test "literal left, right and inside block" do
    test_parse(
      "Hello{% capture variable %}World{% endcapture %}Here",
      ["Hello", {:capture, [body: ["World"], variable_name: "variable"]}, "Here"]
    )
  end

  @tag :skip
  test "multiple closed tags" do
    test_parse(
      "{% capture first_variable %}{% endcapture %}{% capture last_variable %}{% endcapture %}",
      [{:capture, [body: [], variable_name: "first_variable"]}, {:capture, [body: [], variable_name: "last_variable"]}]
    )
  end

  # test "nested closed tags" do
  #   test_parse(
  #     "{% capture variable %}{% capture internal_variable %}{% endcapture %}{% endcapture %}",
  #     [{:capture, [body: ["Hello"], variable_name: "variable"]}]
  #   )
  # end
end
