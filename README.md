# Docker Aseprite Container (opinionated)

This repository allows you to compile Aseprite without installing any build tools.

---

> ⚠️ Warning: [upstream repository](https://github.com/nilsve/docker-aseprite-linux) does not declare an explicit
> license thus we must default
> to [License: No Permission](https://choosealicense.com/no-permission/).
>    - Why work on this? [Ethical imperative](https://en.wikipedia.org/wiki/Hacker_ethic).

---

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
bats                           Run unit tests (TODO).
```

```text
Compile Aseprite for Linux

Usage:
  /compile-aseprite [-h|--help] | [--git-ref-skia <git-ref>] [--git-ref-aseprite <git-ref>] [--build-type <build-type>] [--headless]

  -h, --help
    Outputs this help screen.

  --git-ref-skia <git-ref>
    The git-ref to use when cloning https://github.com/aseprite/skia.git. Defaults to aseprite-m102.

  --git-ref-aseprite <git-ref>
    The git-ref to use when cloning https://github.com/aseprite/aseprite.git. Defaults to main.

  --build-type <build-type>
    The value used for -DCMAKE_BUILD_TYPE. Defaults to RelWithDebInfo.

  --headless
    Sets value used for -DENABLE_UI to OFF. Defaults to ON.
```

## Additional Information

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
ENABLE_UI=OFF
```

## Acknowledgments

- Forked from [nilsve/docker-aseprite-linux](https://github.com/nilsve/docker-aseprite-linux).
- Docker & Docker Compose structure inspired by [dunglas/symfony-docker](https://github.com/dunglas/symfony-docker).
