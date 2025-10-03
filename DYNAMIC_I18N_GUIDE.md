# Dynamic I18n Guide

## 🎯 Overview

Dynamic I18n allows you to add new translation keys in Directus without needing to generate enum files or release new app versions. This is perfect for content teams who need to add new text frequently.

## ✅ Benefits

- **No Release Required**: Add new keys without app store updates
- **Shorebird Compatible**: Can be patched using Shorebird
- **Type Safe**: Still provides compile-time checking
- **Easy Migration**: Gradual migration from enum-based system
- **Real-time Updates**: Keys can be refreshed at runtime

## 🚀 Quick Start

### 1. Initialize Dynamic I18n

```dart
import 'package:directus_i18n/directus_i18n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Dynamic I18n Service
  await DynamicI18nService.init(
    baseUrl: 'https://your-directus-instance.com',
    accessToken: 'your-access-token',
    collectionName: 'app_contents',
  );
  
  runApp(MyApp());
}
```

### 2. Use Dynamic Translations

```dart
// Method 1: String extension
Text('welcome'.tr())
Text('welcome_user'.tr(params: {'name': 'John'}))
Text('nonexistent_key'.tr(fallback: 'Fallback text'))

// Method 2: Context extension
Text(context.tr('welcome'))
Text(context.tr('welcome_user', params: {'name': 'Jane'}))

// Method 3: DynamicI18nText widget
DynamicI18nText('welcome')
DynamicI18nText(
  'welcome_user',
  params: {'name': 'Bob'},
  style: TextStyle(fontWeight: FontWeight.bold),
)

// Method 4: DynamicI18nButton
DynamicI18nButton(
  'login',
  onPressed: () => print('Login pressed'),
)
```

## 🔄 Migration from Enum-based System

### Before (Enum-based)
```dart
// Old way with generated enum
Text(I18nKeys.welcome.translate())
Text(I18nKeys.welcomeUser.translate(
  translationParams: {'name': 'John'},
))
```

### After (Dynamic)
```dart
// New way with dynamic keys
Text('welcome'.tr())
Text('welcome_user'.tr(params: {'name': 'John'}))
```

### Gradual Migration Strategy

1. **Phase 1**: Keep existing enum system, add dynamic for new keys
2. **Phase 2**: Migrate high-frequency keys to dynamic
3. **Phase 3**: Remove enum generation, use only dynamic

## 📋 Workflow for Content Teams

### Adding New Keys

1. **Add content in Directus CMS**
   - Go to your Directus admin
   - Add new content item
   - Set translations for all languages
   - Publish the content

2. **Keys are automatically available**
   - No code generation needed
   - No app release required
   - Keys available immediately

3. **Use in Flutter code**
   ```dart
   // New key is immediately available
   Text('new_feature_title'.tr())
   ```

### Updating Existing Keys

1. **Update content in Directus**
2. **Refresh keys in app** (optional, will auto-refresh on next app start)
   ```dart
   await DynamicI18nService.refreshKeys();
   ```

## 🛠️ Advanced Usage

### Custom Fallback Strategy

```dart
String translateWithCustomFallback(String key) {
  return key.tr(fallback: 'Key not found: $key');
}
```

### Key Validation

```dart
if ('welcome'.hasTranslation) {
  Text('welcome'.tr())
} else {
  Text('Welcome!') // Fallback UI
}
```

### Batch Translation

```dart
List<String> keys = ['welcome', 'login', 'register'];
Map<String, String> translations = {};

for (String key in keys) {
  translations[key] = key.tr();
}
```

### Error Handling

```dart
String safeTranslate(String key) {
  try {
    return key.tr();
  } catch (e) {
    return 'Translation error: $key';
  }
}
```

## 🔧 Configuration

### Environment Variables

Create `.env` file:
```bash
DIRECTUS_BASE_URL=https://your-directus.com
DIRECTUS_ACCESS_TOKEN=your-token
DIRECTUS_COLLECTION_NAME=app_contents
```

### Custom Configuration

