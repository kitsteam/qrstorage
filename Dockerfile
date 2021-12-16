
ARG ALPINE_VERSION=3.14

FROM elixir:1.12.2-alpine as elixir_alpine

ENV APP_PATH=/app

RUN apk add \
  --update-cache \
  postgresql-client \
  nodejs \
  npm

# Install for dart-sass https://github.com/CargoSense/dart_sass/issues/13
ARG GLIBC_VERSION=2.33-r0
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk
RUN apk add glibc-${GLIBC_VERSION}.apk

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

# Install for dart-sass https://github.com/CargoSense/dart_sass/issues/13
ARG GLIBC_VERSION=2.33-r0
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk
RUN apk add glibc-${GLIBC_VERSION}.apk

# Install mix dependencies
COPY mix.exs mix.lock $APP_PATH/
RUN mix do deps.get, deps.compile

# Compile and build release
COPY . .

# Build assets
# COPY assets/package.json assets/package-lock.json $APP_PATH/assets/
RUN npm install --prefix assets
RUN mix assets.deploy
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