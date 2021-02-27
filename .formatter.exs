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
    called_from: :*,
    global_call: :*,
    local_call: :*,
    should_be_present: :*,
    type: :*
  ]
]
