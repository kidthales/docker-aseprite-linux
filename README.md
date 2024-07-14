# Docker Aseprite Linux

This repository allows you to compile Aseprite with Make & Docker Compose; it is a fork
of [nilsve/docker-aseprite-linux](https://github.com/nilsve/docker-aseprite-linux) with some inspiration taken from
things I like in [dunglas/symfony-docker](https://github.com/dunglas/symfony-docker).

> I was originally interested in automating Aseprite exports as part of my indie game dev 'stack'; I may have gotten
> carried away here! 😅

## Features

- A flexible docker compose driven compile script capable of:
    - Building Aseprite with clang (default) or g++.
    - Specifying build type (RelWithDebInfo, Debug, etc.).
    - Specifying alternate git branches, tags, & hashes for Aseprite & Skia build sources.
    - (Mostly) automated handling of dependencies & build outputs across differing build runs.
    - Easily creating headless builds.
- A Makefile fronted with helpful targets for:
    - Compiling Aseprite for a Linux host.
    - Creating a docker image with a headless Aseprite build (maybe useful for exporting in some kind of CI setup?).
    - Cleaning & removing builds & dependencies.

## Requirements

- [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/install/).
- [GNU Make](https://www.gnu.org/software/make/).

## Quickstart

Compile Aseprite and output runtime resources to `output/build/bin`:

```shell
make aseprite
```

Build a Docker image with headless Aseprite:

```shell
make image
```

## Usage

```text
 —— ⬜ 🐳 Docker Aseprite Linux Makefile 🐳 ⬜ ——————————————————————————————————
help                           Outputs this help screen.
help-aseprite                  Outputs compile-aseprite help screen.
aseprite                       Compile Aseprite, pass the parameter "c=" to specify compilation options, example: make aseprite c='--git-ref-aseprite v1.2.40'.
image                          Build Aseprite image (headless).
clean                          Remove Aseprite build artifacts.
dist-clean                     Remove Aseprite build artifacts & all build dependencies.
dist-clean-aseprite            Remove Aseprite build artifacts & project.
dist-clean-depot               Remove depot_tools build dependency.
dist-clean-skia                Remove skia build dependency.
```

```text
Compile Aseprite for Linux

Usage:
  /compile-aseprite [-h|--help] | [--git-ref-skia <git-ref>] [--git-ref-aseprite <git-ref>] [--build-type <build-type>] [--headless] [--with-g++]

  -h, --help
    Outputs this help screen.

  --git-ref-skia <git-ref>
    The git-ref to use when cloning https://github.com/aseprite/skia.git. Defaults to aseprite-m102.

  --git-ref-aseprite <git-ref>
    The git-ref to use when cloning https://github.com/aseprite/aseprite.git. Defaults to main.

  --build-type <build-type>
    The value used for -DCMAKE_BUILD_TYPE. Defaults to RelWithDebInfo.

  --headless
    Sets value used for -DENABLE_UI to OFF. Defaults is ON.

  --with-g++
      Use the g++ compiler toolchain. Default is clang.
```

## Additional Information

### Compilation Toolchain

By default, clang is used to build all dependencies along with Aseprite; Builds with g++ are also supported.

> Builds with clang are recommended in the Aseprite project documents; anecdotally, these builds also result in smaller
> headless image sizes when compared to g++ builds.

> IMPORTANT: When switching toolchains, make sure to run `make clean` between compilation runs.

### `.env`

Use a git ignored [.env file](https://docs.docker.com/compose/environment-variables/variable-interpolation/#env-file) to
override compilation defaults and image naming.

```dotenv
# Example .env file.
IMAGES_PREFIX=my-vendor/
ASEPRITE_GIT_REF=v1.3.7
ASEPRITE_COMPILE_PYTHON_VERSION=3.11-bookworm
ASEPRITE_COMPILE_TIMEZONE=Canada/Pacific
SKIA_GIT_REF=aseprite-m121
BUILD_TYPE=Debug
COMPILER_CHAIN=g++
```

### FAQ

Please refer to the upstream project's [FAQ](https://github.com/nilsve/docker-aseprite-linux/blob/master/README.md#faq)
for hints.

## License

[MIT](./LICENSE)
