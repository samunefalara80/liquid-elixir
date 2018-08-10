defmodule Liquid.Translators.Tags.Break do
  @moduledoc """
  Translate new AST to old AST for the break  tag, this tag is only present inside the body of the for tag
  """

  @doc """
  Takes the markup of the new AST and creates a `Liquid.Tag` struct (old AST) and fill the keys needed, this is used recursively by the For tag.
  """

  @spec translate(List.t() | String.t()) :: Tag.t()
  def translate(_markup) do
    %Liquid.Tag{name: :break}
  end
end
