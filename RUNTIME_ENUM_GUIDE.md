# Runtime Enum Generation Guide

## 🎯 Overview

Runtime Enum Generation allows you to generate enum files in your codebase without needing to release new app versions. This combines the benefits of type safety with the flexibility of dynamic content updates.

## ✅ Benefits

- **No Release Required**: Generate enum files in codebase
- **Type Safety**: Full compile-time checking with enums
- **Shorebird Compatible**: Can be patched using Shorebird
- **Auto-Generation**: Automatically generates enums at app startup
- **Hybrid Approach**: Combines enum + dynamic fallback

## 🚀 Quick Start

### 1. Initialize Runtime Enum Generation

```dart
import 'package:directus_i18n/directus_i18n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hybrid I18n Service (auto-generates enum)
  await HybridI18nService.init(
    baseUrl: 'https://your-directus-instance.com',
    accessToken: 'your-access-token',
    collectionName: 'app_contents',
    enumName: 'AutoI18nKeys',
    autoGenerateEnum: true,
    enableDynamicFallback: true,
  );
  
  runApp(MyApp());
}
```

### 2. Use Generated Enums

```dart
// The enum is automatically generated in lib/generated/AutoI18nKeys.dart
// You can use it like any other enum:

Text(AutoI18nKeys.welcome.translate())
Text(AutoI18nKeys.welcomeUser.translate(params: {'name': 'John'}))

// Or use the hybrid service for maximum flexibility:
Text(HybridI18nService.translate('welcome'))
Text('welcome'.tr()) // Dynamic extension
```

## 🔧 Configuration Options

### AutoEnumService

```dart
await AutoEnumService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_contents',
  enumName: 'AutoI18nKeys',
  autoGenerate: true, // Auto-generate on startup
  checkInterval: Duration(hours: 1), // Check for updates
);
```

### HybridI18nService

```dart
await HybridI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_contents',
  enumName: 'HybridI18nKeys',
  autoGenerateEnum: true, // Generate enum files
  enableDynamicFallback: true, // Enable dynamic fallback
);
```

## 📁 Generated Files Structure

```
lib/
├── generated/
│   ├── AutoI18nKeys.dart          # Generated enum file
│   └── runtime_i18n_keys.dart     # Runtime generated enum
└── src/
    └── i18n_keys.dart             # Original enum (if exists)
```

## 🔄 Workflow

### 1. Content Team Workflow

1. **Add content in Directus CMS**
   - Add new translation keys
   - Set translations for all languages
   - Publish the content

2. **Enum is automatically generated**
   - App startup checks for new content
   - Generates updated enum file
   - Stores in `lib/generated/` directory

3. **Keys are immediately available**
   - No code generation needed
   - No app release required
   - Type-safe enum usage

### 2. Developer Workflow

1. **Use generated enums**
   ```dart
   Text(AutoI18nKeys.newKey.translate())
   ```

2. **Or use hybrid approach**
   ```dart
   Text(HybridI18nService.translate('new_key'))
   ```

3. **Force regeneration if needed**
   ```dart
   await AutoEnumService.forceRegenerate(/* config */);
   ```

## 🛠️ Advanced Usage

### Manual Enum Generation

```dart
// Generate enum manually
await RuntimeEnumGenerator.generateAndStore(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_contents',
  enumName: 'ManualI18nKeys',
);
```

### Check Enum Status

```dart
// Check if generated enum exists
bool hasEnum = AutoEnumService.hasGeneratedEnum();

// Get enum file info
Map<String, dynamic> info = AutoEnumService.getEnumInfo();
print('Enum path: ${info['path']}');
print('Last modified: ${info['lastModified']}');
```

### Hybrid Translation

```dart
// Hybrid service tries enum first, then dynamic
String translation = HybridI18nService.translate(
  'welcome',
  fallback: 'Welcome!',
  params: {'name': 'John'},
);
```

### Force Refresh

```dart
// Force regenerate enum and refresh dynamic cache
await HybridI18nService.refresh();
```

## 📋 Script Usage

### Auto Generate Script

```bash
# Run the auto-generation script
dart run scripts/auto_generate_enum.dart

# This will:
# 1. Fetch keys from Directus
# 2. Generate enum file in lib/generated/
# 3. Make keys available without app release
```

### Environment Variables

