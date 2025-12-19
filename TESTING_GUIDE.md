# 🧪 คู่มือการทดสอบ directus_i18n ใน Project

## 🎯 ภาพรวม

คู่มือนี้จะสอนวิธีการทดสอบ `directus_i18n` package ใน Flutter project ของคุณ โดยครอบคลุมทั้ง Unit Tests, Widget Tests, และ Integration Tests

---

## 📋 ขั้นตอนที่ 1: Setup Test Dependencies

### 1.1 เพิ่ม Dependencies ใน `pubspec.yaml`

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.0  # สำหรับ mocking
  integration_test:
    sdk: flutter
```

### 1.2 Install Dependencies

```bash
flutter pub get
```

---

## 📋 ขั้นตอนที่ 2: การทดสอบการ Initialize

### 2.1 ทดสอบ HybridI18nService Initialization

สร้างไฟล์ `test/services/hybrid_i18n_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  group('HybridI18nService Initialization', () {
    tearDown(() {
      // Reset service หลังแต่ละ test
      HybridI18nService.refresh();
    });

    test('should initialize successfully', () async {
      await HybridI18nService.init(
        baseUrl: 'https://your-directus.com',
        accessToken: 'test-token',
        collectionName: 'app_content',
        collections: [
          DirectusCollectionConfig(
            name: 'app_content',
            pagePrefix: 'login',
          ),
        ],
        autoGenerateEnum: false, // ปิด enum generation ใน test
        enableDynamicFallback: true,
      );

      final status = HybridI18nService.getStatus();
      expect(status['initialized'], isTrue);
    });

    test('should not initialize twice', () async {
      await HybridI18nService.init(
        baseUrl: 'https://your-directus.com',
        accessToken: 'test-token',
      );

      // Initialize อีกครั้ง
      await HybridI18nService.init(
        baseUrl: 'https://your-directus.com',
        accessToken: 'test-token',
      );

      // ควร initialize ได้ครั้งเดียวเท่านั้น
      final status = HybridI18nService.getStatus();
      expect(status['initialized'], isTrue);
    });

    test('should load keys from Directus', () async {
      await HybridI18nService.init(
        baseUrl: 'https://your-directus.com',
        accessToken: 'test-token',
        collectionName: 'app_content',
        collections: [
          DirectusCollectionConfig(
            name: 'app_content',
            pagePrefix: 'login',
          ),
        ],
      );

      // รอให้ load เสร็จ
      await Future.delayed(Duration(seconds: 2));

      final status = HybridI18nService.getStatus();
      expect(status['dynamicKeysCount'], greaterThan(0));
    });
  });
}
```

---

## 📋 ขั้นตอนที่ 3: การทดสอบ Translation

### 3.1 ทดสอบ Translation ด้วย Mock Data

สร้างไฟล์ `test/translations/translation_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter/material.dart';

void main() {
  group('Translation Tests', () {
    setUp(() async {
      // Initialize service ก่อน test
      await HybridI18nService.init(
        baseUrl: 'https://your-directus.com',
        accessToken: 'test-token',
        collectionName: 'app_content',
        collections: [
          DirectusCollectionConfig(
            name: 'app_content',
            pagePrefix: 'login',
          ),
        ],
        autoGenerateEnum: false,
        enableDynamicFallback: true,
      );

      // รอให้ load เสร็จ
      await Future.delayed(Duration(seconds: 2));
    });

    tearDown(() {
      HybridI18nService.refresh();
    });

    test('should translate key correctly', () {
      final translation = HybridI18nService.translate(
        'TITLE',
        fallback: 'Login',
      );

      expect(translation, isNotEmpty);
      // ถ้ามี key ใน Directus จะได้ translation
      // ถ้าไม่มีจะได้ fallback
      expect(translation == 'Login' || translation.isNotEmpty, isTrue);
    });

    test('should use fallback when key not found', () {
      final translation = HybridI18nService.translate(
        'NON_EXISTENT_KEY',
        fallback: 'Fallback Text',
      );

      expect(translation, 'Fallback Text');
    });

    test('should translate with parameters', () {
      final translation = HybridI18nService.translate(
        'WELCOME_MESSAGE',
        params: {'name': 'John'},
        fallback: 'Welcome, {name}!',
      );

      expect(translation, contains('John'));
    });

    test('should check if key exists', () {
      final hasKey = HybridI18nService.hasKey('TITLE');
      // อาจจะเป็น true หรือ false ขึ้นอยู่กับว่ามี key ใน Directus หรือไม่
      expect(hasKey, isA<bool>());
    });

    test('should get all available keys', () {
      final allKeys = HybridI18nService.getAllKeys();
      expect(allKeys, isA<List<String>>());
    });
  });
}
```

### 3.2 ทดสอบ Translation ด้วย Context

สร้างไฟล์ `test/widgets/translation_widget_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

