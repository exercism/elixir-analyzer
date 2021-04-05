defmodule ElixirAnalyzer.TestSuite.BirdCount do
  @dialyzer generated: true
  @moduledoc """
  This is an exercise analyzer extension module for the concept exercise Bird Count
  """

  alias ElixirAnalyzer.Constants

  use ElixirAnalyzer.ExerciseTest

  not_allowed_functions =
    [{quote(do: Enum), Enum}, {quote(do: List), List}, {quote(do: Stream), Stream}]
    |> Enum.flat_map(fn {quoted_module, module} ->
      Enum.map(module.module_info(:exports), fn {fun, _arity} -> {quoted_module, fun} end)
    end)
    |> Enum.uniq()

  code =
    Enum.map(not_allowed_functions, fn {module, function} ->
      quote do
        assert_no_call "does not call #{unquote(module)}.#{unquote(function)}" do
          type :essential
          called_fn module: unquote(module), name: unquote(function)
          comment unquote(Constants.bird_count_use_recursion())
        end
      end
    end)

  Code.eval_quoted(code, [], __ENV__)

  feature "doesn't use list comprehensions" do
    find :none
    type :essential
    comment Constants.bird_count_use_recursion()

    form do
      for _ignore <- _ignore do
        _ignore
      end
    end

    form do
      for _ignore <- _ignore, _ignore do
        _ignore
      end
    end

    form do
      for _ignore <- _ignore, _ignore, into: _ignore do
        _ignore
      end
    end
  end
end
