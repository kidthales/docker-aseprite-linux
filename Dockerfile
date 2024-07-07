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
	build-essential \
	cmake \
	curl \
	git \
	libfontconfig1-dev \
	libgl1-mesa-dev \
	libx11-dev \
	libxcursor-dev \
	libxi-dev \
	ninja-build \
	unzip

COPY --link --chmod=755 compile.sh /compile-aseprite

VOLUME /dependencies
VOLUME /output

WORKDIR /output

ENTRYPOINT ["/compile-aseprite"]

FROM debian:bookworm-slim as aseprite

# Assumes compiled output exists on host; see compile stage.
COPY output/aseprite/build/bin /opt/aseprite/bin

WORKDIR /tmp

# Ensure binary is found in $PATH.
RUN ln -s /opt/aseprite/bin/aseprite /usr/local/bin/aseprite && ln -s /opt/aseprite/bin/aseprite /usr/local/bin/ase

# Install dependencies.
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
	libfontconfig1 \
	libgl1 \
	libssl3 \
	libxcursor1 \
	&& rm -rf /var/lib/apt/lists/*

# Smoke test.
RUN aseprite --help

COPY --link --chmod=755 entrypoint.sh /docker-aseprite-entrypoint

RUN ln -s /docker-aseprite-entrypoint /usr/local/bin/docker-aseprite-entrypoint

ENTRYPOINT ["docker-aseprite-entrypoint"]

CMD ["--help"]
