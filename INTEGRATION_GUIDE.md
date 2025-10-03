# Integration Guide - การนำไปใช้กับ Project อื่น

## 🎯 Overview

คู่มือนี้จะสอนวิธีการนำ Runtime Enum Generation ไปใช้กับ Flutter project อื่นๆ โดยไม่ต้องแก้ไข codebase เดิมมาก

## 📋 Prerequisites

- Flutter project ที่มีอยู่แล้ว
- Directus CMS instance
- Access token สำหรับ Directus

## 🚀 Step-by-Step Integration

### Step 1: Add Package Dependency

#### วิธีที่ 1: Local Package (แนะนำสำหรับ development)

```yaml
# pubspec.yaml
dependencies:
  directus_i18n:
    path: ../directus_i18n  # หรือ path ไปยัง package
```

#### วิธีที่ 2: Git Dependency

```yaml
# pubspec.yaml
dependencies:
  directus_i18n:
    git:
      url: https://github.com/your-org/directus_i18n.git
      ref: main
```

#### วิธีที่ 3: Pub.dev (เมื่อ publish แล้ว)

```yaml
# pubspec.yaml
dependencies:
  directus_i18n: ^1.0.0
```

### Step 2: Create Environment Configuration

สร้างไฟล์ `.env` ใน root ของ project:

```bash
# .env
DIRECTUS_BASE_URL=https://your-directus-instance.com
DIRECTUS_ACCESS_TOKEN=your-access-token
DIRECTUS_COLLECTION_NAME=app_contents
I18N_ENUM_NAME=ProjectI18nKeys
```

### Step 3: Initialize in main.dart

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Hybrid I18n Service
  await HybridI18nService.init(
    baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
    accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
    collectionName: dotenv.env['DIRECTUS_COLLECTION_NAME'] ?? 'app_contents',
    enumName: dotenv.env['I18N_ENUM_NAME'] ?? 'ProjectI18nKeys',
    autoGenerateEnum: true,
    enableDynamicFallback: true,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: HomePage(),
    );
  }
}
```

### Step 4: Add flutter_dotenv Dependency

```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

### Step 5: Create Generated Directory

```bash
# สร้าง directory สำหรับ generated files
mkdir -p lib/generated
```

### Step 6: Add to .gitignore (Optional)

```gitignore
# .gitignore
# Generated i18n files (optional - depends on your workflow)
lib/generated/
```

## 🔧 Configuration Options

### Basic Configuration

```dart
await HybridI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_contents',
  enumName: 'MyAppI18nKeys',
  autoGenerateEnum: true,
  enableDynamicFallback: true,
);
```

### Advanced Configuration

```dart
await HybridI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_contents',
  enumName: 'MyAppI18nKeys',
  autoGenerateEnum: true,
  enableDynamicFallback: true,
);

// Optional: Configure auto enum service separately
await AutoEnumService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_contents',
  enumName: 'MyAppI18nKeys',
  autoGenerate: true,
  checkInterval: Duration(hours: 1),
);
```

## 📱 Usage Examples

### Method 1: Using Generated Enum

```dart
// After initialization, you can use the generated enum
import 'package:your_app/generated/project_i18n_keys.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(ProjectI18nKeys.welcome.translate()),
        Text(ProjectI18nKeys.welcomeUser.translate(
          translationParams: {'name': 'John'},
        )),
      ],
    );
  }
}
```

### Method 2: Using Hybrid Service

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(HybridI18nService.translate('welcome')),
        Text(HybridI18nService.translate(
          'welcome_user',
          params: {'name': 'John'},
        )),
      ],
    );
  }
}
```

### Method 3: Using String Extension

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('welcome'.tr()),
        Text('welcome_user'.tr(params: {'name': 'John'})),
        Text('nonexistent_key'.tr(fallback: 'Fallback text')),
      ],
    );
  }
}
```