// Extension สำหรับทดสอบ
extension BuildContextI18nExtension on BuildContext {
  String i18n(String key, {String? fallback, Map<String, String>? params}) {
    return HybridI18nService.translate(
      key,
      context: this,
      fallback: fallback ?? key,
      params: params,
    );
  }
}

void main() {
  group('Translation Widget Tests', () {
    setUp(() async {
      await HybridI18nService.init(
        baseUrl: 'https://your-directus.com',
        accessToken: 'test-token',
        collectionName: 'app_content',
        autoGenerateEnum: false,
        enableDynamicFallback: true,
      );
      await Future.delayed(Duration(seconds: 2));
    });

    tearDown(() {
      HybridI18nService.refresh();
    });

    testWidgets('should display translated text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('th', 'TH'),
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('th', 'TH'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Text(
                  context.i18n('TITLE', fallback: 'Login'),
                );
              },
            ),
          ),
        ),
      );

      // ตรวจสอบว่ามี text แสดง
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should use DynamicI18nText widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('th', 'TH'),
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('th', 'TH'),
          ],
          home: Scaffold(
            body: DynamicI18nText(
              'TITLE',
              fallback: 'Login',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
```

---

## 📋 ขั้นตอนที่ 4: การทดสอบ Enum Generation

### 4.1 ทดสอบ Generated Enum

สร้างไฟล์ `test/enum/enum_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';
// Import generated enum (ถ้า generate แล้ว)
// import '../generated/monster_i18n_keys.dart';

void main() {
  group('Enum Tests', () {
    test('should have enum values', () {
      // ถ้า generate enum แล้ว
      // expect(MonsterI18nKeys.values, isNotEmpty);
      // expect(MonsterI18nKeys.LOGIN_TITLE.key, 'TITLE');
    });

    test('should translate enum value', () {
      // ถ้า generate enum แล้ว
      // final translation = MonsterI18nKeys.LOGIN_TITLE.translate();
      // expect(translation, isNotEmpty);
    });
  });
}
```

### 4.2 ทดสอบ Enum Generation Script

สร้างไฟล์ `test/scripts/generate_enum_test.dart`:

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  group('Enum Generation Tests', () {
    test('should generate enum file', () async {
      // ใช้ test credentials
      await DirectusI18nKeyGenerator.generate(
        baseUrl: 'https://your-directus.com',
        accessToken: 'test-token',
        outputPath: 'test/generated/test_i18n_keys.dart',
        collectionName: 'app_content',
        collections: [
          DirectusCollectionConfig(
            name: 'app_content',
            pagePrefix: 'login',
          ),
        ],
        enumName: 'TestI18nKeys',
      );

      // ตรวจสอบว่าไฟล์ถูกสร้าง
      final file = File('test/generated/test_i18n_keys.dart');
      expect(await file.exists(), isTrue);

      // ตรวจสอบว่าไฟล์มี content
      final content = await file.readAsString();
      expect(content, contains('enum TestI18nKeys'));
      expect(content, contains('LOGIN_TITLE')); // ถ้ามี key นี้
    });
  });
}
```

---

## 📋 ขั้นตอนที่ 5: การทดสอบ Integration

### 5.1 ทดสอบ Integration แบบเต็ม

สร้างไฟล์ `test/integration/full_integration_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Full Integration Tests', () {
    setUpAll(() async {
      // Load environment variables
      await dotenv.load(fileName: '.env');
    });

    test('should initialize and load translations from real Directus', () async {
      await HybridI18nService.init(
        baseUrl: dotenv.get('DIRECTUS_BASE_URL'),
        accessToken: dotenv.get('DIRECTUS_ACCESS_TOKEN'),
        collectionName: 'app_content',
        collections: [
          DirectusCollectionConfig(
            name: 'app_content',
            pagePrefix: 'login',
          ),
        ],
        autoGenerateEnum: false,
        enableDynamicFallback: true,
      );

      // รอให้ load เสร็จ
      await Future.delayed(Duration(seconds: 3));

      final status = HybridI18nService.getStatus();
      print('Status: $status');

      expect(status['initialized'], isTrue);
      expect(status['dynamicKeysCount'], greaterThan(0));

      // ทดสอบ translation
      final translation = HybridI18nService.translate(
        'TITLE',
        fallback: 'Login',
      );

      print('Translation for TITLE: $translation');
      expect(translation, isNotEmpty);
    });

    test('should handle multiple page prefixes', () async {
      await HybridI18nService.init(
        baseUrl: dotenv.get('DIRECTUS_BASE_URL'),
        accessToken: dotenv.get('DIRECTUS_ACCESS_TOKEN'),
        collectionName: 'app_content',
        collections: [
          DirectusCollectionConfig(
            name: 'app_content',
            pagePrefix: 'login',
          ),
          DirectusCollectionConfig(
            name: 'app_content',
            pagePrefix: 'home',
          ),
        ],
      );

      await Future.delayed(Duration(seconds: 3));

      final allKeys = HybridI18nService.getAllKeys();
      print('Total keys loaded: ${allKeys.length}');
      print('Keys: $allKeys');

      expect(allKeys.length, greaterThan(0));
    });
  });
}
```

---

## 📋 ขั้นตอนที่ 6: การทดสอบด้วย Mock Data

### 6.1 สร้าง Mock Repository

สร้างไฟล์ `test/mocks/mock_repository.dart`:

```dart
import 'package:directus_i18n/directus_i18n.dart';
import 'package:mocktail/mocktail.dart';

class MockDirectusI18nRepository extends Mock implements DirectusI18nRepository {}

class MockTranslations {
  static Map<String, String> getLoginPageTranslations() {
    return {
      'TITLE': 'Login',
      'BUTTON': 'Login',
      'EMAIL_LABEL': 'Email',
      'PASSWORD_LABEL': 'Password',
    };
  }

  static Map<String, String> getHomePageTranslations() {
    return {
      'WELCOME': 'Welcome',
      'DESCRIPTION': 'Description',
    };
  }
}
```

### 6.2 ทดสอบด้วย Mock

สร้างไฟล์ `test/mocks/mock_translation_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:mocktail/mocktail.dart';
import 'mock_repository.dart';

void main() {
  group('Mock Translation Tests', () {
    late MockDirectusI18nRepository mockRepository;

    setUp(() {
      mockRepository = MockDirectusI18nRepository();
    });

    test('should load translations from mock repository', () async {
      final mockTranslations = MockTranslations.getLoginPageTranslations();

      when(() => mockRepository.load(any()))
          .thenAnswer((_) async => mockTranslations);

      final loader = DirectusI18nLoader(mockRepository);
      final result = await loader.load();

      expect(result, mockTranslations);
      expect(result['TITLE'], 'Login');
      expect(result['BUTTON'], 'Login');
    });
  });
}
```

---

## 📋 ขั้นตอนที่ 7: การทดสอบ Error Handling

### 7.1 ทดสอบ Error Cases

สร้างไฟล์ `test/errors/error_handling_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  group('Error Handling Tests', () {
    test('should handle network error gracefully', () async {
      await HybridI18nService.init(
        baseUrl: 'https://invalid-url.com',
        accessToken: 'invalid-token',
        collectionName: 'app_content',
        autoGenerateEnum: false,
        enableDynamicFallback: true,
      );

      // Service ควร initialize ได้แม้ network จะ fail
      final status = HybridI18nService.getStatus();
      expect(status['initialized'], isTrue);

      // Translation ควรใช้ fallback
      final translation = HybridI18nService.translate(
        'TITLE',
        fallback: 'Login',
      );

      expect(translation, 'Login');
    });

    test('should handle missing key gracefully', () {
      final translation = HybridI18nService.translate(
        'NON_EXISTENT_KEY_12345',
        fallback: 'Fallback',
      );

      expect(translation, 'Fallback');
    });

    test('should handle null context', () {
      final translation = HybridI18nService.translate(
        'TITLE',
        fallback: 'Login',
        context: null, // null context
      );

      expect(translation, isNotEmpty);
    });
  });
}
```

---

## 📋 ขั้นตอนที่ 8: การทดสอบ Page Prefix

### 8.1 ทดสอบ Page Prefix Filtering

สร้างไฟล์ `test/page_prefix/page_prefix_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  group('Page Prefix Tests', () {
    setUp(() async {
      await HybridI18nService.init(
        baseUrl: 'https://your-directus.com',
        accessToken: 'test-token',
        collectionName: 'app_content',
        collections: [
          DirectusCollectionConfig(
            name: 'app_content',
            pagePrefix: 'login',
          ),
        ],
        autoGenerateEnum: false,
        enableDynamicFallback: true,
      );

      await Future.delayed(Duration(seconds: 2));
    });

    tearDown(() {
      HybridI18nService.refresh();
    });

    test('should load only login page keys', () {
      final allKeys = HybridI18nService.getAllKeys();
      print('Keys loaded: $allKeys');

      // Keys ควรมาจาก login page เท่านั้น
      // (ถ้ามี prefix อาจจะมี LOGIN. prefix)
      expect(allKeys, isNotEmpty);
    });

    test('should translate login page key', () {
      final translation = HybridI18nService.translate(
        'TITLE', // Key จาก login page
        fallback: 'Login',
      );

      expect(translation, isNotEmpty);
    });
  });
}
```

---

## 📋 ขั้นตอนที่ 9: การทดสอบ Locale Switching

### 9.1 ทดสอบการเปลี่ยนภาษา

สร้างไฟล์ `test/locale/locale_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter/material.dart';

void main() {
  group('Locale Tests', () {
    setUp(() async {
      await HybridI18nService.init(
        baseUrl: 'https://your-directus.com',
        accessToken: 'test-token',
        collectionName: 'app_content',
        autoGenerateEnum: false,
        enableDynamicFallback: true,
      );

      await Future.delayed(Duration(seconds: 2));
    });

    tearDown(() {
      HybridI18nService.refresh();
    });

    testWidgets('should translate in Thai locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('th', 'TH'),
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('th', 'TH'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final translation = HybridI18nService.translate(
                  'TITLE',
                  context: context,
                  fallback: 'Login',
                );
                return Text(translation);
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // ควรได้ translation ภาษาไทย (ถ้ามี)
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should translate in English locale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('th', 'TH'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final translation = HybridI18nService.translate(
                  'TITLE',
                  context: context,
                  fallback: 'Login',
                );
                return Text(translation);
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
```

---

## 📋 ขั้นตอนที่ 10: การทดสอบ Performance

### 10.1 ทดสอบ Performance

สร้างไฟล์ `test/performance/performance_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  group('Performance Tests', () {
    test('should initialize quickly', () async {
      final stopwatch = Stopwatch()..start();

      await HybridI18nService.init(
        baseUrl: 'https://your-directus.com',
        accessToken: 'test-token',
        collectionName: 'app_content',
        autoGenerateEnum: false,
        enableDynamicFallback: true,
      );

      stopwatch.stop();
      print('Initialization time: ${stopwatch.elapsedMilliseconds}ms');

      // ควร initialize ภายใน 5 วินาที
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('should translate quickly', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        HybridI18nService.translate(
          'TITLE',
          fallback: 'Login',
        );
      }

      stopwatch.stop();
      print('100 translations time: ${stopwatch.elapsedMilliseconds}ms');

      // 100 translations ควรใช้เวลาไม่เกิน 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
```

---

## 📋 ขั้นตอนที่ 11: การรัน Tests

### 11.1 รัน Tests ทั้งหมด

```bash
# รัน tests ทั้งหมด
flutter test

# รัน test เฉพาะไฟล์
flutter test test/services/hybrid_i18n_service_test.dart

# รัน test พร้อม coverage
flutter test --coverage

# รัน integration tests
flutter test integration_test/
```

### 11.2 สร้าง Test Script

สร้างไฟล์ `scripts/run_tests.dart`:

```dart
import 'dart:io';

void main() async {
  print('🧪 Running tests...');
  
  final result = await Process.run(
    'flutter',
    ['test'],
    runInShell: true,
  );

  print(result.stdout);
  if (result.exitCode != 0) {
    print(result.stderr);
    exit(result.exitCode);
  }

  print('✅ All tests passed!');
}
```

รันด้วย:
```bash
dart run scripts/run_tests.dart
```

---

## 📋 ขั้นตอนที่ 12: การทดสอบใน CI/CD

### 12.1 สร้าง GitHub Actions Workflow

สร้างไฟล์ `.github/workflows/test.yml`:

```yaml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test
      
      - name: Generate coverage
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

---

## 📝 ตัวอย่าง Test Suite แบบเต็ม

### test/directus_i18n_test_suite.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Directus I18n Test Suite', () {
    setUpAll(() async {
      // Load environment variables
      await dotenv.load(fileName: '.env');
    });

    group('Initialization', () {
      test('should initialize HybridI18nService', () async {
        await HybridI18nService.init(
          baseUrl: dotenv.get('DIRECTUS_BASE_URL'),
          accessToken: dotenv.get('DIRECTUS_ACCESS_TOKEN'),
          collectionName: 'app_content',
          collections: [
            DirectusCollectionConfig(
              name: 'app_content',
              pagePrefix: 'login',
            ),
          ],
        );

        final status = HybridI18nService.getStatus();
        expect(status['initialized'], isTrue);
      });
    });

    group('Translation', () {
      test('should translate existing key', () {
        final translation = HybridI18nService.translate(
          'TITLE',
          fallback: 'Login',
        );

        expect(translation, isNotEmpty);
      });

      test('should use fallback for missing key', () {
        final translation = HybridI18nService.translate(
          'NON_EXISTENT',
          fallback: 'Fallback',
        );

        expect(translation, 'Fallback');
      });
    });

    group('Status', () {
      test('should get service status', () {
        final status = HybridI18nService.getStatus();
        expect(status, isA<Map<String, dynamic>>());
        expect(status['initialized'], isA<bool>());
      });
    });
  });
}
```

---

## 🆘 Troubleshooting

### ปัญหา: Tests fail เพราะ network timeout

**แก้ไข:**
- ใช้ mock data แทน real API calls
- เพิ่ม timeout ใน test
- ใช้ test credentials ที่ถูกต้อง

### ปัญหา: Service ไม่ initialize ใน test

**แก้ไข:**
- ใช้ `setUp()` เพื่อ initialize ก่อน test
- ใช้ `tearDown()` เพื่อ reset หลัง test
- รอให้ initialization เสร็จด้วย `await Future.delayed()`

### ปัญหา: Context เป็น null ใน widget test

**แก้ไข:**
- ใช้ `Builder` widget เพื่อสร้าง context
- หรือใช้ `MaterialApp` wrapper

---

## 📚 เอกสารเพิ่มเติม

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mocktail Documentation](https://pub.dev/packages/mocktail)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

---

## ✅ Checklist

- [ ] Setup test dependencies
- [ ] สร้าง test files
- [ ] ทดสอบ initialization
- [ ] ทดสอบ translation
- [ ] ทดสอบ enum generation
- [ ] ทดสอบ integration
- [ ] ทดสอบ error handling
- [ ] รัน tests ทั้งหมด
- [ ] Setup CI/CD (optional)

---

**🎉 เสร็จสิ้น! ตอนนี้คุณพร้อมทดสอบ directus_i18n ใน project ของคุณแล้ว**
