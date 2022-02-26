# ElixirAnalyzer [![Coverage Status](https://coveralls.io/repos/github/jiegillet/elixir-analyzer/badge.svg)](https://coveralls.io/github/jiegillet/elixir-analyzer)

This is an Elixir application to follow the specification of the Exercism automated mentor support project.

See the project docs: https://github.com/exercism/docs/tree/main/building/tooling/analyzers

## Current status / plan

`ElixirAnalyzer` at this point will run static analysis. The result json file is output to the destination folder.

`ElixirAnalyzer.ExerciseTest` is able to generate static analysis tests and the analyze function loads the features to be tested.

## How to run

### via CLI

#### Fast start

```shell
$ ./bin/build
[output of CLI being build]
$ ./bin/elixir_analyzer <exercise-slug> <path the folder containing the solution> <path to folder for output>
```

#### Running the analyzer

Running `bin/elixir_analyzer` on a system with Elixir/Erlang/OTP installed

```text
  Usage:
    $ elixir_analyzer <exercise-slug> <path the folder containing the solution> <path to folder for output> [options]
```

### via IEX

`iex -S mix`, then calling:
```elixir
ElixirAnalyzer.analyze_exercise("exercise-slug", "/path/to/solution/", "/path/to/output/")
```

This assumes the solution has the file of the proper name and also a test unit by the proper name.

To check that it works without preparing a custom exercise solution, you can run it on one of the text fixtures: 

```elixir
ElixirAnalyzer.analyze_exercise("two-fer", "./test_data/two_fer/imperfect_solution/", "./test_data/two_fer/imperfect_solution/")
```

## Tests

The tests are run with `mix test`.

### Git submodule

Some of the tests depend on the `/elixir` git submodule. Run `git submodule update --init --recursive` once after cloning this repo to also get the submodule.

To check at which commit the submodule is, run `git submodule`. To update the submodule to the newest commit, run `git submodule update --remote --merge`.

The submodule is used only by the tests.

### External tests

There are also tests tagged as `:external` which are excluded by default. Those tests check if all of the comments used in this repository exist in [`exercism/website-copy`][website-copy-comments]. To run all tests, use the `--include external` flag.

## Design

### `ElixirAnalyzer`

- The is the main application module. A function call to `start_analyze/3` begins the analysis (either through IEX or the CLI escript [if generated]).
- A configuration in `config/config.exs` holds data for each exercise supported

```elixir
config :elixir_analyzer,
  exercise_config: %{
    "two-fer" => %{
      code_file: "two_fer.ex",
      analyzer_module: ElixirAnalyzer.TestSuite.TwoFer
    },
    # ... and so on
  }
```

- `analyze` then loads the appropriate files from the exercise solution
- `analyze` then calls the `analyze/x` function from the **analyzer_module**.

### `ElixirAnalyzer.Submission`

This is a module that contains a struct of the same name with operations to manipulate itself. Contains the exercise information, list of all the comments to be returned to the student, the solution status.

This struct is passed along throughout the analysis of the solution

### `ElixirAnalyzer.ExerciseTest`

This module contains macros for a DSL to be able to compare ideal solution features to the exercise solution attempt.

```elixir
  # module usage
  use ElixirAnalyzer.Exercise

  # This is DSL for describing the test to be done
  # This describes that a solution should have a typespec for the two_fer function
  feature "has spec" do

    status   :test # :skip -- optional
    find     :all # :any, :none, :one
    type     :actionable # or :essential, :informative, :celebratory
    comment  Constants.two_fer_no_specification # may also be a string

    # the form of the code that you are looking for
    # you may include more than one form block
    form do
      @spec two_fer(String.t()) :: String.t()
    end
  end
```

### `ElixirAnalyzer.Constants`

Contains macro to generate a function returning the comment path on the [`exercism/website-copy`][website-copy-comments] repository.

### `ElixirAnalyzer.CLI`

This module is a module for the CLI escript to parse the command line arguments and start the processing

### `ElixirAnalyzer.ExerciseTest.________`

These modules are for describing the tests for which the analyzer is able to determine the state of the solution based on style, syntax. They use `ElixirAnalyzer.Exercise` for macro generation of code.

[website-copy-comments]: https://github.com/exercism/website-copy/tree/main/analyzer-comments
