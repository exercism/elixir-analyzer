[
    ~r/The test \d* =:= nil can never evaluate to 'true'/

  #  # {short_description}
  #  {":0:unknown_function Function :erl_types.t_is_opaque/1/1 does not exist."},
  #  # {short_description, warning_type}
  #  {":0:unknown_function Function :erl_types.t_to_string/1 does not exist.", :unknown_function},
  #  # {short_description, warning_type, line}
  #  {":0:unknown_function Function :erl_types.t_to_string/1 does not exist.", :unknown_function, 0},
  #  # {file, warning_type, line}
  #  {"lib/dialyxir/pretty_print.ex", :no_return, 100},
  #  # {file, warning_type}
  #  {"lib/dialyxir/warning_helpers.ex", :no_return},
  #  # {file}
  #  {"lib/dialyxir/warnings/app_call.ex"},
  #  # regex
  #  ~r/my_file\.ex.*my_function.*no local return/
]
