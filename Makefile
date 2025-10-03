# Directus I18n Package Makefile

.PHONY: help sync-keys test clean install example

# Default target
help:
	@echo "🚀 Directus I18n Package Commands:"
	@echo ""
	@echo "  make sync-keys    - Generate I18nKeys from Directus CMS"
	@echo "  make test         - Run all tests"
	@echo "  make install      - Install dependencies"
	@echo "  make example      - Run example app"
	@echo "  make clean        - Clean build files"
	@echo "  make watch-keys   - Watch and auto-regenerate keys (requires fswatch)"
	@echo ""

# Generate I18n keys from Directus
sync-keys:
	@echo "📝 Syncing I18n keys from Directus..."
	@dart run example/generate_keys.dart
	@echo "✅ Keys synced successfully!"

# Run tests
test:
	@echo "🧪 Running tests..."
	@flutter test
	@echo "✅ All tests passed!"

# Install dependencies
install:
	@echo "📦 Installing dependencies..."
	@flutter pub get
	@cd example && flutter pub get
	@echo "✅ Dependencies installed!"

# Run example app
example:
	@echo "🚀 Running example app..."
	@cd example && flutter run

# Clean build files
clean:
	@echo "🧹 Cleaning build files..."
	@flutter clean
	@cd example && flutter clean
	@rm -rf .dart_tool
	@rm -rf example/.dart_tool
	@echo "✅ Clean complete!"

# Watch for Directus changes and auto-regenerate (requires fswatch)
watch-keys:
	@echo "👀 Watching for Directus changes..."
	@echo "Press Ctrl+C to stop"
	@while true; do \
		dart run example/generate_keys.dart; \
		echo "Waiting 60 seconds before next sync..."; \
		sleep 60; \
	done

# Quick setup for new project
setup:
	@echo "🔧 Setting up Directus I18n package..."
	@make install
	@make sync-keys
	@make test
	@echo "✅ Setup complete! Package is ready to use."

