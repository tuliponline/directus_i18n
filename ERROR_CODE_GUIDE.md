# Error Code Management Guide

## 🎯 Overview

Simple Error Code Management allows you to manage error codes and their multilingual messages from Directus CMS, separate from your main i18n content. This provides centralized error handling with localized messages.

## ✨ Features

- 🌍 **Centralized Error Management** - Manage all error codes in Directus
- 🔄 **Dynamic Loading** - Load error codes at runtime without app updates
- 📝 **Multilingual Messages** - Support for multiple languages
- 🎯 **Simple Structure** - Just code and message
- 🧪 **Fully Testable** - Mock support for unit and widget tests

## 🚀 Quick Start

### 1. Setup Error Code Collection in Directus

Create a new collection called `error_codes` with these fields:

```json
{
  "code": "string",           // Error code (e.g., "NETWORK_ERROR")
  "message": "text",          // Default error message
  "status": "string",         // published, draft
  "translations": "relation"  // Translations relation
}
```

### 2. Initialize Error Code Service

```dart
import 'package:directus_i18n/directus_i18n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Error Code Service
  await ErrorCodeService.init(
    baseUrl: 'https://your-directus-instance.com',
    accessToken: 'your-access-token',
    collectionName: 'error_codes',
    autoLoad: true,
  );
  
  runApp(MyApp());
}
```

### 3. Use Error Codes

```dart
// Method 1: String Extension
Text('NETWORK_ERROR'.getErrorMessage())
Text('AUTH_FAILED'.getErrorMessage())
Text('VALIDATION_ERROR'.getErrorMessage(parameters: {'field': 'email'}))

// Method 2: Context Extension
Text(context.getErrorMessage('NETWORK_ERROR'))
Text(context.getErrorMessage('AUTH_FAILED'))

// Method 3: Direct Service
final errorCode = ErrorCodeService.getErrorCode('NETWORK_ERROR');
if (errorCode != null) {
  Text(errorCode.displayMessage())
}
```

## 🔧 Configuration

### Environment Variables

```bash
# .env
DIRECTUS_BASE_URL=https://your-directus.com
DIRECTUS_ACCESS_TOKEN=your-token
ERROR_CODES_COLLECTION_NAME=error_codes
```

### Service Configuration

```dart
await ErrorCodeService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'error_codes',
  autoLoad: true, // Load error codes on initialization
);
```

## 📱 Usage Examples

### 1. String Extension (Easiest)

```dart
// Get error message
Text('NETWORK_ERROR'.getErrorMessage())

// Get error message with parameters
Text('VALIDATION_ERROR'.getErrorMessage(
  parameters: {'field': 'email', 'minLength': '8'}
))

// Check if error code exists
if ('NETWORK_ERROR'.isErrorCode) {
  // Handle error
}
```

### 2. Context Extension

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(context.getErrorMessage('NETWORK_ERROR')),
        Text(context.getErrorMessage('AUTH_FAILED')),
        Text(context.getErrorMessage('VALIDATION_ERROR')),
      ],
    );
  }
}
```

### 3. ErrorCodeWidget

```dart
// Basic error display
ErrorCodeWidget('NETWORK_ERROR')

// With custom styling
ErrorCodeWidget(
  'VALIDATION_ERROR',
  parameters: {'field': 'email'},
  showCode: true,
  textStyle: TextStyle(fontSize: 16),
)

// Error message widget
ErrorMessageWidget('AUTH_FAILED')

// Error card
ErrorCardWidget(
  'NETWORK_ERROR',
  parameters: {'retryCount': '3'},
  showCode: true,
)
```

### 4. Error List

```dart
// Display list of errors
ErrorListWidget(
  ['NETWORK_ERROR', 'AUTH_FAILED', 'VALIDATION_ERROR'],
  parameters: {
    'VALIDATION_ERROR': {'field': 'email'},
  },
  showCode: true,
)
```

## 🌍 Multilingual Support

### Language Management

```dart
// Get all available languages
final languages = ErrorCodeService.getAllAvailableLanguages();
print('Available languages: $languages');

// Get error codes with specific language
final thaiErrors = ErrorCodeService.getErrorCodesWithLanguage('th');

// Check if error code has translation for specific language
final hasThai = errorCode.hasTranslationFor('th');
```

## 🔄 Advanced Usage

### Custom Error Handling

```dart
class ErrorHandler {
  static void handleError(String errorCode, {Map<String, String>? params}) {
    final errorCodeObj = ErrorCodeService.getErrorCode(errorCode);
    if (errorCodeObj == null) {
      // Handle unknown error
      return;
    }

    // Show error message
    final message = errorCodeObj.displayMessage(parameters: params);
    _showError(message);
  }

  static void _showError(String message) {
    // Show error dialog or snackbar
  }
}
```

### Exception Integration

```dart
// Custom exception with error code
class AppException implements Exception {
  final String errorCode;
  final Map<String, String>? parameters;

  AppException(this.errorCode, {this.parameters});

  @override
  String toString() {
    return ErrorCodeService.getLocalizedMessage(
      errorCode,
      parameters: parameters,
    );
  }
}

// Usage
try {
  // Some operation
} catch (e) {
  if (e is AppException) {
    // Get localized error message
    final message = e.getLocalizedErrorMessage();
    showErrorDialog(message);
  }
}
```

### Search and Filter

```dart
// Search error codes
final searchResults = ErrorCodeService.searchErrorCodes('network');

