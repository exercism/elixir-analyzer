# A Guide to Writing an Elixir Analyzer Extension

## Step 4: Adding unit tests for the new extension

1. Create a new file in `/test/elixir_analyzer/test_suite/` called `analyzer_extension_module_name_test.exs`.

2. Do not use `ExUnit.Case` directly, but rather our custom `ElixirAnalyzer.ExerciseTestCase`. It takes the analyzer extension module as an option so that you don't need to repeat it with every test.

   ```elixir
   use ElixirAnalyzer.ExerciseTestCase,
     exercise_test_module: ElixirAnalyzer.ExerciseTest.Example
   ```

3. Use the `test_exercise_analysis` macro to define test cases. It expects a test name, assertions about the analysis result comments, and a code snippet or list of code snippets in the `do` block. Refer to the macro's documentation for more details.

   ```elixir
   # 04-example-analysis-test.exs
   defmodule ElixirAnalyzer.TestSuite.ExampleTest do
     use ElixirAnalyzer.ExerciseTestCase,
         exercise_test_module: ElixirAnalyzer.TestSuite.Example

     test_exercise_analysis "perfect solution",
       comments: [] do
       defmodule Example do
         @moduledoc """
         Greets the user
         """
         def hello(name) do
           "Hello, #{name}!"
         end
       end
     end
   end
   ```
