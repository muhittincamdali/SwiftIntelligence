# SwiftIntelligence Framework - Makefile
# Comprehensive development automation for AI/ML framework
# Usage: make [command]

# Configuration
SWIFT := swift
XCODEBUILD := xcodebuild
PROJECT_NAME := SwiftIntelligence
SCHEME := SwiftIntelligence
PLATFORM_IOS := iOS Simulator,name=iPhone 15 Pro,OS=17.2
PLATFORM_MACOS := macOS
PLATFORM_WATCHOS := watchOS Simulator,name=Apple Watch Series 9 (45mm),OS=10.2
PLATFORM_TVOS := tvOS Simulator,name=Apple TV 4K (3rd generation),OS=17.2
PLATFORM_VISIONOS := visionOS Simulator,name=Apple Vision Pro,OS=1.0

# Directories
BUILD_DIR := .build
DOCS_DIR := docs
COVERAGE_DIR := coverage
DERIVED_DATA := ~/Library/Developer/Xcode/DerivedData

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

# MARK: - Help

.PHONY: help
help: ## Show this help message
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║          SwiftIntelligence Framework - Makefile           ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Available commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BLUE)Examples:$(NC)"
	@echo "  make build          # Build the framework"
	@echo "  make test           # Run all tests"
	@echo "  make docs           # Generate documentation"
	@echo "  make clean          # Clean build artifacts"

# MARK: - Building

.PHONY: build
build: ## Build the framework (debug)
	@echo "$(GREEN)Building SwiftIntelligence framework...$(NC)"
	$(SWIFT) build

.PHONY: build-release
build-release: ## Build the framework (release)
	@echo "$(GREEN)Building SwiftIntelligence framework (Release)...$(NC)"
	$(SWIFT) build --configuration release

.PHONY: build-all
build-all: ## Build for all platforms
	@echo "$(GREEN)Building for all platforms...$(NC)"
	@$(MAKE) build-ios
	@$(MAKE) build-macos
	@$(MAKE) build-watchos
	@$(MAKE) build-tvos
	@$(MAKE) build-visionos

.PHONY: build-ios
build-ios: ## Build for iOS
	@echo "$(GREEN)Building for iOS...$(NC)"
	$(XCODEBUILD) build \
		-scheme $(SCHEME) \
		-destination platform="$(PLATFORM_IOS)" \
		-quiet

.PHONY: build-macos
build-macos: ## Build for macOS
	@echo "$(GREEN)Building for macOS...$(NC)"
	$(XCODEBUILD) build \
		-scheme $(SCHEME) \
		-destination platform="$(PLATFORM_MACOS)" \
		-quiet

.PHONY: build-watchos
build-watchos: ## Build for watchOS
	@echo "$(GREEN)Building for watchOS...$(NC)"
	$(XCODEBUILD) build \
		-scheme $(SCHEME) \
		-destination platform="$(PLATFORM_WATCHOS)" \
		-quiet

.PHONY: build-tvos
build-tvos: ## Build for tvOS
	@echo "$(GREEN)Building for tvOS...$(NC)"
	$(XCODEBUILD) build \
		-scheme $(SCHEME) \
		-destination platform="$(PLATFORM_TVOS)" \
		-quiet

.PHONY: build-visionos
build-visionos: ## Build for visionOS
	@echo "$(GREEN)Building for visionOS...$(NC)"
	$(XCODEBUILD) build \
		-scheme $(SCHEME) \
		-destination platform="$(PLATFORM_VISIONOS)" \
		-quiet

# MARK: - Testing

.PHONY: test
test: ## Run all tests
	@echo "$(GREEN)Running all tests...$(NC)"
	$(SWIFT) test --enable-code-coverage

.PHONY: test-verbose
test-verbose: ## Run tests with verbose output
	@echo "$(GREEN)Running tests (verbose)...$(NC)"
	$(SWIFT) test --enable-code-coverage --verbose

.PHONY: test-parallel
test-parallel: ## Run tests in parallel
	@echo "$(GREEN)Running tests in parallel...$(NC)"
	$(SWIFT) test --parallel --enable-code-coverage

.PHONY: test-filter
test-filter: ## Run specific tests (usage: make test-filter FILTER=NLP)
	@echo "$(GREEN)Running filtered tests: $(FILTER)...$(NC)"
	$(SWIFT) test --filter $(FILTER)

