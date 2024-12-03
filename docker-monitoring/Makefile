DOCKER_COMPOSE_CMD := docker compose --env-file monitoring.env

include monitoring.env

.PHONY: start
start: ## Start node
	$(DOCKER_COMPOSE_CMD) up --detach --force-recreate

.PHONY: stop
stop: ## Stop node
	$(DOCKER_COMPOSE_CMD) down

.PHONY: stop-and-remove-volumes
stop-and-remove: ## Stop and remove volumes
	$(DOCKER_COMPOSE_CMD) down --volumes

.PHONY: logs
logs: ## Show logs
	$(DOCKER_COMPOSE_CMD) logs --tail 50 --follow $(args)

.PHONY: raw
raw: ## Wrapper for Docker Compose
	$(DOCKER_COMPOSE_CMD) $(args)

.PHONY: watch
watch: ## Watch containers
	watch -n 1 $(DOCKER_COMPOSE_CMD) ps

.PHONY: customize-configs
customize-configs: ## Customize configs (use before any modifications)
	mkdir -p ./$(CONFIG_PATH)
	cp -r ./configs/* ./$(CONFIG_PATH)/

.PHONY: diff-custom-configs
diff-custom-configs: ## Compare original and custom configs
	diff --color='always' -ru ./configs/ ./$(CONFIG_PATH)/

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\t\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
