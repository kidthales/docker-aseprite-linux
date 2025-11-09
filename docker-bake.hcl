variable "APP_UPSTREAM" { default = "docker-image://debian:trixie-slim" }
variable "ASEPRITE_BUILD_TYPE" { default = "Release" }
variable "ASEPRITE_GIT_REF" { default = "main" }
variable "BUILDER_UPSTREAM" { default = "docker-image://python:3.12.12-trixie" }
variable "IMAGES_PREFIX" { default = "" }

target "aseprite-headless" {
     args = {
        aseprite_build_type = "${ASEPRITE_BUILD_TYPE}"
        aseprite_git_ref = "${ASEPRITE_GIT_REF}"
    }
    contexts = {
        builder-upstream = "${BUILDER_UPSTREAM}"
        app-upstream = "${APP_UPSTREAM}"
    }
    target = "app"
    tags = ["${IMAGES_PREFIX}aseprite:${ASEPRITE_GIT_REF}-headless"]
}

group "default" {
    targets = ["aseprite-headless"]
}
