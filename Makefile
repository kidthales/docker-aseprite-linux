# Executables (local)
DOCKER_BAKE = touch .env && docker buildx bake -f .env -f docker-bake.hcl

# Misc
.DEFAULT_GOAL = help
.PHONY        : help build

## —— Docker Aseprite Headless Makefile ————————————————————————————————————————
help: ## Outputs this help screen.
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

build: ## Build the toolkit images. Pass the parameter "c=" to pass additional options and arguments to docker bake; example: make build c="--no-cache --pull"
	@$(eval c ?=)
	@$(DOCKER_BAKE) $(c)
