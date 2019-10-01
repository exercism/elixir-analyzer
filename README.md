# ElixirAnalyzer

This is a prototype Elixir application to follow the specification of the Exercism.io automated mentor support project.

## Current status / plan

`ElixirAnalyzer` at this point will run static analysis.  The result json file is output to the destination folder.

`ElixirAnalyzer.Exercise` is able to generate static analysis tests and the analyze function loads the features to be tested.

## How to run the prototype

### via CLI

running `bin/elixir_analyzer` on a system with elixir/erlang/otp installed

```text
  $ elixir_analyzer {--exercise exercise-name|exercise-name} {--path path-to|path-to}

  You may also pass the following optional flags:
    --skip-analysis                         flag skips running the static analysis
    --output path, -o path                  where to print the output, default to path
    --output-file filename, -f filename     default 'analyze.json'
```

### via IEX

`iex -S mix`, then calling `ElixirAnalyzer.analyze_exercise("slug-name", "/path/to/solution/")`.
This assumes the solution has the file of the proper name and also a test unit by the proper name.

At this time "two-fer" is the only solution implemented at a most basic level. All that gets validated is if it passes the test unit completely.  Goal will be to able to recognize the optimal solution through ast search for specific patterns.

As a demonstration, once iex loads with `iex -S mix` you can type `ElixirAnalyzer.analyze("two-fer", "./test_data/two_fer/passing_solution/")`.

## Design

### `ElixirAnalyzer`

* The is the main application module.  A function call to `start_analyze/3` begins the analysis (either through IEX or the CLI escript [if generated]).
* A json configuation `config/exercise_data.json` holds data for each exercise supported

```json
{
    "two-fer": {
        "code_file": "two_fer.ex",
        "analyzer_module": "ElixirAnalyzer.Exercise.TwoFer"
    }
}
```

* `analyze` then loads the appropriate files from the exercise solution
* `analyze` then calls the `analyze/x` function from the __analyzer_module__.

### `ElixirAnalyzer.Submission`

This is a module that contains a struct of the same name with operations to manipulate itself.  Contains the exercise information, list of all the comments to be returned to the student, the solution status.

This struct is passed along throughout the analysis of the solution

### `ElixirAnalyzer.ExerciseTest`

This module contains macros for a DSL to be able to compare ideal solution features to the exercise solution attempt.

```elixir
  # module usage
  use ElixirAnalyzer.Exercise

  # This is DSL for describing the test to be done
  # This describes that a solution should have a typespec for the two_fer function
  feature "has spec" do

    mentor_message "elixir.two_fer.no_specification"
    severity :message # or :disapprove or :refer
    match :all # :any, :none, :one
    # status :test # :skip

    # the form of the code that you are looking for
    # you may include more than one form block
    form do
      @spec two_fer(String.t()) :: String.t()
    end
  end
```

### `ElixirAnalyzer.CLI`

This module is a module for the CLI escript to parse the command line arguements and start the processing

### `ElixirAnalyzer.ExerciseTest.________`

These modules are for describing the tests for which the analyzer is able to determine the state of the solution based on style, syntax.  They use `ElixirAnalyzer.Exercise` for macro generation of code.

## Other Plans

1. Develop the environment for execution (postponed)
    * Edit, Aug 18/19 -- This will all be orchestrated in a docker container, so the code should be constrained (though absolute security is not possible in docker), if the need arises will come up with a solution.

2. Finish the escript to be able to call the program from the command line with command line arguments

3. Create the bash script to call the application with the parameters needed (stubbed in `bin/analyze.sh`)

4. Create the Dockerfile in order to create the environment for the application to be run. (stubbed in `docker/Dockerfile`)

## Dictionary of paramerized comments

Parameterized Comment | Comment Description | Comment Website Copy
--------------------- | ------------------- | --------------------
`"elixir.general.approve"` | Solution has been approved, may have more reasons to follow. |
`"elixir.general.refer_to_mentor"` | Solution has been referred to a mentor, may have more reasons to follow. |
`"elixir.general.disapprove"` | Solution has been disapproved for some reason, must have more reasons to follow. |
`"elixir.general.code_file_not_found"` | Unable to locate the code file at the path |
`"elixir.general.compile_success"` | Successful compile |
`"elixir.general.compile_error"` | Some error occured with compilation |
--------------------- | ------------------- | --------------------
`"elixir.analysis.quote_error"` | There was some error creating a quoted form (Abstract-Syntax-Tree) of the code as a string |
--------------------- | ------------------- | --------------------
`"elixir.two_fer.no_specification"` | Suggest a type specification to student
