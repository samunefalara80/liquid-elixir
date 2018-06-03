defmodule Liquid.Combinators.Tags.TablerowTest do
  use ExUnit.Case

  import Liquid.Helpers
  alias Liquid.NimbleParser, as: Parser

  test "tablerow tag: basic tag structures" do
    tags = [
      "{% tablerow item in array %}{% endtablerow %}",
      "{%tablerow item in array%}{%endtablerow%}",
      "{%     tablerow     item    in     array    %}{%    endtablerow    %}"
    ]

    Enum.each(tags, fn tag ->
      test_combinator(
        tag,
        &Parser.tablerow/1,
        tablerow: [
          tablerow_collection: [
            variable_name: ["item"],
            value: {:variable, [parts: [part: "array"]]}
          ],
          tablerow_body: []
        ]
      )
    end)
  end

  test "tablerow tag: limit parameter" do
    tags = [
      "{% tablerow item in array limit:2 %}{% endtablerow %}",
      "{%tablerow item in array limit:2%}{%endtablerow%}",
      "{%     tablerow     item    in     array  limit:2  %}{%    endtablerow    %}",
      "{%     tablerow    item    in     array  limit: 2  %}{%    endtablerow    %}"
    ]

    Enum.each(tags, fn tag ->
      test_combinator(
        tag,
        &Parser.tablerow/1,
        tablerow: [
          tablerow_collection: [
            variable_name: ["item"],
            value: {:variable, [parts: [part: "array"]]},
            limit_param: [2]
          ],
          tablerow_body: []
        ]
      )
    end)
  end

  test "tablerow tag: offset parameter" do
    tags = [
      "{% tablerow item in array offset:2 %}{% endtablerow %}",
      "{%tablerow item in array offset:2%}{%endtablerow%}",
      "{%     tablerow     item    in     array  offset:2  %}{%    endtablerow    %}"
    ]

    Enum.each(tags, fn tag ->
      test_combinator(
        tag,
        &Parser.tablerow/1,
        tablerow: [
          tablerow_collection: [
            variable_name: ["item"],
            value: {:variable, [parts: [part: "array"]]},
            offset_param: [2]
          ],
          tablerow_body: []
        ]
      )
    end)
  end

  test "tablerow tag: cols parameter" do
    tags = [
      "{% tablerow item in array cols:2 %}{% endtablerow %}",
      "{%tablerow item in array cols:2%}{%endtablerow%}",
      "{%     tablerow     item    in     array  cols:2  %}{%    endtablerow    %}"
    ]

    Enum.each(tags, fn tag ->
      test_combinator(
        tag,
        &Parser.tablerow/1,
        tablerow: [
          tablerow_collection: [
            variable_name: ["item"],
            value: {:variable, [parts: [part: "array"]]},
            cols_param: [2]
          ],
          tablerow_body: []
        ]
      )
    end)
  end

  test "tablerow tag: range parameter" do
    tags = [
      "{% tablerow i in (1..10) %}{{ i }}{% endtablerow %}",
      "{%tablerow i in (1..10)%}{{ i }}{% endtablerow %}",
      "{%     tablerow     i     in     (1..10)      %}{{ i }}{%     endtablerow     %}"
    ]

    Enum.each(tags, fn tag ->
      test_combinator(
        tag,
        &Parser.tablerow/1,
        tablerow: [
          tablerow_collection: [
            variable_name: ["i"],
            value: {:range, [start: 1, end: 10]}
          ],
          tablerow_body: [
            liquid_variable: [variable: [parts: [part: "i"]]]
          ]
        ]
      )
    end)
  end

  test "tablerow tag: range with variables" do
    test_combinator(
      "{% tablerow i in (my_var..10) %}{{ i }}{% endtablerow %}",
      &Parser.tablerow/1,
      tablerow: [
        tablerow_collection: [
          variable_name: ["i"],
          value:
            {:range,
             [
               start: {:variable, [parts: [part: "my_var"]]},
               end: 10
             ]}
        ],
        tablerow_body: [
          liquid_variable: [variable: [parts: [part: "i"]]]
        ]
      ]
    )
  end

  test "tablerow tag: call with 2 parameters" do
    test_combinator(
      "{% tablerow i in (my_var..10) limit:2 cols:2 %}{{ i }}{% endtablerow %}",
      &Parser.tablerow/1,
      tablerow: [
        tablerow_collection: [
          variable_name: ["i"],
          value:
            {:range,
             [
               start: {:variable, [parts: [part: "my_var"]]},
               end: 10
             ]},
          limit_param: [2],
          cols_param: [2]
        ],
        tablerow_body: [
          liquid_variable: [variable: [parts: [part: "i"]]]
        ]
      ]
    )
  end

  test "tablerow tag: invalid tag structure and variable values" do
    test_combinator_error(
      "{% tablerow i in (my_var..10) %}{{ i }}{% else %}{% else %}{% endtablerow %}",
      &Parser.tablerow/1
    )

    test_combinator_error(
      "{% tablerow i in (my_var..product.title[2]) %}{{ i }}{% else %}{% endtablerow %}",
      &Parser.tablerow/1
    )

    test_combinator_error(
      "{% tablerow i in products limit: a %}{{ i }}{% else %}{% endtablerow %}",
      &Parser.tablerow/1
    )
  end
end
