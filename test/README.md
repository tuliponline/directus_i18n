# Test Configuration

## Environment Variables

To run integration tests that connect to a real Directus instance, you need to set up environment variables.

### Option 1: Using .env file

Create a `.env` file in the project root:

```env
DIRECTUS_BASE_URL=https://your-directus-instance.com
DIRECTUS_ACCESS_TOKEN=your-access-token
```

### Option 2: Using environment variables

Set environment variables in your shell:

```bash
export DIRECTUS_BASE_URL="https://your-directus-instance.com"
export DIRECTUS_ACCESS_TOKEN="your-access-token"
```

## Test Files

### Unit Tests (No Directus Connection Required)

- `directus_i18n_test.dart` - Tests for DirectusI18nService
- `error_code_test.dart` - Tests for ErrorCode model and service
- `com10003_test.dart` - Specific test for COM10003 error code

### Integration Tests (Requires Directus Connection)

- `simple_integration_test.dart` - Basic integration tests
- `show_real_errors.dart` - Display real error messages from Directus
- `test_custom_fallback.dart` - Test custom fallback messages
- `test_fallback_with_code.dart` - Test fallback messages with error codes
- `test_missing_code.dart` - Test handling of missing error codes

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Unit Tests Only
```bash
flutter test test/directus_i18n_test.dart
flutter test test/error_code_test.dart
flutter test test/com10003_test.dart
```

### Run Integration Tests
```bash
# Set environment variables first
export DIRECTUS_BASE_URL="https://your-directus-instance.com"
export DIRECTUS_ACCESS_TOKEN="your-access-token"

# Then run integration tests
flutter test test/simple_integration_test.dart
flutter test test/show_real_errors.dart
flutter test test/test_custom_fallback.dart
flutter test test/test_fallback_with_code.dart
flutter test test/test_missing_code.dart
```

## Test Configuration

The test files use placeholder values by default:

- `baseUrl: 'https://your-directus-instance.com'`
- `accessToken: 'your-access-token'`

Replace these with your actual Directus instance details to run integration tests.

## Security Note

⚠️ **Important**: Never commit real access tokens or sensitive URLs to version control. Use environment variables or `.env` files that are excluded from git.
