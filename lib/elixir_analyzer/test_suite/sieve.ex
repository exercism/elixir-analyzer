defmodule ElixirAnalyzer.TestSuite.Sieve do
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Sieve
  """

  use ElixirAnalyzer.ExerciseTest
  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Source

  assert_no_call "does not call rem/2" do
    type :essential
    comment Constants.sieve_do_not_use_div_rem()
    called_fn module: Kernel, name: :rem
  end

  assert_no_call "does not call div/2" do
    type :essential
    comment Constants.sieve_do_not_use_div_rem()
    called_fn module: Kernel, name: :div
  end

  check_source "does not call Kernel.//2" do
    type :essential
    comment Constants.sieve_do_not_use_div_rem()

    check(%Source{code_ast: code_ast}) do
      {_, acc} =
        Macro.prewalk(code_ast, [], fn node, acc ->
          case node do
            # ignore `/` that are part of a function capture
            {:&, metadata, [{:/, metadata2, children2} | children]} ->
              node =
                {:&, metadata,
                 [{:/, Keyword.put(metadata2, :ignore, true), children2} | children]}

              {node, acc}

            # usage: Kernel./(x, y) or &Kernel.//2
            {:., _, [{:__aliases__, _, [:Kernel]}, :/]} ->
              {node, [node | acc]}

            # usage: x / y
            {:/, metadata, _} ->
              if Keyword.get(metadata, :ignore) do
                {node, acc}
              else
                {node, [node | acc]}
              end

            _ ->
              {node, acc}
          end
        end)

      acc == []
    end
  end

  assert_no_call "does not call Integer module" do
    type :essential
    comment Constants.sieve_do_not_use_div_rem()
    called_fn module: Integer, name: :_
  end

  assert_no_call "does not call Float module" do
    type :essential
    comment Constants.sieve_do_not_use_div_rem()
    called_fn module: Float, name: :_
  end

  assert_no_call "does not call :math module" do
    type :essential
    comment Constants.sieve_do_not_use_div_rem()
    called_fn module: :math, name: :_
  end
end
