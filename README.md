# Docker Aseprite Headless

[![Builds](https://github.com/kidthales/docker-aseprite-headless/actions/workflows/batch.yml/badge.svg)](https://github.com/kidthales/docker-aseprite-headless/actions/workflows/batch.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

Build your own Docker images featuring an [Aseprite](https://www.aseprite.org/) binary suitable for [CLI](https://www.aseprite.org/docs/cli/) use cases, such as in build scripts or automated workflows like GitHub Actions.

> [!TIP]  
> If you would like to compile Aseprite with a GUI, please look to the [official documentation](https://github.com/aseprite/aseprite/blob/main/INSTALL.md) for more information. For use-cases that require a docker-based compilation targeting a Linux host, please take a look at [nilsve/docker-aseprite-linux](https://github.com/nilsve/docker-aseprite-linux).

> [!WARNING]  
> This project only supports building Aseprite v1.3.15+ for Debian Trixie based images.

## Quickstart

To build a fresh image using an Aseprite binary built from the `main` branch of [Aseprite's GitHub repository](https://github.com/aseprite/aseprite):

```shell
# Creates image with tag aseprite:main-headless
docker buildx bake --pull --no-cache
```

To confirm that the image runs as a container:

```shell
docker run --rm -it aseprite:main-headless --help
```

To perform some Aseprite cli task on some file in the current host directory:

```shell
docker run --rm -it -v .:/workspace aseprite:main-headless --batch --layer 'Layer 1' example.aseprite --save-as example.png
```

To build from some other ref within the Aseprite repository, override the bake variable's default value:

```shell
# Creates image with tag aseprite:v1.3.15.5-headless
ASEPRITE_GIT_REF=v1.3.15.5 docker buildx bake --pull --no-cache
```

Please refer to the [docker-bake](./docker-bake.hcl) file for all available bake variables and their default values.

## Makefile

A simple Makefile is provided to help ease build invocations; a build using the bake variables' default values would look like:

```shell
make build
```

After invoking this command, you will notice a git ignored `.env` file was generated; you may override the bake variable values here and the `make build` invocation will use them on subsequent runs. 

An example `.env` file's contents could look like:

```dotenv
IMAGES_PREFIX="kidthales/"
ASEPRITE_GIT_REF="v1.3.15"
ASEPRITE_BUILD_TYPE="RelWithDebInfo"
```

> [!WARNING]  
> Ensure that the values assigned in the `.env` file are wrapped in double quotes. This is a requirement of the underlying `docker buildx bake` command used to perform image builds.

To view the current bake configuration based on the `.env` file content:

```shell
make print
```

## GitHub Actions

Some example workflows are utilized in this project to help build and push images to the repository owner's GitHub container registry. When using these workflows in your own repository, please ensure that you are familiar with [authenticating in a GitHub Actions workflow](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-in-a-github-actions-workflow) and the steps laid out for [upgrading a workflow that accesses a registry using a personal access token](https://docs.github.com/en/packages/managing-github-packages-using-github-actions-workflows/publishing-and-installing-a-package-with-github-actions#upgrading-a-workflow-that-accesses-a-registry-using-a-personal-access-token).
