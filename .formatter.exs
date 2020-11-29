# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: [
    # Elixir Analyzer
    status: :*,
    find: :*,
    on_fail: :*,
    comment: :*,
    form: :*,
    suppress_if: :*,
    depth: :*,
    calling_function: :*,
    called_function: :*
  ]
]
