defmodule TwoFer do
  @moduledoc false

  @doc """
  Two-fer or 2-fer is short for two for one. One for you and one for me.

  Using a tab like this 	 or like this \t in a @doc is allowed.
  """
  @spec two_fer(String.t()) :: String.t()
  def two_fer(name \\ "you") when is_binary(name) do
    "One for #{name}, one for me."
  end
end








