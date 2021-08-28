
ARG ALPINE_VERSION=3.14

FROM elixir:1.12.2-alpine as elixir_alpine

ENV APP_PATH=/app

RUN apk add \
  --update-cache \
  postgresql-client \
  nodejs \
  npm

RUN mix do local.hex --force, local.rebar --force

WORKDIR $APP_PATH
 
# The stage can be used for development
# Following the instructions described in the README.md
FROM elixir_alpine as development

RUN apk add \
  # The package `inotify-tools` is needed for instant live-reload of the the phoenix server
  inotify-tools

# Install mix dependencies
COPY mix.exs mix.lock $APP_PATH/
RUN mix do deps.get

COPY assets/package.json assets/package-lock.json $APP_PATH/assets/
RUN npm install --prefix assets

# Building a release version
# https://hexdocs.pm/phoenix/releases.html
FROM elixir_alpine AS production_build

# Set build ENV
ENV MIX_ENV=prod

# Install mix dependencies
COPY mix.exs mix.lock $APP_PATH/
RUN mix do deps.get, deps.compile

# Build assets
COPY assets $APP_PATH/assets/
RUN set -eux; \
    npm \
      --loglevel=error \
      --no-audit \
      --prefix assets \
      --progress=false \
      ci \
    ; \
    npm \
      --prefix assets \
      run \
      deploy \
    ;

# Compile and build release
COPY . .
RUN mix do phx.digest, compile, release

# Prepare release image
FROM alpine:${ALPINE_VERSION} AS production

ENV APP_PATH=/app

RUN apk add --no-cache \
      libgcc \
      libstdc++ \
      ncurses-libs \
      openssl \
      postgresql-client \
    ;

WORKDIR $APP_PATH

RUN chown nobody:nobody $APP_PATH/

USER nobody:nobody

COPY .docker/entrypoint.release.sh $APP_PATH/.docker/entrypoint.release.sh
COPY --from=production_build --chown=nobody:nobody $APP_PATH/_build/prod/rel/qrstorage ./

ENV HOME=$APP_PATH

ENTRYPOINT ["sh", ".docker/entrypoint.release.sh"]

EXPOSE 8000