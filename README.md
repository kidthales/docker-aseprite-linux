# Docker Aseprite Container (opinionated)

This repository allows you to compile Aseprite without installing any build tools.

---

> ⚠️ Warning: upstream repository does not declare an explicit license and so must default
> to [License: No Permission](https://choosealicense.com/no-permission/).
>    - Then why work on this? [Ethical imperative](https://en.wikipedia.org/wiki/Hacker_ethic).

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

```shell
 —— ⬜ 🐳 Docker Aseprite Linux Makefile 🐳 ⬜ —————————————————————————————————— 
help                           Outputs this help screen.
aseprite                       Compile Aseprite, pass the parameter "c=" to specify compilation options, example: make aseprite c='--git-ref-aseprite main' (TODO).
image                          Build Aseprite image.
clean                          Remove Aseprite build artifacts.
dist-clean                     Remove Aseprite build artifacts & all build dependencies
dist-clean-aseprite            Remove Aseprite build artifacts & project.
dist-clean-depot               Remove depot_tools build dependency.
dist-clean-skia                Remove skia build dependency.
chown                          Fix file ownership issues on linux hosts.
```

## Additional Information

> TODO

## Acknowledgments

- Forked from [nilsve/docker-aseprite-linux](https://github.com/nilsve/docker-aseprite-linux).
- Docker & Docker Compose structure inspired by [dunglas/symfony-docker](https://github.com/dunglas/symfony-docker).
