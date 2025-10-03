# 🛡️ Custom Fallback Messages Guide

## Overview

This guide explains how the package handles missing error codes and provides custom fallback messages instead of using the error code itself.

## 🎯 Default Fallback Messages

When an error code is not found in Directus, the package now uses these custom fallback messages with the error code included:

| Language Code | Fallback Message |
|---------------|------------------|
| `th-TH` | `เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ (ERROR_CODE)` |
| `en-US`, `en` | `An unknown error occurred. (ERROR_CODE)` |
| Other languages | `An unknown error occurred. (ERROR_CODE)` |

**Example:**
- Error Code: `COM10004`
- Thai: `เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ (COM10004)`
- English: `An unknown error occurred. (COM10004)`

## 🔧 How It Works

### 1. ErrorCode Model

```dart
// In ErrorCode.getLocalizedMessage()
String getLocalizedMessage({
  String? languageCode,
  Map<String, String>? parameters,
  String? fallback,
}) {
  String messageText = message ?? fallback ?? _getDefaultFallbackMessage(languageCode);
  
  // Try to get translation for specific language
  if (languageCode != null && translations != null && translations!.containsKey(languageCode)) {
    messageText = translations![languageCode]!;
  }
  
  return messageText;
}

// Custom fallback message based on language
String _getDefaultFallbackMessage(String? languageCode) {
  switch (languageCode) {
    case 'th-TH':
      return 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ ($code)';
    case 'en-US':
    case 'en':
      return 'An unknown error occurred. ($code)';
    default:
      return 'An unknown error occurred. ($code)';
  }
}
```

### 2. ErrorCodeService

```dart
// In ErrorCodeService.getLocalizedMessage()
static String getLocalizedMessage(
  String code, {
  String? languageCode,
  Map<String, String>? parameters,
  String? fallback,
}) {
  final errorCode = getErrorCode(code);
  if (errorCode == null) {
    return fallback ?? _getDefaultFallbackMessage(languageCode, code);
  }

  return errorCode.getLocalizedMessage(
    languageCode: languageCode,
    parameters: parameters,
    fallback: fallback,
  );
}
```

## 📱 Usage Examples

### 1. Basic Usage

```dart
// Initialize service
await ErrorCodeService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'error',
);

// Missing error code - uses custom fallback with error code
String thaiMessage = 'COM10004'.getErrorMessage(languageCode: 'th-TH');
// Returns: "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ (COM10004)"

String englishMessage = 'COM10004'.getErrorMessage(languageCode: 'en-US');
// Returns: "An unknown error occurred. (COM10004)"

// Default (no language) - uses English fallback
String defaultMessage = 'COM10004'.getErrorMessage();
// Returns: "An unknown error occurred. (COM10004)"
```

### 2. Error Handling Pattern

```dart
void handleUserError(String errorCode, String userLanguage) {
  final error = ErrorCodeService.getErrorCode(errorCode);
  final message = errorCode.getErrorMessage(languageCode: userLanguage);
  
  if (error == null) {
    // Error code not found - using fallback message with error code
    print('Missing error code: $errorCode');
    print('Fallback message: $message'); // Includes error code for debugging
    
    // Log for debugging
    logMissingErrorCode(errorCode);
    
    // Show generic error dialog with error code visible
    showErrorDialog(message);
  } else {
    // Error code found - use specific details
    showSpecificErrorDialog(error);
  }
}
```

### 3. Custom Fallback Override

```dart
// You can still override with custom fallback
String customMessage = ErrorCodeService.getLocalizedMessage(
  'COM10004',
  languageCode: 'th-TH',
  fallback: 'ข้อความ fallback ที่กำหนดเอง',
);
// Returns: "ข้อความ fallback ที่กำหนดเอง"
```

### 4. Error Dialog Implementation

```dart
void showErrorDialog(String errorCode, String languageCode) {
  final error = ErrorCodeService.getErrorCode(errorCode);
  
  String title;
  String message;
  String actionText;
  
  if (error != null) {
    // Use specific error details
    title = error.title ?? error.code;
    message = error.getLocalizedMessage(languageCode: languageCode);
    actionText = error.actionText ?? 'ตกลง';
  } else {
    // Use fallback message with error code
    title = languageCode == 'th-TH' ? 'ข้อผิดพลาด' : 'Error';
    message = errorCode.getErrorMessage(languageCode: languageCode); // Includes error code
    actionText = languageCode == 'th-TH' ? 'ตกลง' : 'OK';
  }
  
  // Show dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(actionText),
        ),
      ],
    ),
  );
}
```

