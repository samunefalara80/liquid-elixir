defmodule Liquid.ParserTest do
  use ExUnit.Case
  import Liquid.Helpers

  test "only literal" do
    test_parse("Hello", ["Hello"])
  end

  test "liquid variable" do
    test_parse("{{ X }}", [liquid_variable: [variable: [parts: [part: "X"]]]])
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
      [{:capture, [variable_name: "variable", body: []]}]
    )
  end

  test "literal left, right and inside block" do
    test_parse(
      "Hello{% capture variable %}World{% endcapture %}Here",
      ["Hello", {:capture, [variable_name: "variable", body: ["World"]]}, "Here"]
    )
  end

  test "multiple closed tags" do
    test_parse(
      "Open{% capture first_variable %}Hey{% endcapture %}{% capture second_variable %}Hello{% endcapture %}{% capture last_variable %}{% endcapture %}Close",
      ["Open", {:capture, [variable_name: "first_variable", body: ["Hey"]]}, {:capture, [variable_name: "second_variable", body: ["Hello"]]}, {:capture, [variable_name: "last_variable", body: []]}, "Close"]
    )
  end

  test "tag inside block" do
    test_parse(
      "{% capture x %}{% decrement x %}{% endcapture %}",
      [{:capture, [variable_name: "x", body: [{:decrement, [variable: [parts: [part: "x"]]]}]]}]
    )
  end

  test "literal and tag inside block" do
    test_parse(
      "{% capture x %}X{% decrement x %}{% endcapture %}",
      [{:capture, [variable_name: "x", body: ["X", {:decrement, [variable: [parts: [part: "x"]]]}]]}]
    )
  end

  test "two tags inside block" do
    test_parse(
      "{% capture x %}{% decrement x %}{% decrement x %}{% endcapture %}",
      [{:capture, [variable_name: "x", body: [{:decrement, [variable: [parts: [part: "x"]]]}, {:decrement, [variable: [parts: [part: "x"]]]}]]}]
    )
  end

  test "variable inside block" do
    test_parse(
      "{% capture x %}{% increment x %}{% endcapture %}{% capture y %}{% endcapture %}",
      [{:capture, [variable_name: "x", body: [{:liquid_variable, [variable: [parts: [part: "x"]]]}]]}]
    )
  end

  test "nested closed tags" do
    test_parse(
      "{% capture variable %}{% capture internal_variable %}{% endcapture %}{% endcapture %}",
      [{:capture, [variable_name: "variable", body: ["Hello"]]}]
    )
  end
end