```dart
await DynamicI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_contents',
  cacheEnabled: true, // Enable/disable caching
);
```

## 🚀 Shorebird Integration

### What Can Be Patched

✅ **Can Patch:**
- Translation values (text content)
- UI layout changes
- New dynamic key usage
- Fallback text updates

❌ **Cannot Patch:**
- New enum cases (not applicable with dynamic system)
- Core service initialization changes
- API endpoint changes

### Patch Workflow

1. **Update translations in Directus**
2. **Update Flutter code to use new keys**
3. **Create Shorebird patch**
4. **Deploy patch to users**

```bash
# Example patch workflow
shorebird patch android
shorebird patch ios
```

## 📊 Performance Considerations

### Caching
- Keys are cached in memory after first load
- Use `DynamicI18nService.refreshKeys()` to update cache
- Cache persists for app session

### Network Usage
- Keys loaded once on app start
- Optional refresh on demand
- Minimal network impact

### Memory Usage
- Keys stored in memory as Map<String, String>
- Typical usage: ~1-5MB for 1000+ keys
- Automatic cleanup on app restart

## 🧪 Testing

### Unit Tests

```dart
void main() {
  group('Dynamic I18n Tests', () {
    setUp(() {
      DynamicI18nService.clearCache();
    });

    test('should translate existing key', () {
      // Mock the service
      DynamicI18nService.init(/* mock config */);
      
      expect('welcome'.tr(), equals('Welcome!'));
    });

    test('should use fallback for missing key', () {
      expect(
        'missing_key'.tr(fallback: 'Fallback'),
        equals('Fallback'),
      );
    });
  });
}
```

### Integration Tests

```dart
void main() {
  group('Dynamic I18n Integration', () {
    testWidgets('should display translated text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DynamicI18nText('welcome'),
        ),
      );
      
      expect(find.text('Welcome!'), findsOneWidget);
    });
  });
}
```

## 🔍 Debugging

### Enable Debug Mode

```dart
// Show keys instead of translations
I18nKey.isDisplayContentKey = true;
```

### Logging

```dart
// Enable detailed logging
Logger.level = Level.debug;
```

### Key Validation

```dart
// Check if key exists
print('Key exists: ${'welcome'.hasTranslation}');

// Get all available keys
print('Available keys: ${DynamicI18nService.getAllKeys()}');
```

## 📚 Best Practices

### 1. Key Naming Convention
```dart
// Use snake_case for keys
'welcome_message'.tr()
'user_profile_title'.tr()
'button_save_changes'.tr()
```

### 2. Parameter Naming
```dart
// Use descriptive parameter names
'welcome_user'.tr(params: {'user_name': 'John'})
'item_count'.tr(params: {'count': '5'})
```

### 3. Fallback Strategy
```dart
// Always provide meaningful fallbacks
'complex_key'.tr(fallback: 'Simple fallback text')
```

### 4. Error Handling
```dart
// Handle missing keys gracefully
String getTranslation(String key) {
  if (key.hasTranslation) {
    return key.tr();
  } else {
    // Log missing key for debugging
    Logger().w('Missing translation key: $key');
    return 'Missing: $key';
  }
}
```

## 🆘 Troubleshooting

### Common Issues

**Q: Keys not loading**
A: Check Directus connection and access token

**Q: Translations not updating**
A: Call `DynamicI18nService.refreshKeys()`

**Q: Performance issues**
A: Enable caching and limit key refresh frequency

**Q: Missing keys in production**
A: Ensure keys are published in Directus

### Debug Commands

```dart
// Check service status
print('Service initialized: ${DynamicI18nService._isInitialized}');

// List all keys
print('Keys: ${DynamicI18nService.getAllKeys()}');

// Check specific key
print('Key exists: ${DynamicI18nService.hasKey('welcome')}');
```

## 🔗 Related Resources

- [Directus Documentation](https://docs.directus.io)
- [Shorebird Documentation](https://shorebird.dev)
- [Flutter I18n Package](https://pub.dev/packages/flutter_i18n)
- [Example App](example/dynamic_i18n_example.dart)
