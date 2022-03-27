# Recipes

## Find local function call by function name (any arity, any argument names)

```elixir
assert_call "description" do
  called_fn name: :local_function_name
end
```

This will also find local calls that reference the module by name or by `__MODULE__`.

## Find function call by module name and function name (any arity, any argument names)

```elixir
assert_call "description" do
  called_fn module: ModuleName, name: :function_name
end
```

## Find function call by module name and function name (any arity, any argument names) from a specific local function

```elixir
assert_call "description" do
  calling_fn module: CallingModuleName, name: :calling_function_name
  called_fn module: ModuleName, name: :function_name
end
```

## Find no functions calls of any functions from a given module

```elixir
assert_no_call "description" do
  called_fn module: ModuleName, name: :_
end
```

## Find usage of list comprehensions

```elixir
assert_call "description" do
  called_fn name: :for
end
```

## Assert no usage of a specific module

This is trivial with `assert_(no_)call` because it tracks imports and aliases.

```elixir
assert_no_call "does not call any ModuleName functions" do
  called_fn module: ModuleName, name: :_
end
```

## Suppress assert if another assert passed or failed

This is useful to create conditionals between asserts.

```elixir
assert_call "call function_one if function_two not called" do
  called_fn module: ModuleName, name: :function_one
  suppress_if "call function_two if function_one not called", :pass
end

assert_call "call function_two if function_one not called" do
  called_fn module: ModuleName, name: :function_two
  suppress_if "call function_one if function_two not called", :pass
end
```


Note that tracking imports only works for standard library modules, not user-defined modules.

## Find module attribute with given value and any name

```elixir
feature "description" do
  find :any

  form do
    @_shallow_ignore :some_value
  end
end
```

## Find module attribute with given name and any value

```elixir
feature "description" do
  find :any

  form do
    @some_name _ignore
  end
end
```

## Asserting two function calls in a block appear in order

This check will also pass if there are other function calls in between, before, or after.

```elixir
feature "description" do
  find :any

  form do
    def read_file(_ignore) do
      _block_includes do
        _ignore = File.open(_ignore)
        File.close(_ignore)
      end
    end
  end
end
```

## Asserting that a block finished with a specific function 

This check will also pass if there are other function calls in between or before (but not after). When used to match a single line, make sure to place `_block_ends_with` inside a context (like a module or function definition) as in the example below.

```elixir
feature "description" do
  find :any

  form do
    def read_file(_ignore) do
      _block_ends_with do
        _ignore = File.open(_ignore)
        File.close(_ignore)
      end
    end
  end
end
```

## Check that a solution contains comments

The `check_source` type of check can access the data in the `%Source{}` struct (submission code as string or AST, exercise slug and type, exemplar/example as string or AST, and more), which can be used for advanced checks. The function `check` must return a boolean. `check_source` is powerful but primitive, `feature` or `assert_call` should be preferred if they can be used as they have more refined features (such as imports tracking). 

```elixir
check_source "code contains comments" do

  check(%Source{code_string: code_string}) do
    code_string
      |> String.split("\n")
      |> Enum.any?(&String.starts_with?(&1, "#"))
  end 
end 
```

