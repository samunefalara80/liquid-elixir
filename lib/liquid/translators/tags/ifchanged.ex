defmodule Liquid.Translators.Tags.Ifchanged do
  @moduledoc """
  Translate new AST to old AST for the Ifchanged tag.
  """
  alias Liquid.NimbleTranslator

  @doc """
  Takes the markup of the new AST, creates a `Liquid.Block` struct (old AST) and fill the keys needed to render a Ifchanged tag.
  """
  def translate(markup) do
    nodelist = NimbleTranslator.process_node(markup)
    %Liquid.Block{name: :ifchanged, nodelist: nodelist}
  end
end
