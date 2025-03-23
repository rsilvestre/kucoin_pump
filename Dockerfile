# ./Dockerfile

# Extend from the official Elixir image.
FROM elixir:1.18 as build

ARG TELEGRAM_ENABLED
ARG TELEGRAM_BOT_TOKEN
ARG TELEGRAM_CHAT_ID
ARG MIX_ENV
ARG PGUSER
ARG PGPASSWORD
ARG PGDATABASE
ARG PGPORT
ARG PGHOST

RUN apt-get update

ENV MIX_ENV=$MIX_ENV
ENV TELEGRAM_ENABLED=$TELEGRAM_ENABLED
ENV TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
ENV TELEGRAM_CHAT_ID=$TELEGRAM_CHAT_ID
ENV PGUSER=$PGUSER
ENV PGPASSWORD=${PGPASSWORD}
ENV PGDATABASE=$PGDATABASE
ENV PGPORT=$PGPORT
ENV PGHOST=$PGHOST

# Create app directory and copy the Elixir projects into it.
RUN mkdir /app
WORKDIR /app

# Install Hex package manager.
# By using `--force`, we don’t need to type “Y” to confirm the installation.
RUN mix do local.hex --force, local.rebar --force

# install mix dependencies
COPY mix.exs mix.lock ./

RUN mix do deps.get --only $MIX_ENV, deps.compile

# build project
COPY config config
COPY priv priv
COPY lib lib

RUN mix do compile, release

FROM elixir:1.18 as app

RUN apt-get update && \
    apt-get install -y postgresql-client

ENV MIX_ENV=${MIX_ENV}

# prepare app directory
RUN mkdir /app
WORKDIR /app

# copy release to app container
COPY --from=build /app/_build/prod/rel/kucoin_pump .
COPY entrypoint.sh .

RUN chown -R nobody: /app

USER nobody

ENV HOME=/app

CMD ["bash", "/app/entrypoint.sh"]
