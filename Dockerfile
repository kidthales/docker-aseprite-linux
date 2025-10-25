#syntax=docker/dockerfile:1.4

# The different stages of this Dockerfile are meant to be built into separate images.
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target

ARG python_version

FROM python:${python_version} as compile

# Required for tzdata.
ARG timezone
RUN ln -snf /usr/share/zoneinfo/${timezone} /etc/localtime && echo ${timezone} > /etc/timezone

# Install dependencies.
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
	clang \
	cmake \
	curl \
	g++ \
	git \
	libc++-dev \
	libc++abi-dev \
	libfontconfig1-dev \
	libgl1-mesa-dev \
	libx11-dev \
	libxcursor-dev \
	libxi-dev \
	libxrandr-dev \
	ninja-build \
	unzip

COPY --link --chmod=755 compile.sh /compile-aseprite

VOLUME /dependencies
VOLUME /output

WORKDIR /output

ENTRYPOINT ["/compile-aseprite"]

FROM debian:trixie-slim as aseprite

# Assumes compiled output exists on host; see compile stage.
COPY output/aseprite/build/bin /opt/aseprite/bin

WORKDIR /tmp

# Ensure binary is found in $PATH.
RUN ln -s /opt/aseprite/bin/aseprite /usr/local/bin/aseprite && ln -s /opt/aseprite/bin/aseprite /usr/local/bin/ase

# Install dependencies.
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
	libc++1-17t64 \
	libfontconfig1 \
	libgl1 \
	libldap2 \
	libsm6 \
	libssl3 \
	libxcursor1 \
	libxrandr2 \
	&& rm -rf /var/lib/apt/lists/*

COPY --link --chmod=755 entrypoint.sh /docker-aseprite-entrypoint

RUN ln -s /docker-aseprite-entrypoint /usr/local/bin/docker-aseprite-entrypoint

# Smoke test.
RUN /docker-aseprite-entrypoint --help

ENTRYPOINT ["docker-aseprite-entrypoint"]

CMD ["--help"]
