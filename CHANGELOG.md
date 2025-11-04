# Changelog

All notable changes to this project will be documented in this file.

## [1.0.5] - 2025-01-XX

### Fixed
- Fixed HybridI18nService to support multiple languages properly
- Fixed translation selection based on current locale from BuildContext
- Changed cache structure to support multi-language translations: `Map<String, Map<String, String>>`
- Improved locale detection with fallback to language code only if full locale not found
- Added support for locale format normalization (th-TH, th_TH, th)

### Added
- Added `hasKeyForLanguage()` method to check if key exists for specific language
- Added `refreshDynamicCache()` method with explicit parameters
- Added comprehensive Thai API documentation (API_DOCUMENTATION_TH.md)

### Changed
- Updated `_loadDynamicKeys()` to load all language translations, not just first one
- Updated `_translateDynamic()` to use BuildContext locale for language selection
- Improved error handling in refresh method

## [1.0.0] - 2025-10-01

### Added
- Initial release of directus_i18n package
- DirectusI18nService for easy initialization
- DirectusI18nRepository for loading translations from Directus CMS
- DirectusI18nLoader for FlutterI18n integration
- I18nKey interface for type-safe translation keys
- Extension methods for easy translation usage
- DirectusI18nKeyGenerator for generating enum from Directus
- Support for parameter substitution in translations
- Fallback support for missing translations
- In-memory caching of translations
- Platform channel support for native integration
- Global navigator key support
- Comprehensive test coverage
- Example app demonstrating usage
- Full documentation and README

### Features
- 🌍 Dynamic content loading from Directus CMS
- 🔄 Automatic locale detection
- 💾 In-memory caching
- 🔐 Type-safe translation keys
- 🎯 Fallback support
- 📝 Parameter substitution
- 🧪 Fully testable with mock support

