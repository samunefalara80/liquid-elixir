Code.require_file "../../test_helper.exs", __ENV__.file

defmodule Liquescent.CaptureTest do
  use ExUnit.Case

  setup_all do
    Liquescent.start
    on_exit fn -> Liquescent.stop end
    :ok
  end

  test :test_captures_block_content_in_variable do
    assert_template_result("test string", "{% capture 'var' %}test string{% endcapture %}{{var}}", {})
  end

  test :test_capture_with_hyphen_in_variable_name do
    template_source = """
    {% capture this-thing %}Print this-thing{% endcapture %}
    {{ this-thing }}
    """
    template = Template.parse(template_source)
    rendered = template.render(template)
    assert "Print this-thing" == rendered |> String.strip
  end

  test :test_capture_to_variable_from_outer_scope_if_existing do
    template_source = """
    {% assign var = '' %}
    {% if true %}
    {% capture var %}first-block-string{% endcapture %}
    {% endif %}
    {% if true %}
    {% capture var %}test-string{% endcapture %}
    {% endif %}
    {{var}}
    """
    template = Template.parse(template_source)
    rendered = template.render(template)
    assert "test-string" == Regex.replace(~r/\s/, rendered, "")
  end

  test :test_assigning_from_capture do
    template_source = """
    {% assign first = '' %}
    {% assign second = '' %}
    {% for number in (1..3) %}
    {% capture first %}{{number}}{% endcapture %}
    {% assign second = first %}
    {% endfor %}
    {{ first }}-{{ second }}
    """
    template = Template.parse(template_source)
    rendered = template.render(template)
    assert "3-3" == Regex.replace(~r/\s/, rendered, "")
  end

  defp assert_template_result(expected, markup) do
    assert_result(expected, markup, [])
  end

  defp assert_template_result(expected, markup, assigns) do
    assert_result(expected,markup,assigns)
  end

  defp assert_result(expected, markup, assigns) do
    template = Liquescent.Templates.parse(markup)
    { :ok, result, _ } = Liquescent.Templates.render(template, assigns)
    assert result == expected
  end
end
