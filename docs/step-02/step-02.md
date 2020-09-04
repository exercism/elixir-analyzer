# A Guide to Writing an Elixir Analyzer Extension

## Step 2: The anatomy of an elixir analyzer extension

In this section we will look at two files:

- The example module file we will want to analyze
- The example Analyzer extension

### The example module

```elixir
# ./02-example-module.ex
defmodule Example do

  def hello(name) do
    "Hello, #{name}!"
  end
end
```

Here we have a basic module that defines a single function `Example.hello/1`. If you are familiar with exercism practice exercises, this resembles the `two-fer` exercise.

### The example analyzer extension

An analyzer does not replace module unit tests, the goal of our analyzer is to tease out anti-patterns in passing solutions. Using this pattern detection, the goal is to provide clear, direct coaching to a student to correct the design choice.

```elixir
defmodule ElixirAnalyzer.ExerciseTest.Example do  # 1
  @dialyzer generated: true                       # 2
  use ElixirAnalyzer.ExerciseTest                 # 3
end
```

This is the bare minimum of required code for an analyzer extension. There are a few things here to look at in more detail. Looking at line 1, we can see the naming convention used by the analyzer. An analyzer extension must be named `ElixirAnalyzer.ExerciseTest.__________` where the blank is the name of the module you want to analyze. In our case we can see in the code example, the name for our extension is `ElixirAnalyzer.ExerciseTest.Example`.

Line 2 of the extension has a module attribute to notify _dialyzer_ that the module is generated from another. Without this line you may see some dialyzer warnings that are unfixable as the warning is derived from the compilation step and how the extension is transformed through the macro unfolding process.

Line 3 allows the use of the macros found in `ElixirAnalyzer.ExerciseTest`, specifically the `feature/1` macro. This macro will allow us to specify tests and patterns that we want to identify in the solution being analyzed.

## How to use the extension

The extension module should then be placed into the `lib/` folder of the mix project, ideally in `lib/elixir_analyzer/exercise_test/` folder for convention.

Then we can run the elixir analyzer:

```shell
> mix escript.build
Compiling 2 files (.ex)
Generated escript elixir_analyzer with MIX_ENV=dev

> ./elixir_analyzer --analyze-file "<path>/02-example-module.ex:Example"
undefined analysis ... Completed!

Analysis ... Analysis Complete
Output written to ... <path>/analysis.json
```

We can then find `analysis.json` at the path specified with the contents:

```json
{ "comments": [], "status": "approve" }
```

---

Next steps: [adding a feature test][step-3]

[step-3]: ../step-03/step-03.md
