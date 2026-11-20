.PHONY: help test test-quick test-verbose lint format clean install dev docs

# Default target
.DEFAULT_GOAL := help

# Colors
BOLD := \033[1m
GREEN := \033[92m
BLUE := \033[94m
NC := \033[0m

help: ## Show this help message
	@echo "$(BOLD)PalexusOS Development$(NC)"
	@echo "Usage: make $(BLUE)<target>$(NC)"
	@echo ""
	@echo "$(BOLD)Testing$(NC)"
	@grep -E '^test.*:.*##' Makefile | sed 's/:.*##\s*/ - /'
	@echo ""
	@echo "$(BOLD)Development$(NC)"
	@grep -E '^(lint|format|clean|install|dev|docs):.*##' Makefile | sed 's/:.*##\s*/ - /'
	@echo ""

# Testing targets
test: ## Run all 160 tests
	python -m pytest tests/ -v

test-quick: ## Run tests quickly (quiet mode)
	python -m pytest tests/ -q

test-verbose: ## Run tests with full output and tracebacks
	python -m pytest tests/ -vv --tb=long

test-design: ## Test design system module
	python -m pytest tests/test_design.py -v

test-build: ## Test build/gates module
	python -m pytest tests/test_build.py -v

test-desktop: ## Test desktop environment module
	python -m pytest tests/test_desktop.py -v

# Code quality targets
lint: ## Run code quality checks (ruff)
	ruff check palexus/ tests/ --extend-ignore=E501

format: ## Format code with black
	black palexus/ tests/ scripts/ --line-length=100

format-check: ## Check code formatting without changes
	black --check palexus/ tests/ scripts/ --line-length=100

# Package targets
install: ## Install palexus package in development mode
	pip install -e .

install-dev: ## Install with development dependencies
	pip install -e ".[dev]"

dev: install-dev test ## Install dev dependencies and run tests

# CLI targets
cli-design: ## Try design system CLI
	python -m palexus.design.cli list

cli-build: ## Try build system CLI
	python -m palexus.build.cli list

cli-test: ## Try test CLI
	python -m palexus.test.cli list

# Documentation targets
docs: ## Open documentation
	@echo "Documentation:"
	@echo "  - Quick start: $(BLUE)QUICKSTART.md$(NC)"
	@echo "  - Architecture: $(BLUE)ARCHITECTURE.md$(NC)"
	@echo "  - Domain model: $(BLUE)CONTEXT.md$(NC)"
	@echo "  - Decisions: $(BLUE)docs/adr/$(NC)"

docs-adr: ## List architecture decision records
	@ls -1 docs/adr/*.md | xargs -I {} basename {} | sed 's/^/  /'

# Cleaning targets
clean: ## Remove build artifacts and cache
	rm -rf build/ dist/ *.egg-info/
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name '*.pyc' -delete
	rm -rf .pytest_cache/ .mypy_cache/ .ruff_cache/

clean-all: clean ## Clean everything including git-ignored files
	git clean -fdx

# Package building
build: ## Build wheel distribution
	python -m build

pkg-build: ## Build Arch package (palexus-lib)
	cd packages/core/palexus-lib && makepkg -si

# Git targets
status: ## Show git status and unpushed commits
	git status
	@echo ""
	@echo "Unpushed commits:"
	git log @{u}.. --oneline || echo "  (up to date)"

# Help for ralph methodology
ralph: ## Show Ralph Wiggum methodology principles
	@echo "$(BOLD)Ralph Wiggum Methodology$(NC)"
	@echo "1. $(BLUE)Explicit Intent$(NC): Be clear about what you're doing and why"
	@echo "2. $(BLUE)Clear Boundaries$(NC): Define module ownership and contracts"
	@echo "3. $(BLUE)Intentional Design$(NC): Document decisions (ADRs)"
	@echo "4. $(BLUE)Locality$(NC): Changes stay localized to their modules"
	@echo "5. $(BLUE)Testability$(NC): Each module independently testable"
	@echo ""
	@echo "PalexusOS implements this through:"
	@echo "  - $(BLUE)CONTEXT.md$(NC): Domain terminology"
	@echo "  - $(BLUE)ARCHITECTURE.md$(NC): Module ownership"
	@echo "  - $(BLUE)docs/adr/$(NC): Decision rationale"
	@echo "  - $(BLUE)160 tests$(NC): Module verification"

# Default verbose
.VERBOSE:
