defmodule Liquid.NimbleParser do
  @moduledoc """
  Transform a valid liquid markup in an AST to be executed by `render`
  """
  import NimbleParsec

  alias Liquid.Combinators.{General, LexicalToken}

  alias Liquid.Combinators.Tags.{
    Assign,
    Comment,
    Decrement,
    Increment,
    Include,
    Raw,
    Cycle,
    If,
    For,
    Tablerow,
    Case,
    Capture,
    Ifchanged,
    Custom
  }

  @type t :: [
          Assign.t()
          | Capture.t()
          | Increment.t()
          | Decrement.t()
          | Include.t()
          | Cycle.t()
          | Raw.t()
          | Comment.t()
          | For.t()
          | If.t()
          | Unless.t()
          | Tablerow.t()
          | Case.t()
          | Ifchanged.t()
          | Custom.t()
          | General.liquid_variable()
          | String.t()
        ]

  defparsec(:liquid_variable, General.liquid_variable())
  defparsec(:variable_definition, General.variable_definition())
  defparsec(:variable_name, General.variable_name())
  defparsec(:quoted_variable_name, General.quoted_variable_name())
  defparsec(:variable_definition_for_assignment, General.variable_definition_for_assignment())
  defparsec(:variable_name_for_assignment, General.variable_name_for_assignment())
  defparsec(:start_tag, General.start_tag())
  defparsec(:end_tag, General.end_tag())
  defparsec(:start_variable, General.start_variable())
  defparsec(:end_variable, General.end_variable())
  defparsec(:filter_param, General.filter_param())
  defparsec(:filter, General.filter())
  defparsec(:filters, General.filters())
  defparsec(:single_quoted_token, General.single_quoted_token())
  defparsec(:double_quoted_token, General.double_quoted_token())
  defparsec(:quoted_token, General.quoted_token())
  defparsec(:comparison_operators, General.comparison_operators())
  defparsec(:logical_operators, General.logical_operators())
  defparsec(:ignore_whitespaces, General.ignore_whitespaces())
  defparsec(:condition, General.condition())
  defparsec(:logical_condition, General.logical_condition())

  defparsec(:null_value, LexicalToken.null_value())
  defparsec(:number, LexicalToken.number())
  defparsec(:value_definition, LexicalToken.value_definition())
  defparsec(:value, LexicalToken.value())
  defparsec(:object_property, LexicalToken.object_property())
  defparsec(:boolean_value, LexicalToken.boolean_value())
  defparsec(:string_value, LexicalToken.string_value())
  defparsec(:object_value, LexicalToken.object_value())
  defparsec(:variable_value, LexicalToken.variable_value())
  defparsec(:variable_part, LexicalToken.variable_part())

  defp clean_empty_strings(_rest, args, context, _line, _offset) do
    result =
      args
      |> Enum.filter(fn e -> e != "" end)

    {result, context}
  end

  defparsec(
    :__parse__,
    General.liquid_literal()
    |> optional(choice([parsec(:liquid_tag), parsec(:liquid_variable), parsec(:custom)]))
    |> traverse({:clean_empty_strings, []})
  )

  defparsec(:assign, Assign.tag())
  defparsec(:capture, Capture.tag())
  defparsec(:decrement, Decrement.tag())
  defparsec(:increment, Increment.tag())

  defparsecp(:comment_content, Comment.comment_content())
  defparsec(:comment, Comment.tag())

  defparsec(:cycle_values, Cycle.cycle_values())
  defparsec(:cycle, Cycle.tag())

  defparsecp(:raw_content, Raw.raw_content())
  defparsec(:raw, Raw.tag())

  defparsec(:ifchanged, Ifchanged.tag())

  defparsec(:include, Include.tag())

  defparsec(:body_elsif, If.body_elsif())
  defparsec(:if, If.tag())
  defparsec(:elsif_tag, If.elsif_tag())
  defparsec(:unless, If.unless_tag())

  defparsec(:break_tag, For.break_tag())
  defparsec(:continue_tag, For.continue_tag())
  defparsec(:for, For.tag())

  defparsec(:tablerow, Tablerow.tag())

  defparsec(:case, Case.tag())
  defparsec(:clauses, Case.clauses())

  defparsec(
    :liquid_tag,
    choice([
      parsec(:assign),
      parsec(:capture),
      parsec(:increment),
      parsec(:decrement),
      parsec(:include),
      parsec(:cycle),
      parsec(:raw),
      parsec(:comment),
      parsec(:for),
      parsec(:break_tag),
      parsec(:continue_tag),
      parsec(:if),
      parsec(:unless),
      parsec(:tablerow),
      parsec(:case),
      parsec(:ifchanged)
    ])
  )

  defparsec(:custom, Custom.tag())

  @doc """
  Validates and parse liquid markup
  """
  @spec parse(String.t()) :: {:ok | :error, any()}
  def parse(markup) do
    case __parse__(markup) do
      {:ok, template, "", _, _, _} ->
        {:ok, template}

      {:ok, _, rest, _, _, _} ->
        {:error, "Error parsing: #{rest}"}
    end
  end
end
