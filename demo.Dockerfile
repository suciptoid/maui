ARG ELIXIR_VERSION=1.19.0
ARG OTP_VERSION=28.1
ARG DEBIAN_VERSION=bookworm-20251020-slim

ARG BUILDER_IMAGE="docker.io/hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="docker.io/debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

# install build dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential git \
    && rm -rf /var/lib/apt/lists/*

COPY . /maui

WORKDIR /maui/demo

# install hex + rebar
RUN mix local.hex --force \
    && mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

RUN mix deps.get --only $MIX_ENV

RUN mix deps.compile

RUN mix assets.setup


# Compile the release
RUN mix compile

# compile assets
RUN mix assets.deploy

RUN mix release

# start a new build stage so that the final image will only contain
# the compiled release and other runtime necessities
FROM ${RUNNER_IMAGE} AS final

RUN apt-get update \
    && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses5 locales ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /maui/demo/_build/${MIX_ENV}/rel/app ./

USER nobody

# If using an environment that doesn't automatically reap zombie processes, it is
# advised to add an init process such as tini via `apt-get install`
# above and adding an entrypoint. See https://github.com/krallin/tini for details
# ENTRYPOINT ["/tini", "--"]

CMD ["/app/bin/server"]
