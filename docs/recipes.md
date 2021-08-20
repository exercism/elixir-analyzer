# Recipes

## Find local function call by function name (any arity, any argument names)

```elixir
assert_call "description" do
  called_fn name: :local_function_name
end
```

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
