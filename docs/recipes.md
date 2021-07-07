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
assert_all "description" do
  called_fn name: :for
end
```

## Assert no usage of a specific module

Note: simplified version for a module with a single-segment name like `List` or `Enum`.

```elixir
assert_no_call "does not call any ModuleName functions" do
  called_fn module: ModuleName, name: :_
end

feature "does not alias or import ModuleName" do
  find :none
   
  form do
    import ModuleName
  end

  form do
    use ModuleName
  end
   
  form do
    import ModuleName, _ignore
  end
    
  form do
    alias ModuleName, as: _ignore
  end
end
```

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
