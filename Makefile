.PHONY: test lint format install-dev setup clean

# Test commands
test:
	@echo "Running NeoChange tests..."
	nvim --headless --noplugin -u tests/minimal_init.lua -c "lua require('plenary.test_harness').test_directory('tests/', {minimal_init = 'tests/minimal_init.lua'})"

test-watch:
	@echo "Running tests in watch mode..."
	find . -name "*.lua" | entr -c make test

# Linting and formatting
lint:
	@echo "Linting Lua files..."
	luacheck lua/ tests/ --globals vim

format:
	@echo "Formatting Lua files..."
	stylua lua/ tests/

format-check:
	@echo "Checking Lua formatting..."
	stylua --check lua/ tests/

# Development setup
install-dev:
	@echo "Installing development dependencies..."
	@echo "Please ensure you have the following tools installed:"
	@echo "- luacheck (lua linter)"
	@echo "- stylua (lua formatter)" 
	@echo "Installing plenary.nvim for testing..."
	@mkdir -p $(HOME)/.local/share/nvim/lazy
	@if [ ! -d "$(HOME)/.local/share/nvim/lazy/plenary.nvim" ]; then \
		git clone --depth=1 https://github.com/nvim-lua/plenary.nvim $(HOME)/.local/share/nvim/lazy/plenary.nvim; \
		echo "✓ plenary.nvim installed"; \
	else \
		echo "✓ plenary.nvim already installed"; \
	fi

# Clean up
clean:
	@echo "Cleaning up..."
	rm -rf .luacheckcache

# Setup for new contributors
setup: install-dev
	@echo "Development environment ready!"
	@echo "Run 'make ci' to verify everything works"

# CI tasks
ci: format-check lint test
	@echo "All CI checks passed!"

# Help
help:
	@echo "Available commands:"
	@echo "  setup       - Set up development environment"
	@echo "  test        - Run all tests"
	@echo "  test-watch  - Run tests in watch mode"
	@echo "  lint        - Run luacheck linter"  
	@echo "  format      - Format code with stylua"
	@echo "  format-check- Check if code is formatted"
	@echo "  install-dev - Install development dependencies"
	@echo "  clean       - Clean up cache files"
	@echo "  ci          - Run all CI checks"
	@echo "  help        - Show this help"