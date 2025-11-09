#syntax=docker/dockerfile:1.4

# The different stages of this Dockerfile are meant to be built into separate images.
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/build/bake/reference/#targettarget

FROM builder-upstream AS builder

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

ARG aseprite_git_ref=main
ARG aseprite_build_type=Release

RUN git clone -b "${aseprite_git_ref}" --recursive https://github.com/aseprite/aseprite.git /opt/aseprite; \
	mkdir -p /opt/aseprite/build

RUN	cd /opt/aseprite/build && export CC=clang && export CXX=clang++ && cmake \
	-DCMAKE_BUILD_TYPE="${aseprite_build_type}" \
	-DCMAKE_CXX_FLAGS:STRING=-stdlib=libc++ \
	-DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libc++ \
	-DLAF_BACKEND=none \
	-DENABLE_SCRIPTING=on \
	-DENABLE_CCACHE=on \
	-G Ninja \
	.. \
	&& ninja aseprite

FROM app-upstream AS app

COPY --from=builder /opt/aseprite/build/bin /opt/aseprite/bin

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

WORKDIR /workspace

ENTRYPOINT ["docker-aseprite-entrypoint"]

CMD ["--help"]
