# Executables (local)
DOCKER_COMP = docker compose

# Misc
.DEFAULT_GOAL = help
.PHONY        : help aseprite image

## —— ⬜ 🐳 Docker Aseprite Linux Makefile 🐳 ⬜ ——————————————————————————————————
help: ## Outputs this help screen.
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

aseprite: ## Compile Aseprite, pass the parameter "c=" to specify compilation options, example: make aseprite c='--git-ref-aseprite main' (TODO).
	@$(eval c ?=)
	@$(DOCKER_COMP) run --build --rm aseprite $(c)

image: ## Build Aseprite image.
	@$(MAKE) aseprite c=''
	@$(DOCKER_COMP) -f compose.yaml -f compose.image.yaml build aseprite