### Method 4: Using DynamicI18nText Widget

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DynamicI18nText('welcome'),
        DynamicI18nText(
          'welcome_user',
          params: {'name': 'John'},
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
```

## 🛠️ Migration from Existing I18n

### From flutter_i18n

```dart
// Before
Text(FlutterI18n.translate(context, 'welcome'))

// After
Text('welcome'.tr())
// or
Text(HybridI18nService.translate('welcome'))
```

### From intl package

```dart
// Before
Text(AppLocalizations.of(context)!.welcome)

// After
Text('welcome'.tr())
// or
Text(HybridI18nService.translate('welcome'))
```

### From custom i18n solution

```dart
// Before
Text(I18n.of(context).translate('welcome'))

// After
Text('welcome'.tr())
// or
Text(HybridI18nService.translate('welcome'))
```

## 📋 Build Scripts

### Add to Makefile

```makefile
# Makefile
.PHONY: i18n-generate i18n-clean

i18n-generate:
	@echo "🔄 Generating i18n enum..."
	@dart run packages/directus_i18n/scripts/auto_generate_enum.dart
	@echo "✅ I18n enum generated successfully!"

i18n-clean:
	@echo "🧹 Cleaning generated i18n files..."
	@rm -rf lib/generated/
	@echo "✅ I18n files cleaned!"

i18n-refresh: i18n-clean i18n-generate
	@echo "🔄 I18n refreshed successfully!"
```

### Add to pubspec.yaml scripts

```yaml
# pubspec.yaml
scripts:
  i18n:generate: dart run packages/directus_i18n/scripts/auto_generate_enum.dart
  i18n:clean: rm -rf lib/generated/
  i18n:refresh: make i18n-refresh
```

## 🔄 CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/i18n.yml
name: I18n Sync

on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight
  workflow_dispatch:      # Manual trigger

jobs:
  sync-i18n:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      
      - name: Generate I18n Enum
        run: |
          cd packages/directus_i18n
          dart run scripts/auto_generate_enum.dart
        env:
          DIRECTUS_BASE_URL: ${{ secrets.DIRECTUS_BASE_URL }}
          DIRECTUS_ACCESS_TOKEN: ${{ secrets.DIRECTUS_ACCESS_TOKEN }}
      
      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v5
        with:
          title: 'chore: sync i18n keys from Directus'
          body: 'Auto-generated by GitHub Actions'
          branch: 'sync-i18n-keys'
```

### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - i18n

sync_i18n:
  stage: i18n
  image: cirrusci/flutter:stable
  script:
    - cd packages/directus_i18n
    - dart run scripts/auto_generate_enum.dart
  only:
    - schedules
    - web
```

## 🧪 Testing

### Unit Tests

```dart
// test/i18n_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  group('I18n Tests', () {
    setUp(() {
      // Mock the service
      HybridI18nService.init(
        baseUrl: 'https://mock-directus.com',
        accessToken: 'mock-token',
        autoGenerateEnum: false,
        enableDynamicFallback: true,
      );
    });

    test('should translate existing key', () {
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

### Widget Tests

```dart
// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  testWidgets('should display translated text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DynamicI18nText('welcome'),
      ),
    );
    
    expect(find.text('Welcome!'), findsOneWidget);
  });
}
```

## 🔍 Debugging

### Enable Debug Mode

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable debug logging
  Logger.level = Level.debug;
  
  // Initialize service
  await HybridI18nService.init(/* config */);
  
  runApp(MyApp());
}
```

### Check Service Status

```dart
// Check service status
Map<String, dynamic> status = HybridI18nService.getStatus();
print('I18n Status: $status');

// Check if enum exists
bool hasEnum = AutoEnumService.hasGeneratedEnum();
print('Has generated enum: $hasEnum');
```

## 📚 Best Practices

### 1. File Organization

```
lib/
├── generated/           # Generated enum files
│   └── ProjectI18nKeys.dart
├── i18n/               # I18n configuration
│   ├── i18n_config.dart
│   └── i18n_keys.dart  # Original keys (if any)
├── main.dart
└── ...
```

### 2. Environment Management

```dart
// lib/config/i18n_config.dart
class I18nConfig {
  static const String baseUrl = String.fromEnvironment(
    'DIRECTUS_BASE_URL',
    defaultValue: 'https://default-directus.com',
  );
  
  static const String accessToken = String.fromEnvironment(
    'DIRECTUS_ACCESS_TOKEN',
    defaultValue: 'default-token',
  );
}
```

### 3. Error Handling

```dart
// lib/services/i18n_service.dart
class I18nService {
  static Future<void> initialize() async {
    try {
      await HybridI18nService.init(/* config */);
    } catch (e) {
      // Fallback to static translations
      Logger().e('Failed to initialize i18n: $e');
      // Load static fallback translations
    }
  }
}
```

### 4. Performance Optimization

```dart
// Cache translations for better performance
class CachedI18nService {
  static final Map<String, String> _cache = {};
  
  static String translate(String key, {String? fallback}) {
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    
    final translation = HybridI18nService.translate(key, fallback: fallback);
    _cache[key] = translation;
    return translation;
  }
}
```

## 🆘 Troubleshooting

### Common Issues

**Q: Package not found**
A: Check pubspec.yaml and run `flutter pub get`

**Q: Environment variables not loaded**
A: Ensure `.env` file exists and `flutter_dotenv` is added

**Q: Generated enum not found**
A: Check if `lib/generated/` directory exists and run generation script

**Q: Translations not working**
A: Check Directus connection and access token

### Debug Commands

```bash
# Check package installation
flutter pub deps | grep directus_i18n

# Generate enum manually
dart run packages/directus_i18n/scripts/auto_generate_enum.dart

# Check generated files
ls -la lib/generated/

# Test translation
flutter test test/i18n_test.dart
```

## 🔗 Related Resources

- [Runtime Enum Guide](RUNTIME_ENUM_GUIDE.md)
- [Dynamic I18n Guide](DYNAMIC_I18N_GUIDE.md)
- [Example App](example/runtime_enum_example.dart)
- [Directus Documentation](https://docs.directus.io)
- [Shorebird Documentation](https://shorebird.dev)