.PHONY: test-coverage
test-coverage: ## Generate test coverage report
	@echo "$(GREEN)Generating test coverage report...$(NC)"
	@mkdir -p $(COVERAGE_DIR)
	$(SWIFT) test --enable-code-coverage
	@echo "$(YELLOW)Converting coverage data...$(NC)"
	xcrun llvm-cov export \
		$(BUILD_DIR)/debug/$(PROJECT_NAME)PackageTests.xctest/Contents/MacOS/$(PROJECT_NAME)PackageTests \
		-instr-profile $(BUILD_DIR)/debug/codecov/default.profdata \
		-format=lcov > $(COVERAGE_DIR)/coverage.lcov
	@echo "$(GREEN)Coverage report generated at $(COVERAGE_DIR)/coverage.lcov$(NC)"

.PHONY: test-benchmarks
test-benchmarks: ## Run performance benchmarks
	@echo "$(GREEN)Running performance benchmarks...$(NC)"
	$(SWIFT) test --filter Benchmark

.PHONY: test-integration
test-integration: ## Run integration tests
	@echo "$(GREEN)Running integration tests...$(NC)"
	$(SWIFT) test --filter Integration

# MARK: - Documentation

.PHONY: docs
docs: ## Generate documentation with DocC
	@echo "$(GREEN)Generating documentation...$(NC)"
	@mkdir -p $(DOCS_DIR)
	$(SWIFT) package generate-documentation \
		--target $(PROJECT_NAME) \
		--output-path $(DOCS_DIR) \
		--transform-for-static-hosting \
		--hosting-base-path $(PROJECT_NAME)
	@echo "$(GREEN)Documentation generated at $(DOCS_DIR)$(NC)"

.PHONY: docs-preview
docs-preview: ## Preview documentation in browser
	@echo "$(GREEN)Starting documentation preview server...$(NC)"
	$(SWIFT) package --disable-sandbox preview-documentation \
		--target $(PROJECT_NAME)

.PHONY: docs-all
docs-all: ## Generate documentation for all targets
	@echo "$(GREEN)Generating documentation for all targets...$(NC)"
	@for target in Core NLP Vision Speech ML Privacy Network Cache Metrics Reasoning ImageGeneration; do \
		echo "$(YELLOW)Generating docs for SwiftIntelligence$$target...$(NC)"; \
		$(SWIFT) package generate-documentation \
			--target SwiftIntelligence$$target \
			--output-path $(DOCS_DIR)/$$target; \
	done

# MARK: - Code Quality

.PHONY: lint
lint: ## Run SwiftLint
	@echo "$(GREEN)Running SwiftLint...$(NC)"
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint; \
	else \
		echo "$(RED)SwiftLint not installed. Install with: brew install swiftlint$(NC)"; \
		exit 1; \
	fi

.PHONY: lint-fix
lint-fix: ## Auto-fix SwiftLint violations
	@echo "$(GREEN)Auto-fixing SwiftLint violations...$(NC)"
	@if command -v swiftlint >/dev/null 2>&1; then \
		swiftlint --fix; \
	else \
		echo "$(RED)SwiftLint not installed. Install with: brew install swiftlint$(NC)"; \
		exit 1; \
	fi

.PHONY: format
format: ## Format code with swift-format
	@echo "$(GREEN)Formatting code...$(NC)"
	@if command -v swift-format >/dev/null 2>&1; then \
		swift-format -i -r Sources Tests Examples; \
	else \
		echo "$(YELLOW)swift-format not installed. Install with: brew install swift-format$(NC)"; \
	fi

.PHONY: analyze
analyze: ## Run static analysis
	@echo "$(GREEN)Running static analysis...$(NC)"
	$(XCODEBUILD) analyze \
		-scheme $(SCHEME) \
		-destination platform="$(PLATFORM_MACOS)" \
		-quiet

# MARK: - Dependencies

.PHONY: resolve
resolve: ## Resolve package dependencies
	@echo "$(GREEN)Resolving package dependencies...$(NC)"
	$(SWIFT) package resolve

.PHONY: update
update: ## Update package dependencies
	@echo "$(GREEN)Updating package dependencies...$(NC)"
	$(SWIFT) package update

.PHONY: dependencies
dependencies: ## Show package dependencies
	@echo "$(GREEN)Package dependencies:$(NC)"
	$(SWIFT) package show-dependencies

# MARK: - Cleaning

.PHONY: clean
clean: ## Clean build artifacts
	@echo "$(GREEN)Cleaning build artifacts...$(NC)"
	$(SWIFT) package clean
	rm -rf $(BUILD_DIR)
	rm -rf $(COVERAGE_DIR)
	@echo "$(GREEN)Clean complete!$(NC)"

