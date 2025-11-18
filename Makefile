# Makefile for Playdate itch.io Pipeline
# Simplifies common development tasks

.PHONY: help install build test validate run deploy-dev deploy-beta deploy-stable clean hooks

# Default game source (can be overridden)
GAME_SOURCE ?= game-template

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Playdate itch.io Pipeline - Available Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-18s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Usage Examples:$(NC)"
	@echo "  make build                    # Build default game"
	@echo "  make build GAME_SOURCE=my-game  # Build specific game"
	@echo "  make test                     # Run validation"
	@echo "  make deploy-dev               # Deploy to dev channel"
	@echo ""

install: ## Install git hooks and check dependencies
	@echo "$(BLUE)Installing git hooks...$(NC)"
	@./scripts/install-hooks.sh
	@echo "$(GREEN)Setup complete!$(NC)"

build: ## Build the game
	@echo "$(BLUE)Building game from $(GAME_SOURCE)...$(NC)"
	@./scripts/build.sh --source $(GAME_SOURCE)
	@echo "$(GREEN)Build complete!$(NC)"

build-device: ## Build for Playdate device
	@echo "$(BLUE)Building game for device from $(GAME_SOURCE)...$(NC)"
	@./scripts/build.sh --source $(GAME_SOURCE) --device
	@echo "$(GREEN)Device build complete!$(NC)"

build-clean: ## Clean build and rebuild
	@echo "$(BLUE)Clean building game from $(GAME_SOURCE)...$(NC)"
	@./scripts/build.sh --source $(GAME_SOURCE) --clean
	@echo "$(GREEN)Clean build complete!$(NC)"

validate: ## Validate game code and structure
	@echo "$(BLUE)Validating game...$(NC)"
	@./scripts/validate.sh --source $(GAME_SOURCE)

validate-strict: ## Validate with strict mode (warnings as errors)
	@echo "$(BLUE)Validating game (strict mode)...$(NC)"
	@./scripts/validate.sh --source $(GAME_SOURCE) --strict

test: validate ## Run tests (alias for validate)

run: ## Run game in simulator
	@echo "$(BLUE)Running game in simulator...$(NC)"
	@./scripts/run-simulator.sh

deploy-dev: ## Deploy to itch.io dev channel
	@echo "$(BLUE)Deploying to dev channel...$(NC)"
	@./scripts/deploy-itch.sh dev
	@echo "$(GREEN)Deployed to dev channel!$(NC)"

deploy-beta: ## Deploy to itch.io beta channel
	@echo "$(BLUE)Deploying to beta channel...$(NC)"
	@./scripts/deploy-itch.sh beta
	@echo "$(GREEN)Deployed to beta channel!$(NC)"

deploy-stable: ## Deploy to itch.io stable channel
	@echo "$(BLUE)Deploying to stable channel...$(NC)"
	@./scripts/deploy-itch.sh stable
	@echo "$(GREEN)Deployed to stable channel!$(NC)"

deploy-dev-dry: ## Dry run deploy to dev channel
	@echo "$(YELLOW)Dry run: Deploying to dev channel...$(NC)"
	@./scripts/deploy-itch.sh dev --dry-run

deploy-beta-dry: ## Dry run deploy to beta channel
	@echo "$(YELLOW)Dry run: Deploying to beta channel...$(NC)"
	@./scripts/deploy-itch.sh beta --dry-run

deploy-stable-dry: ## Dry run deploy to stable channel
	@echo "$(YELLOW)Dry run: Deploying to stable channel...$(NC)"
	@./scripts/deploy-itch.sh stable --dry-run

clean: ## Clean build directory
	@echo "$(BLUE)Cleaning build directory...$(NC)"
	@rm -rf build/*
	@echo "$(GREEN)Build directory cleaned!$(NC)"

hooks: install ## Install git hooks (alias for install)

new-game: ## Create a new game from template
	@echo "$(BLUE)Creating new game...$(NC)"
	@read -p "Game name: " name; \
	read -p "Author name: " author; \
	./scripts/create-game.sh "$$name" "$$author"
	@echo "$(GREEN)Game created!$(NC)"

release-beta: ## Create a beta release (interactive)
	@echo "$(YELLOW)Creating beta release...$(NC)"
	@read -p "Version (e.g., 1.0.0-beta.1): " version; \
	echo "$(BLUE)Tagging version $$version...$(NC)"; \
	git tag "v$$version"; \
	echo "$(BLUE)Pushing tag...$(NC)"; \
	git push origin "v$$version"; \
	echo "$(GREEN)Beta release v$$version created!$(NC)"

release: ## Create a stable release (interactive)
	@echo "$(YELLOW)Creating stable release...$(NC)"
	@read -p "Version (e.g., 1.0.0): " version; \
	echo "$(BLUE)Tagging version $$version...$(NC)"; \
	git tag "v$$version"; \
	echo "$(BLUE)Pushing tag...$(NC)"; \
	git push origin "v$$version"; \
	echo "$(GREEN)Stable release v$$version created!$(NC)"

check-env: ## Check environment setup
	@echo "$(BLUE)Checking environment...$(NC)"
	@echo ""
	@echo "$(YELLOW)Playdate SDK:$(NC)"
	@if [ -z "$$PLAYDATE_SDK_PATH" ]; then \
		echo "  $(RED)✗$(NC) PLAYDATE_SDK_PATH not set"; \
	else \
		echo "  $(GREEN)✓$(NC) PLAYDATE_SDK_PATH: $$PLAYDATE_SDK_PATH"; \
	fi
	@echo ""
	@echo "$(YELLOW)butler (itch.io CLI):$(NC)"
	@if command -v butler > /dev/null 2>&1; then \
		echo "  $(GREEN)✓$(NC) butler installed: $$(butler -V)"; \
	else \
		echo "  $(RED)✗$(NC) butler not installed"; \
	fi
	@echo ""
	@echo "$(YELLOW)itch.io Configuration:$(NC)"
	@if [ -z "$$BUTLER_API_KEY" ]; then \
		echo "  $(RED)✗$(NC) BUTLER_API_KEY not set"; \
	else \
		echo "  $(GREEN)✓$(NC) BUTLER_API_KEY is set"; \
	fi
	@if [ -z "$$ITCH_GAME" ]; then \
		echo "  $(RED)✗$(NC) ITCH_GAME not set"; \
	else \
		echo "  $(GREEN)✓$(NC) ITCH_GAME: $$ITCH_GAME"; \
	fi
	@echo ""
	@echo "$(YELLOW)Optional Tools:$(NC)"
	@if command -v luac > /dev/null 2>&1; then \
		echo "  $(GREEN)✓$(NC) luac (Lua compiler) installed"; \
	else \
		echo "  $(YELLOW)○$(NC) luac not installed (optional)"; \
	fi
	@if command -v luacheck > /dev/null 2>&1; then \
		echo "  $(GREEN)✓$(NC) luacheck (Lua linter) installed"; \
	else \
		echo "  $(YELLOW)○$(NC) luacheck not installed (optional)"; \
	fi

dev-workflow: ## Complete development workflow (build, validate, test)
	@echo "$(BLUE)Running development workflow...$(NC)"
	@$(MAKE) build GAME_SOURCE=$(GAME_SOURCE)
	@$(MAKE) validate GAME_SOURCE=$(GAME_SOURCE)
	@echo "$(GREEN)Development workflow complete!$(NC)"
	@echo "$(YELLOW)Run '$(MAKE) run' to test in simulator$(NC)"

ci-test: ## Run CI/CD validation (used by GitHub Actions)
	@echo "$(BLUE)Running CI/CD validation...$(NC)"
	@./scripts/validate.sh --source $(GAME_SOURCE) --strict
	@echo "$(GREEN)CI/CD validation passed!$(NC)"

list-builds: ## List all builds in build directory
	@echo "$(BLUE)Available builds:$(NC)"
	@if [ -d "build" ]; then \
		find build -name "*.pdx" -exec ls -lh {} \; 2>/dev/null || echo "No builds found"; \
	else \
		echo "No build directory"; \
	fi

version: ## Show current git version info
	@echo "$(BLUE)Version Information:$(NC)"
	@echo "  Current branch: $$(git rev-parse --abbrev-ref HEAD)"
	@echo "  Latest commit:  $$(git log -1 --format='%h - %s')"
	@if git describe --tags 2>/dev/null; then \
		echo "  Latest tag:     $$(git describe --tags --abbrev=0)"; \
	else \
		echo "  Latest tag:     (none)"; \
	fi

docs: ## Open documentation
	@echo "$(BLUE)Opening documentation...$(NC)"
	@echo "  README.md - Main documentation"
	@echo "  docs/SETUP.md - Setup guide"
	@echo "  docs/DEVELOPMENT.md - Development guide"
	@echo "  docs/DEPLOYMENT.md - Deployment guide"
	@echo "  CONTRIBUTING.md - Contribution guide"

quick-start: ## Quick start guide
	@echo "$(BLUE)Quick Start Guide$(NC)"
	@echo ""
	@echo "$(YELLOW)1. Install git hooks:$(NC)"
	@echo "   make install"
	@echo ""
	@echo "$(YELLOW)2. Check your environment:$(NC)"
	@echo "   make check-env"
	@echo ""
	@echo "$(YELLOW)3. Build the game:$(NC)"
	@echo "   make build"
	@echo ""
	@echo "$(YELLOW)4. Run in simulator:$(NC)"
	@echo "   make run"
	@echo ""
	@echo "$(YELLOW)5. Deploy to itch.io:$(NC)"
	@echo "   make deploy-dev"
	@echo ""
	@echo "For more commands, run: make help"

.DEFAULT_GOAL := help
