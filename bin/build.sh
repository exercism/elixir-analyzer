#!/bin/bash

mix deps.get
mix deps.compile
mix escript.build

mv elixir_analyzer ./bin/elixir_analyzer
chmod +x ./bin/elixir_analyzer