# {{PROJECT_NAME}} — developer entry point.
# Every agent and every CI step goes through these targets, so `make lint`,
# `make build` and `make test-file FILE=…` mean the same thing in every project.
# Run `make` for the list.

COMPOSE := docker compose
# {{IF FRONTEND}}
FE_DIR  := {{FE_DIR}}
FE      := frontend
# {{ENDIF}}
# {{IF BACKEND}}
BE_DIR  := {{BE_DIR}}
BE      := backend
# {{ENDIF}}

.DEFAULT_GOAL := help
.PHONY: help install install-frontend install-backend dev lint format typecheck test test-file test-file-frontend build clean \
        lint-frontend format-frontend typecheck-frontend test-frontend build-frontend \
        lint-backend format-backend typecheck-backend test-backend build-backend \
        up down restart logs ps clean-docker migrate \
        dev-frontend dev-backend up-frontend up-backend stop-frontend stop-backend \
        logs-frontend logs-backend

## ───────── Help ─────────
help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

## ───────── Local (no Docker) ─────────
install: ## Install all dependencies
	{{INSTALL_CMD}}
# {{IF FRONTEND}}
install-frontend: ## Install frontend dependencies only (CI)
	cd $(FE_DIR) && {{FE_INSTALL_CMD}}
# {{ENDIF}}
# {{IF BACKEND}}
install-backend: ## Install backend dependencies only (CI)
	cd $(BE_DIR) && {{BE_INSTALL_CMD}}
# {{ENDIF}}

dev: ## Run the dev server(s) locally
# {{IF FULLSTACK}}
	$(MAKE) -j2 dev-frontend dev-backend
# {{ENDIF}}
# {{IF FRONTEND_ONLY}}
	$(MAKE) dev-frontend
# {{ENDIF}}
# {{IF BACKEND_ONLY}}
	$(MAKE) dev-backend
# {{ENDIF}}

# {{IF FRONTEND}}
dev-frontend: ## Frontend dev server
	cd $(FE_DIR) && {{FE_DEV_CMD}}
# {{ENDIF}}
# {{IF BACKEND}}
dev-backend: ## Backend dev server
	cd $(BE_DIR) && {{BE_DEV_CMD}}
# {{ENDIF}}

# Aggregate targets call the per-side ones, so CI can run one side at a time.
# {{IF FULLSTACK}}
lint: lint-frontend lint-backend ## Lint every side
format: format-frontend format-backend ## Format every side
typecheck: typecheck-frontend typecheck-backend ## Type-check every side (what CI runs)
test: test-frontend test-backend ## Run all tests
build: build-frontend build-backend ## Build every side
# {{ENDIF}}
# {{IF FRONTEND_ONLY}}
lint: lint-frontend ## Lint
format: format-frontend ## Format
typecheck: typecheck-frontend ## Type-check (what CI runs)
test: test-frontend ## Run all tests
build: build-frontend ## Build
# {{ENDIF}}
# {{IF BACKEND_ONLY}}
lint: lint-backend ## Lint
format: format-backend ## Format
typecheck: typecheck-backend ## Type-check (what CI runs)
test: test-backend ## Run all tests
build: build-backend ## Build
# {{ENDIF}}

# {{IF FRONTEND}}
lint-frontend: ## Lint the frontend
	cd $(FE_DIR) && {{FE_LINT_CMD}}
format-frontend: ## Format the frontend
	cd $(FE_DIR) && {{FE_FORMAT_CMD}}
typecheck-frontend: ## Type-check the frontend
	cd $(FE_DIR) && {{FE_TYPECHECK_CMD}}
test-frontend: ## Run frontend tests
	cd $(FE_DIR) && {{FE_TEST_CMD}}
build-frontend: ## Build the frontend
	cd $(FE_DIR) && {{FE_BUILD_CMD}}
# {{ENDIF}}

# {{IF BACKEND}}
lint-backend: ## Lint the backend
	cd $(BE_DIR) && {{BE_LINT_CMD}}
format-backend: ## Format the backend
	cd $(BE_DIR) && {{BE_FORMAT_CMD}}
typecheck-backend: ## Type-check the backend
	cd $(BE_DIR) && {{BE_TYPECHECK_CMD}}
test-backend: ## Run backend tests
	cd $(BE_DIR) && {{BE_TEST_CMD}}
build-backend: ## Build the backend
	cd $(BE_DIR) && {{BE_BUILD_CMD}}
# {{ENDIF}}

test-file: ## Run one test file: make test-file FILE=<path relative to the side's dir>
	@test -n "$(FILE)" || (echo "usage: make test-file FILE=<path>" && exit 1)
# {{IF BACKEND}}
	cd $(BE_DIR) && {{BE_TEST_SINGLE_CMD}} $(FILE)
# {{ENDIF}}
# {{IF FRONTEND_ONLY}}
	cd $(FE_DIR) && {{FE_TEST_SINGLE_CMD}} $(FILE)
# {{ENDIF}}
# {{IF FULLSTACK}}

test-file-frontend: ## Run one frontend test file: make test-file-frontend FILE=<path>
	@test -n "$(FILE)" || (echo "usage: make test-file-frontend FILE=<path>" && exit 1)
	cd $(FE_DIR) && {{FE_TEST_SINGLE_CMD}} $(FILE)
# {{ENDIF}}

# {{IF BACKEND_PYTHON}}
migrate: ## Apply database migrations locally
	cd $(BE_DIR) && {{BE_MIGRATE_CMD}}
# {{ENDIF}}

clean: ## Remove build artefacts and dependencies
	find . -name node_modules -type d -prune -exec rm -rf {} + 2>/dev/null || true
	find . \( -name dist -o -name .next -o -name .turbo -o -name __pycache__ -o -name .pytest_cache \) -type d -prune -exec rm -rf {} + 2>/dev/null || true

## ───────── Docker (local stack) ─────────
up: ## Build and start the whole stack in the background
	$(COMPOSE) up --build -d

down: ## Stop and remove the stack
	$(COMPOSE) down

restart: down up ## Restart the whole stack

logs: ## Tail all logs
	$(COMPOSE) logs -f

ps: ## Show running services
	$(COMPOSE) ps

# {{IF FRONTEND}}
up-frontend: ## Rebuild and restart the frontend container, then tail its logs
	$(COMPOSE) stop $(FE) && $(COMPOSE) up --build -d $(FE) && $(COMPOSE) logs -f $(FE)

stop-frontend: ## Stop the frontend container
	$(COMPOSE) stop $(FE)

logs-frontend: ## Tail frontend logs
	$(COMPOSE) logs -f $(FE)
# {{ENDIF}}

# {{IF BACKEND}}
up-backend: ## Rebuild and restart the backend container, then tail its logs
	$(COMPOSE) stop $(BE) && $(COMPOSE) up --build -d $(BE) && $(COMPOSE) logs -f $(BE)

stop-backend: ## Stop the backend container
	$(COMPOSE) stop $(BE)

logs-backend: ## Tail backend logs
	$(COMPOSE) logs -f $(BE)
# {{ENDIF}}

clean-docker: ## Remove the stack, its local images and volumes
	$(COMPOSE) down --rmi local -v
