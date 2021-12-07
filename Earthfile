# SPDX-FileCopyrightText: 2021 Rosa Richter
#
# SPDX-License-Identifier: MIT

ARG MIX_ENV=dev

all:
  BUILD +test
  BUILD +check
  BUILD +lint-copyright
  BUILD +docker

get-deps:
  FROM elixir:1.13-alpine
  RUN mix do local.rebar --force, local.hex --force
  COPY mix.exs .
  COPY mix.lock .

  RUN mix deps.get

  SAVE ARTIFACT deps AS LOCAL ./deps

compile-deps:
  FROM +get-deps
  RUN MIX_ENV=$MIX_ENV mix deps.compile

  SAVE ARTIFACT _build/$MIX_ENV AS LOCAL ./_build/$MIX_ENV

build:
  FROM +compile-deps

  COPY lib ./lib

  RUN MIX_ENV=$MIX_ENV mix compile

  SAVE ARTIFACT _build/$MIX_ENV AS LOCAL ./_build/$MIX_ENV

lint-copyright:
  FROM fsfe/reuse

  COPY . .

  RUN reuse lint

test:
  FROM --build-arg MIX_ENV=test +build

  COPY test ./test
  COPY docker-compose.yml ./docker-compose.yml

  WITH DOCKER --compose docker-compose.yml
    RUN mix test
  END

check:
  FROM --build-arg MIX_ENV=dev +build

  COPY . .

  RUN mix check --except ex_unit --except reuse

release:
  FROM +build

  RUN MIX_ENV=$MIX_ENV mix release

  SAVE ARTIFACT _build/$MIX_ENV/rel AS LOCAL ./_build/$MIX_ENV/rel

docker:
  FROM elixir:alpine
  WORKDIR /app

  COPY --build-arg MIX_ENV=prod +release/rel .

  ENTRYPOINT ["/app/bin/extracker"]
  CMD ["start"]

  SAVE IMAGE --push ghcr.io/cantido/extracker:latest

  
