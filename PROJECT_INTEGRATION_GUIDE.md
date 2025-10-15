# Project Integration Guide - การนำไปใช้กับ Project อื่น

## 🎯 Overview

คู่มือนี้จะสอนวิธีการนำ `directus_i18n` package ไปใช้กับ Flutter project อื่นๆ และวิธีการ generate enum ใหม่เมื่อมีการเพิ่ม content ใน Directus

## 📋 Prerequisites

- Flutter project ที่มีอยู่แล้ว
- Directus CMS instance
- Access token สำหรับ Directus (หรือใช้ public access)

## 🚀 Step-by-Step Integration

### Step 1: Add Package Dependency

#### วิธีที่ 1: Local Package (แนะนำสำหรับ development)

```yaml
# pubspec.yaml
dependencies:
  directus_i18n:
    path: ../directus_i18n  # หรือ path ไปยัง package
  flutter_dotenv: ^5.1.0
```

#### วิธีที่ 2: Git Dependency

```yaml
# pubspec.yaml
dependencies:
  directus_i18n:
    git:
      url: https://github.com/your-org/directus_i18n.git
      ref: main
  flutter_dotenv: ^5.1.0
```

### Step 2: Create Environment Configuration

สร้างไฟล์ `.env` ใน root ของ project:

```bash
# .env
DIRECTUS_BASE_URL=https://your-directus-instance.com
DIRECTUS_ACCESS_TOKEN=your-access-token  # หรือเว้นว่างสำหรับ public access
DIRECTUS_COLLECTION_NAME=contents
ERROR_CODES_COLLECTION_NAME=error
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
    accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN'], // Can be null for public access
    collectionName: dotenv.env['DIRECTUS_COLLECTION_NAME'] ?? 'contents',
    enumName: dotenv.env['I18N_ENUM_NAME'] ?? 'ProjectI18nKeys',
    autoGenerateEnum: true,
    enableDynamicFallback: true,
  );
  
  // Initialize Error Code Service
  await ErrorCodeService.init(
    baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
    accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN'], // Can be null for public access
    collectionName: dotenv.env['ERROR_CODES_COLLECTION_NAME'] ?? 'error',
    autoLoad: true,
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

### Step 4: Create Generated Directory

```bash
# สร้าง directory สำหรับ generated files
mkdir -p lib/generated
```

### Step 5: Add to .gitignore (Optional)

```gitignore
# .gitignore
# Generated i18n files (optional - depends on your workflow)
lib/generated/
```

## 🔄 Generate Enum เมื่อเพิ่ม Content ใหม่

### วิธีที่ 1: Manual Generation (แนะนำ)

```bash
# รัน script เพื่อ generate enum ใหม่
dart run packages/directus_i18n/scripts/auto_generate_enum.dart
```

### วิธีที่ 2: Auto Generation (อัตโนมัติ)

```dart
// ใน main.dart - จะ auto generate เมื่อ app เริ่มต้น
await HybridI18nService.init(
  // ... config
  autoGenerateEnum: true, // เปิด auto generation
);
```

### วิธีที่ 3: Force Regenerate

```dart
// Force regenerate enum ใน runtime
await AutoEnumService.forceRegenerate(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'contents',
  enumName: 'ProjectI18nKeys',
);
```

## 📱 Usage Examples

### Method 1: Using Generated Enum (Type Safe)

```dart
// Import generated enum
import 'package:your_app/generated/project_i18n_keys.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Type safe - IDE autocomplete available
        Text(ProjectI18nKeys.welcome.translate()),
        Text(ProjectI18nKeys.welcomeUser.translate(
          translationParams: {'name': 'John'},
        )),
      ],
    );
  }
}
```

### Method 2: Using String Extension (Dynamic)

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

### Method 3: Using Error Codes

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Error codes
        Text('NETWORK_ERROR'.getErrorMessage()),
        Text('AUTH_FAILED'.getErrorMessage()),
        
        // With parameters
        Text('VALIDATION_ERROR'.getErrorMessage(
          parameters: {'field': 'email'},
        )),
      ],
    );
  }
}
```

## 🚀 Shorebird Patch Workflow

### เมื่อเพิ่ม Content ใหม่ใน Directus:

1. **เพิ่ม content ใน Directus CMS**
   - เพิ่ม key ใหม่ใน `contents` collection
   - เพิ่ม translations สำหรับทุกภาษา
   - Publish content

2. **Generate enum ใหม่**
   ```bash
   dart run packages/directus_i18n/scripts/auto_generate_enum.dart
   ```

3. **ใช้ enum ใหม่ในโค้ด**
   ```dart
   // ใช้ enum ใหม่ที่ generate แล้ว
   Text(ProjectI18nKeys.newKey.translate())
   ```

4. **สร้าง Shorebird patch**
   ```bash
   shorebird patch android
   shorebird patch ios
   ```

5. **Deploy patch**
   - ผู้ใช้จะได้ content ใหม่ทันที
   - ไม่ต้องผ่าน app store

## 🛠️ Build Scripts

### Add to Makefile

```makefile
# Makefile
.PHONY: i18n-generate i18n-clean i18n-refresh

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

# Sync both i18n and error codes
i18n-sync:
	@echo "🔄 Syncing both i18n and error codes..."
	@dart run packages/directus_i18n/scripts/sync_both_services.dart
	@echo "✅ Both services synced successfully!"
```

### Add to pubspec.yaml scripts

```yaml
# pubspec.yaml
scripts:
  i18n:generate: dart run packages/directus_i18n/scripts/auto_generate_enum.dart
  i18n:clean: rm -rf lib/generated/
  i18n:refresh: make i18n-refresh
  i18n:sync: dart run packages/directus_i18n/scripts/sync_both_services.dart
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

### Integration Tests

```dart
// test/integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Directus Integration Tests', () {
    setUpAll(() async {
      await dotenv.load(fileName: ".env");
    });

    test('should initialize services with real Directus', () async {
      final baseUrl = dotenv.env['DIRECTUS_BASE_URL'];
      final accessToken = dotenv.env['DIRECTUS_ACCESS_TOKEN'];

      if (baseUrl == null) {
        fail('DIRECTUS_BASE_URL not found in .env file');
      }

      await HybridI18nService.init(
        baseUrl: baseUrl,
        accessToken: accessToken,
        collectionName: 'contents',
        enumName: 'TestI18nKeys',
        autoGenerateEnum: true,
        enableDynamicFallback: true,
      );

      final status = HybridI18nService.getStatus();
      expect(status['initialized'], isTrue);
    });
  });
}
```

## 📚 Best Practices

### 1. File Organization

```
lib/
├── generated/           # Generated enum files
│   └── ProjectI18nKeys.dart
├── config/              # Configuration files
│   └── i18n_config.dart
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
    defaultValue: '',
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
      await ErrorCodeService.init(/* config */);
    } catch (e) {
      // Fallback to static translations
      Logger().e('Failed to initialize i18n: $e');
      // Load static fallback translations
    }
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

**Q: Shorebird patch not working**
A: Ensure generated enum files are included in the patch

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

# Check service status
dart run packages/directus_i18n/scripts/sync_both_services.dart
```

## 🔗 Related Resources

- [Runtime Enum Guide](RUNTIME_ENUM_GUIDE.md)
- [Dynamic I18n Guide](DYNAMIC_I18N_GUIDE.md)
- [Combined Usage Guide](COMBINED_USAGE_GUIDE.md)
- [Directus Documentation](https://docs.directus.io)
- [Shorebird Documentation](https://shorebird.dev)
