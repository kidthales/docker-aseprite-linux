# Executables (local)
DOCKER_COMP = docker compose

# Misc
.DEFAULT_GOAL = help
.PHONY        : help help-aseprite aseprite image clean dist-clean dist-clean-aseprite dist-clean-depot dist-clean-skia bats

## —— ⬜ 🐳 Docker Aseprite Linux Makefile 🐳 ⬜ ——————————————————————————————————
help: ## Outputs this help screen.
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

help-aseprite: ## Outputs compile-aseprite help screen.
	@$(DOCKER_COMP) run --build --rm bash bash /project/compile.sh --help

aseprite: ## Compile Aseprite, pass the parameter "c=" to specify compilation options, example: make aseprite c='--git-ref-aseprite v1.2.40'.
	@$(eval c ?=)
	@$(DOCKER_COMP) run --build --rm aseprite $(c)

image: ## Build Aseprite image (headless).
	@$(MAKE) aseprite c='--headless'
	@$(DOCKER_COMP) -f compose.yaml -f compose.image.yaml build aseprite

clean: ## Remove Aseprite build artifacts.
	@$(DOCKER_COMP) run --build --rm bash rm -rf /project/output/aseprite/build

dist-clean: dist-clean-aseprite dist-clean-depot dist-clean-skia ## Remove Aseprite build artifacts & all build dependencies.

dist-clean-aseprite: ## Remove Aseprite build artifacts & project.
	@$(DOCKER_COMP) run --build --rm bash rm -rf /project/output/aseprite

dist-clean-depot: ## Remove depot_tools build dependency.
	@$(DOCKER_COMP) run --build --rm bash rm -rf /project/dependencies/depot_tools

dist-clean-skia: ## Remove skia build dependency.
	@$(DOCKER_COMP) run --build --rm bash rm -rf -rf /project/dependencies/skia

bats: ## Run unit tests (TODO).
	@$(DOCKER_COMP) run --build --rm bats