Create `.env` file:
```bash
DIRECTUS_BASE_URL=https://your-directus.com
DIRECTUS_ACCESS_TOKEN=your-token
DIRECTUS_COLLECTION_NAME=app_contents
I18N_ENUM_NAME=AutoI18nKeys
```

## 🚀 Shorebird Integration

### What Can Be Patched

✅ **Can Patch:**
- Generated enum files in `lib/generated/`
- Translation values (text content)
- UI layout changes
- New enum usage in code

❌ **Cannot Patch:**
- Core service initialization changes
- API endpoint changes
- Major structural changes

### Patch Workflow

1. **Update translations in Directus**
2. **Regenerate enum files**
   ```bash
   dart run scripts/auto_generate_enum.dart
   ```
3. **Update Flutter code to use new keys**
4. **Create Shorebird patch**
   ```bash
   shorebird patch android
   shorebird patch ios
   ```

## 📊 Performance Considerations

### File Generation
- Enum files generated once at startup
- Cached for app session
- Minimal performance impact

### Memory Usage
- Generated enums loaded into memory
- Dynamic cache for fallback
- Typical usage: ~2-10MB for 1000+ keys

### Network Usage
- Single API call at startup
- Optional refresh on demand
- Minimal network impact

## 🧪 Testing

### Unit Tests

```dart
void main() {
  group('Runtime Enum Tests', () {
    setUp(() {
      // Mock the service
      AutoEnumService.init(/* mock config */);
    });

    test('should generate enum file', () async {
      await RuntimeEnumGenerator.generateAndStore(/* config */);
      expect(AutoEnumService.hasGeneratedEnum(), isTrue);
    });

    test('should load generated enum', () {
      expect(AutoEnumService.getGeneratedEnumPath(), isNotEmpty);
    });
  });
}
```

### Integration Tests

```dart
void main() {
  group('Hybrid I18n Integration', () {
    testWidgets('should use generated enum', (tester) async {
      await HybridI18nService.init(/* config */);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Text(HybridI18nService.translate('welcome')),
        ),
      );
      
      expect(find.text('Welcome!'), findsOneWidget);
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
// Get comprehensive status
Map<String, dynamic> status = HybridI18nService.getStatus();
print('Status: $status');
```

### Manual Enum Inspection

```dart
// Check generated enum file
String path = AutoEnumService.getGeneratedEnumPath();
File file = File(path);
if (file.existsSync()) {
  String content = await file.readAsString();
  print('Enum content: $content');
}
```

## 📚 Best Practices

### 1. File Organization
```
lib/
├── generated/           # Generated enum files
│   └── AutoI18nKeys.dart
├── src/                # Source code
└── i18n/               # I18n configuration
```

### 2. Git Integration
```bash
# Add generated files to git
git add lib/generated/
git commit -m "chore: update generated i18n enum"

# Or ignore them (regenerate on build)
echo "lib/generated/" >> .gitignore
```

### 3. CI/CD Integration
```yaml
# .github/workflows/build.yml
steps:
  - name: Generate I18n Enum
    run: dart run scripts/auto_generate_enum.dart
  
  - name: Build App
    run: flutter build apk
```

### 4. Error Handling
```dart
// Handle enum generation failures gracefully
try {
  await AutoEnumService.init(/* config */);
} catch (e) {
  // Fall back to dynamic translation
  Logger().w('Enum generation failed, using dynamic fallback: $e');
}
```

## 🆘 Troubleshooting

### Common Issues

**Q: Enum not generating**
A: Check Directus connection and access token

**Q: Generated enum not updating**
A: Call `AutoEnumService.forceRegenerate()`

**Q: Performance issues**
A: Enable caching and limit generation frequency

**Q: Missing keys in generated enum**
A: Ensure keys are published in Directus

### Debug Commands

```dart
// Check service status
print('Status: ${HybridI18nService.getStatus()}');

// Force regenerate
await AutoEnumService.forceRegenerate(/* config */);

// Check generated files
print('Generated path: ${AutoEnumService.getGeneratedEnumPath()}');
```

## 🔗 Related Resources

- [Dynamic I18n Guide](DYNAMIC_I18N_GUIDE.md)
- [Directus Documentation](https://docs.directus.io)
- [Shorebird Documentation](https://shorebird.dev)
- [Example App](example/runtime_enum_example.dart)
