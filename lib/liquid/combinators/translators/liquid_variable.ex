defmodule Liquid.Combinators.Translators.LiquidVariable do
  alias Liquid.Combinators.Translators.General

  def translate(variable: [parts: variable_list]) do
    parts = General.variable_in_parts_neded(variable_list)
    variable_name = General.variable_to_string(parts)
    %Liquid.Variable{name: variable_name, parts: parts}
  end

  def translate(variable: [parts: variable_list, filters: filters]) do
    parts = General.variable_in_parts_neded(variable_list)
    variable_name = General.variable_to_string(parts)
    filters_markup = transform_filters(filters)
    %Liquid.Variable{name: variable_name, parts: parts, filters: filters_markup}
  end

  def translate([value, filters: filters]) do
    filters_markup = transform_filters(filters)

    case is_bitstring(value) do
      true ->
        %Liquid.Variable{name: "'#{value}'", filters: filters_markup, literal: "#{value}"}

      false ->
        %Liquid.Variable{name: "#{value}", filters: filters_markup, literal: value}
    end
  end

  def translate([value]) do
    case is_bitstring(value) do
      true ->
        %Liquid.Variable{name: "#{value}", literal: "#{value}"}

      false ->
        %Liquid.Variable{name: "#{value}", literal: value}
    end
  end

  defp transform_filters(filters_list) do
    Keyword.get_values(filters_list, :filter)
    |> Enum.map(&filters_to_list/1)
  end

  defp filters_to_list([filter_name]) do
    [String.to_atom(filter_name), []]
  end

  defp filters_to_list([filter_name, filter_param]) do
    {_, param_value} = filter_param

    value = Keyword.get_values(param_value, :value)

    filter_param_to_string =
      case value do
        [variable: [parts: parts]] ->
          filter_param_value = General.variable_in_parts(parts) |> General.variable_to_string()

          [String.to_atom(filter_name), [filter_param_value]]

        any ->
          if length(value) > 1 do
            filter_param_value = Enum.map(value, fn x -> to_string(x) end)
            [String.to_atom(filter_name), filter_param_value]
          else
            [filter_param_value] = value

            case is_bitstring(filter_param_value) do
              true ->
                [String.to_atom(filter_name), ["'#{filter_param_value}'"]]

              false ->
                [String.to_atom(filter_name), ["#{filter_param_value}"]]
            end
          end
      end
  end
end
