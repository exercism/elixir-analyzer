#!/bin/bash

set -euo pipefail

mix local.hex --force
mix deps.get
mix deps.compile
mix escript.build

mv elixir_analyzer ./bin/elixir_analyzer
chmod +x ./bin/elixir_analyzer