.PHONY: clean-all
clean-all: clean ## Deep clean including DerivedData
	@echo "$(YELLOW)Cleaning DerivedData...$(NC)"
	rm -rf $(DERIVED_DATA)/$(PROJECT_NAME)-*
	rm -rf $(DOCS_DIR)
	@echo "$(GREEN)Deep clean complete!$(NC)"

.PHONY: reset
reset: clean-all ## Complete reset (clean + resolve)
	@echo "$(YELLOW)Performing complete reset...$(NC)"
	@$(MAKE) resolve
	@echo "$(GREEN)Reset complete!$(NC)"

# MARK: - Installation

.PHONY: install-tools
install-tools: ## Install required development tools
	@echo "$(GREEN)Installing development tools...$(NC)"
	@echo "$(YELLOW)Installing SwiftLint...$(NC)"
	brew install swiftlint || true
	@echo "$(YELLOW)Installing swift-format...$(NC)"
	brew install swift-format || true
	@echo "$(YELLOW)Installing xcbeautify...$(NC)"
	brew install xcbeautify || true
	@echo "$(GREEN)Tools installation complete!$(NC)"

.PHONY: check-tools
check-tools: ## Check if required tools are installed
	@echo "$(GREEN)Checking development tools...$(NC)"
	@command -v swiftlint >/dev/null 2>&1 && echo "✅ SwiftLint" || echo "❌ SwiftLint"
	@command -v swift-format >/dev/null 2>&1 && echo "✅ swift-format" || echo "❌ swift-format"
	@command -v xcbeautify >/dev/null 2>&1 && echo "✅ xcbeautify" || echo "❌ xcbeautify"
	@command -v jazzy >/dev/null 2>&1 && echo "✅ Jazzy" || echo "❌ Jazzy"

# MARK: - Release

.PHONY: version
version: ## Show current version
	@echo "$(GREEN)Current version:$(NC)"
	@grep 'public static let version' Sources/SwiftIntelligenceCore/SwiftIntelligenceCore.swift | cut -d'"' -f2

.PHONY: tag
tag: ## Create a git tag (usage: make tag VERSION=1.0.0)
	@echo "$(GREEN)Creating tag v$(VERSION)...$(NC)"
	git tag -a v$(VERSION) -m "Release version $(VERSION)"
	@echo "$(YELLOW)Push tag with: git push origin v$(VERSION)$(NC)"

.PHONY: release
release: clean-all build-release test docs ## Prepare for release
	@echo "$(GREEN)Release preparation complete!$(NC)"
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "  1. Update CHANGELOG.md"
	@echo "  2. Commit changes"
	@echo "  3. Create tag: make tag VERSION=x.x.x"
	@echo "  4. Push tag: git push origin vx.x.x"

# MARK: - Development

.PHONY: dev
dev: ## Open project in Xcode
	@echo "$(GREEN)Opening in Xcode...$(NC)"
	open Package.swift

.PHONY: watch
watch: ## Watch for changes and rebuild
	@echo "$(GREEN)Watching for changes...$(NC)"
	@while true; do \
		fswatch -o Sources Tests | xargs -n1 -I{} $(MAKE) build; \
	done

.PHONY: serve-docs
serve-docs: docs ## Serve documentation locally
	@echo "$(GREEN)Serving documentation at http://localhost:8000$(NC)"
	cd $(DOCS_DIR) && python3 -m http.server 8000

# MARK: - CI/CD

.PHONY: ci
ci: lint build test ## Run CI pipeline locally
	@echo "$(GREEN)CI pipeline complete!$(NC)"

.PHONY: pre-commit
pre-commit: lint-fix format test ## Pre-commit checks
	@echo "$(GREEN)Pre-commit checks passed!$(NC)"

# MARK: - Utility

.PHONY: stats
stats: ## Show project statistics
	@echo "$(GREEN)Project Statistics:$(NC)"
	@echo "$(YELLOW)Lines of code:$(NC)"
	@find Sources -name "*.swift" -exec wc -l {} + | tail -1
	@echo "$(YELLOW)Number of files:$(NC)"
	@find Sources -name "*.swift" | wc -l
	@echo "$(YELLOW)Number of tests:$(NC)"
	@grep -r "func test" Tests | wc -l

.PHONY: todo
todo: ## Show all TODO and FIXME comments
	@echo "$(GREEN)TODO and FIXME items:$(NC)"
	@grep -r "TODO\|FIXME" Sources Tests --include="*.swift" || echo "No TODOs found!"

.PHONY: contributors
contributors: ## Show contributors
	@echo "$(GREEN)Contributors:$(NC)"
	@git shortlog -sn

# Keep the Makefile from deleting intermediate files
.PRECIOUS: %.xcodeproj

# Disable built-in rules
.SUFFIXES: