defmodule ElixirAnalyzer.Support.AnalyzerVerification.SuppressIf do
  @moduledoc """
  This is an analyzer extension module to test the option :suppress_if between features/assert_call/common checks
  """

  alias ElixirAnalyzer.Constants
  alias ElixirAnalyzer.Source
  use ElixirAnalyzer.ExerciseTest

  feature "feature 1: no foo() unless common check was found" do
    find :none
    comment "feature 1: foo() was called"
    suppress_if Constants.solution_debug_functions(), :fail

    form do
      foo()
    end
  end

  assert_no_call "assert 1: no foo() unless common check was found" do
    comment "assert 1: foo() was called"
    suppress_if Constants.solution_debug_functions(), :fail
    called_fn name: :foo
  end

  check_source "check source 1: no foo() unless common check was found" do
    comment "check source 1: foo() was called"
    suppress_if Constants.solution_debug_functions(), :fail
    check(%Source{code_string: code_string}, do: not String.contains?(code_string, "foo"))
  end

  feature "feature 2: no bar() unless assert 1 found a foo() first" do
    find :none
    comment "feature 2: bar() was called"
    suppress_if "assert 1: no foo() unless common check was found", :fail

    form do
      bar()
    end
  end

  assert_no_call "assert 2: no bar() unless feature 1 found a foo() first" do
    comment "assert 2: bar() was called"
    suppress_if "feature 1: no foo() unless common check was found", :fail
    called_fn name: :bar
  end

  check_source "check source 2: no bar() unless assert 1 found a foo() first" do
    comment "check source 2: bar() was called"
    suppress_if "check source 1: no foo() unless common check was found", :fail
    check(%Source{code_string: code_string}, do: not String.contains?(code_string, "bar"))
  end

  feature "feature 3: no baz() unless feature 1 found a foo() first" do
    find :none
    comment "feature 3: baz() was called"
    suppress_if "feature 1: no foo() unless common check was found", :fail

    form do
      baz()
    end
  end

  assert_no_call "assert 3: no baz() unless assert 1 found a foo() first" do
    comment "assert 3: baz() was called"
    suppress_if "assert 1: no foo() unless common check was found", :fail
    called_fn name: :baz
  end

  check_source "check source 3: no baz() unless feature 1 found a foo() first" do
    comment "check source 3: baz() was called"
    suppress_if "feature 1: no foo() unless common check was found", :fail
    check(%Source{code_string: code_string}, do: not String.contains?(code_string, "baz"))
  end

  feature "feature 4: no qux() unless feature 2/3 found a bar()/baz() first" do
    find :none
    comment "feature 4: qux() was called"
    suppress_if "feature 2: no bar() unless assert 1 found a foo() first", :fail
    suppress_if "feature 3: no baz() unless feature 1 found a foo() first", :fail

    form do
      qux()
    end
  end

  assert_no_call "assert 4: no qux() unless feature 2/3 found a bar()/baz() first" do
    comment "assert 4: qux() was called"
    suppress_if "feature 2: no bar() unless assert 1 found a foo() first", :fail
    suppress_if "feature 3: no baz() unless feature 1 found a foo() first", :fail
    called_fn name: :qux
  end

  check_source "check source 4: no qux() unless feature 2/3 found a bar()/baz() first" do
    comment "check source 4: qux() was called"
    suppress_if "feature 2: no bar() unless assert 1 found a foo() first", :fail
    suppress_if "feature 3: no baz() unless feature 1 found a foo() first", :fail
    check(%Source{code_string: code_string}, do: not String.contains?(code_string, "qux"))
  end
end