## 🧪 Testing

### Test Custom Fallback Messages

```dart
test('should use custom fallback messages for missing error codes', () async {
  await ErrorCodeService.init(
    baseUrl: 'https://your-directus.com',
    accessToken: 'your-token',
    collectionName: 'error',
    autoLoad: true,
  );

  // Test missing error codes
  final thaiMessage = 'COM10004'.getErrorMessage(languageCode: 'th-TH');
  expect(thaiMessage, 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ (COM10004)');
  
  final englishMessage = 'COM10004'.getErrorMessage(languageCode: 'en-US');
  expect(englishMessage, 'An unknown error occurred. (COM10004)');
  
  final defaultMessage = 'COM10004'.getErrorMessage();
  expect(defaultMessage, 'An unknown error occurred. (COM10004)');
});
```

### Run Tests

```bash
# Test fallback messages with error codes
flutter test test/test_fallback_with_code.dart

# Test custom fallback messages
flutter test test/test_custom_fallback.dart

# Test missing error code handling
flutter test test/test_missing_code.dart
```

## 🎨 Example App

Check out the complete example app that demonstrates fallback messages:

```bash
# Run the example app
cd example
flutter run fallback_message_example.dart
```

The example app shows:
- ✅ Existing error codes (with specific messages)
- ❌ Missing error codes (with fallback messages including error codes)
- 🌐 Language switching (Thai/English)
- 📊 Service status information

## 🔄 Migration from Old Behavior

### Before (Using Error Code as Fallback)

```dart
// Old behavior
String message = 'COM10004'.getErrorMessage();
// Returns: "COM10004"
```

### After (Using Custom Fallback Messages with Error Code)

```dart
// New behavior
String message = 'COM10004'.getErrorMessage();
// Returns: "An unknown error occurred. (COM10004)"

String thaiMessage = 'COM10004'.getErrorMessage(languageCode: 'th-TH');
// Returns: "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ (COM10004)"
```

## 🎯 Benefits

1. **Better User Experience**: Users see meaningful error messages with error codes for debugging
2. **Multi-language Support**: Fallback messages are localized with error codes
3. **Consistent Messaging**: All missing error codes use the same fallback format
4. **Developer Friendly**: Error codes are visible for debugging while still being user-friendly
5. **Debugging Support**: Error codes are included in fallback messages for easier troubleshooting
6. **Backward Compatible**: Existing code continues to work

## 🔧 Customization

If you want to customize the fallback messages, you can:

1. **Override in method calls**:
   ```dart
   String message = ErrorCodeService.getLocalizedMessage(
     'COM10004',
     languageCode: 'th-TH',
     fallback: 'Your custom fallback message',
   );
   ```

2. **Modify the source code** (if you have access):
   ```dart
   String _getDefaultFallbackMessage(String? languageCode) {
     switch (languageCode) {
       case 'th-TH':
         return 'ข้อความ fallback ที่กำหนดเอง ($code)';
       case 'en-US':
         return 'Your custom fallback message ($code)';
       default:
         return 'Your custom fallback message ($code)';
     }
   }
   ```

## 📝 Best Practices

1. **Always handle missing error codes gracefully**
2. **Use appropriate language codes** (`th-TH`, `en-US`, etc.)
3. **Log missing error codes** for debugging purposes
4. **Provide fallback UI** for unknown errors
5. **Test with both existing and missing error codes**
6. **Leverage error codes in fallback messages** for debugging
7. **Consider user experience** while maintaining debugging capabilities

## 🚀 Next Steps

1. Update your error handling code to use the new fallback messages with error codes
2. Test with your existing error codes
3. Add missing error codes to your Directus instance
4. Consider implementing error reporting for missing codes
5. Update your UI to handle both specific and generic error messages
6. Take advantage of error codes in fallback messages for debugging
7. Monitor and log missing error codes for future improvements
