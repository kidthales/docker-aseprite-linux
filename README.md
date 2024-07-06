# Docker Aseprite Container (opinionated)

This repository allows you to compile Aseprite without installing any build tools.

Forked from [nilsve/docker-aseprite-linux](https://github.com/nilsve/docker-aseprite-linux).

- ⚠️ [License: No Permission](https://choosealicense.com/no-permission/)
    - Then why work on this? [Ethical imperative](https://en.wikipedia.org/wiki/Hacker_ethic).

Docker & Docker Compose structure inspired by [dunglas/symfony-docker](https://github.com/dunglas/symfony-docker).

---

## Requirements

- [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/install/).
- [GNU Make](https://www.gnu.org/software/make/) (optional).

## Quickstart

Compile Aseprite and output runtime resources to `output/build/bin`:

```shell
make aseprite

# manual
docker compose run --build --rm aseprite
```

Build a Docker image with headless Aseprite:

```shell
make image

# manual (TODO)
docker compose run --build --rm aseprite --headless
docker compose -f compose.yaml -f compose.image.yaml build aseprite
```

> WIP