// Get error statistics
final stats = ErrorCodeService.getErrorCodesStatistics();
print('Total errors: ${stats['total']}');
print('Critical errors: ${stats['severity_critical']}');
print('Network errors: ${stats['category_network']}');
```

## 🧪 Testing

### Unit Tests

```dart
void main() {
  group('Error Code Tests', () {
    setUp(() {
      // Mock the service
      ErrorCodeService.init(
        baseUrl: 'https://mock-directus.com',
        accessToken: 'mock-token',
        autoLoad: false,
      );
    });

    test('should get error message', () {
      expect('NETWORK_ERROR'.getErrorMessage(), equals('Network connection failed'));
    });

    test('should get error with parameters', () {
      expect(
        'VALIDATION_ERROR'.getErrorMessage(parameters: {'field': 'email'}),
        equals('Email validation failed'),
      );
    });

    test('should check error code existence', () {
      expect('NETWORK_ERROR'.isErrorCode, isTrue);
      expect('UNKNOWN_ERROR'.isErrorCode, isFalse);
    });
  });
}
```

### Widget Tests

```dart
void main() {
  group('Error Code Widget Tests', () {
    testWidgets('should display error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorCodeWidget('NETWORK_ERROR'),
        ),
      );
      
      expect(find.text('Network connection failed'), findsOneWidget);
    });

    testWidgets('should display error with severity', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorMessageWidget('AUTH_FAILED'),
        ),
      );
      
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
```

## 🔍 Debugging

### Enable Debug Logging

```dart
// Enable detailed logging
Logger.level = Level.debug;
```

### Check Service Status

```dart
// Get service status
Map<String, dynamic> status = ErrorCodeService.getStatus();
print('Status: $status');

// Check if error code exists
bool exists = ErrorCodeService.hasErrorCode('NETWORK_ERROR');
print('Error code exists: $exists');

// Get error codes count
int count = ErrorCodeService.getErrorCodesCount();
print('Total error codes: $count');
```

## 📋 Scripts

### Sync Error Codes

```bash
# Sync error codes from Directus
dart run scripts/sync_error_codes.dart
```

### Environment Variables

```bash
# .env
DIRECTUS_BASE_URL=https://your-directus.com
DIRECTUS_ACCESS_TOKEN=your-token
ERROR_CODES_COLLECTION_NAME=error_codes
```

## 🚀 Shorebird Integration

### What Can Be Patched

✅ **Can Patch:**
- Error code messages and translations
- Error severity and category changes
- New error codes
- Error code parameters

❌ **Cannot Patch:**
- Core service initialization changes
- API endpoint changes
- Major structural changes

### Patch Workflow

1. **Update error codes in Directus**
2. **Refresh error codes in app**
   ```dart
   await ErrorCodeService.refresh();
   ```
3. **Create Shorebird patch**
   ```bash
   shorebird patch android
   shorebird patch ios
   ```

## 📚 Best Practices

### 1. Error Code Naming

```dart
// Use UPPER_SNAKE_CASE
'NETWORK_ERROR'
'AUTH_FAILED'
'VALIDATION_ERROR'
'PAYMENT_DECLINED'
```

### 2. Parameter Naming

```dart
// Use descriptive parameter names
'VALIDATION_ERROR'.getErrorMessage(parameters: {
  'field': 'email',
  'minLength': '8',
  'maxLength': '50',
})
```

### 3. Error Handling Strategy

```dart
// Centralized error handling
class ErrorManager {
  static void handleError(String errorCode, {Map<String, String>? params}) {
    final errorCodeObj = ErrorCodeService.getErrorCode(errorCode);
    if (errorCodeObj == null) {
      // Log unknown error
      Logger().e('Unknown error code: $errorCode');
      return;
    }

    // Handle based on severity
    _handleBySeverity(errorCodeObj, params);
  }

  static void _handleBySeverity(ErrorCode errorCode, Map<String, String>? params) {
    // Implementation based on severity
  }
}
```

### 4. Testing Strategy

```dart
// Mock error codes for testing
class MockErrorCodeService {
  static void setupMockErrorCodes() {
    // Setup mock error codes
  }
}
```

## 🆘 Troubleshooting

### Common Issues

**Q: Error codes not loading**
A: Check Directus connection and access token

**Q: Translations not working**
A: Ensure translations are published in Directus

**Q: Error codes not updating**
A: Call `ErrorCodeService.refresh()`

**Q: Performance issues**
A: Enable caching and limit refresh frequency

### Debug Commands

```dart
// Check service status
print('Status: ${ErrorCodeService.getStatus()}');

// Search error codes
print('Search results: ${ErrorCodeService.searchErrorCodes('network')}');

// Get statistics
print('Statistics: ${ErrorCodeService.getErrorCodesStatistics()}');
```

## 🔗 Related Resources

- [Integration Guide](INTEGRATION_GUIDE.md)
- [Runtime Enum Guide](RUNTIME_ENUM_GUIDE.md)
- [Dynamic I18n Guide](DYNAMIC_I18N_GUIDE.md)
- [Example App](example/error_code_example.dart)
- [Directus Documentation](https://docs.directus.io)
