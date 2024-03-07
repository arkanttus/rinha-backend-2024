# ---------------------------------------------------------#
# Build Release                                            #
# ---------------------------------------------------------#
ARG ELIXIR_VERSION=1.15.4
ARG OTP_VERSION=25.3.2.3
ARG DEBIAN_VERSION=bullseye-20230612-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} as builder

ENV TZ=America/Sao_Paulo
ENV DEBIAN_FRONTEND=noninteractive

# install build dependencies
RUN apt-get update -y && apt-get install -y build-essential git wget && \
  apt-get clean && rm -f /var/lib/apt/lists/*_*

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
  mix local.rebar --force

# set build ENV
ENV MIX_ENV="prod"

# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY priv priv

# Compile the release
COPY lib lib
RUN mix compile

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel

RUN mix release

# ---------------------------------------------------------#
# Run Release                                              #
# ---------------------------------------------------------#
FROM ${RUNNER_IMAGE}

RUN apt-get update -y \
  && apt-get install -y libstdc++6 openssl libncurses5 locales tini curl \
  && ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime \
  && dpkg-reconfigure -f noninteractive tzdata \
  && apt-get clean \
  && rm -f /var/lib/apt/lists/*_*

ENV TZ="America/Sao_Paulo"
ENV DEBIAN_FRONTEND=noninteractive

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR "/app"
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/rinha_backend ./

USER nobody

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/app/bin/rinha_backend", "start"]