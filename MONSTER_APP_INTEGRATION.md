# 📖 คู่มือการใช้งาน directus_i18n ใน Monster Mobile App

## 🎯 ภาพรวม

คู่มือนี้จะสอนวิธีการ integrate `directus_i18n` package เข้ากับ `monster_mobile_app` โดยใช้โครงสร้าง Directus ใหม่ (`app_page` + `app_content`)

---

## 📋 ขั้นตอนที่ 1: ตรวจสอบ Dependencies

### 1.1 Dependencies ที่มีอยู่แล้ว

จาก `pubspec.yaml` ของคุณ:

```yaml
dependencies:
  flutter_dotenv: ^5.1.0  ✅
  logger: ^2.2.0          ✅
  dio: ^5.9.0             ✅
  directus_i18n:
    git:
      url: https://github.com/tuliponline/directus_i18n.git
      ref: v1.0.7          ✅
```

### 1.2 Dependencies ที่ต้องเพิ่ม (ถ้ายังไม่มี)

```yaml
dependencies:
  get_it: ^7.6.7          # สำหรับ dependency injection
  synchronized: ^4.0.0    # สำหรับ thread-safe operations
```

**หมายเหตุ:** `directus_i18n` อาจจะต้องการ dependencies เหล่านี้ แต่ถ้า project ของคุณยังไม่มี ให้เพิ่มเข้าไป

---

## 📋 ขั้นตอนที่ 2: สร้างไฟล์ Configuration

### 2.1 เพิ่ม Environment Variables ใน `.env`

เพิ่มในไฟล์ `.env` ใน folder `env/`:

```bash
# Directus Configuration
DIRECTUS_BASE_URL=https://your-directus-instance.com
DIRECTUS_ACCESS_TOKEN=your-access-token-here
DIRECTUS_COLLECTION_NAME=app_content
I18N_ENUM_NAME=MonsterI18nKeys
```

### 2.2 สร้างไฟล์ Config (Optional)

สร้างไฟล์ `lib/config/directus_config.dart`:

```dart
// lib/config/directus_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DirectusConfig {
  static String get baseUrl => dotenv.get('DIRECTUS_BASE_URL');
  static String get accessToken => dotenv.get('DIRECTUS_ACCESS_TOKEN');
  static String get collectionName => dotenv.get('DIRECTUS_COLLECTION_NAME', fallback: 'app_content');
  static String get enumName => dotenv.get('I18N_ENUM_NAME', fallback: 'MonsterI18nKeys');
}
```

---

## 📋 ขั้นตอนที่ 3: Initialize Service ใน main.dart

### 3.1 แก้ไข `lib/main.dart`

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:easy_localization/easy_localization.dart'; // ถ้ายังใช้อยู่

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: 'env/.env'); // หรือ path ที่ถูกต้อง
  
  // Initialize HybridI18nService สำหรับโครงสร้างใหม่
  await HybridI18nService.init(
    baseUrl: DirectusConfig.baseUrl, // หรือ dotenv.get('DIRECTUS_BASE_URL')
    accessToken: DirectusConfig.accessToken,
    collectionName: DirectusConfig.collectionName,
    collections: [
      // กำหนด pages ที่ต้องการใช้
      DirectusCollectionConfig(
        name: 'app_content',
        pagePrefix: 'login', // Page prefix จาก app_page collection
      ),
      DirectusCollectionConfig(
        name: 'app_content',
        pagePrefix: 'home',
      ),
      DirectusCollectionConfig(
        name: 'app_content',
        pagePrefix: 'profile',
      ),
      // เพิ่ม pages อื่นๆ ตามต้องการ
    ],
    enumName: DirectusConfig.enumName,
    autoGenerateEnum: true, // Generate enum อัตโนมัติ
    enableDynamicFallback: true, // ใช้ dynamic fallback สำหรับ keys ใหม่
  );
  
  // Initialize EasyLocalization (ถ้ายังใช้อยู่)
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('th', 'TH'),
      ],
      path: 'assets/lang', // Path สำหรับ fallback translations
      fallbackLocale: const Locale('th', 'TH'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monster Mobile App',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // ... other configurations
      home: HomePage(),
    );
  }
}
```

---

## 📋 ขั้นตอนที่ 4: สร้าง Script สำหรับ Generate Enum

### 4.1 สร้างไฟล์ `scripts/generate_i18n_keys.dart`

```dart
// scripts/generate_i18n_keys.dart
import 'dart:io';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Load environment variables
  await dotenv.load(fileName: 'env/.env');
  
  final baseUrl = dotenv.get('DIRECTUS_BASE_URL');
  final accessToken = dotenv.get('DIRECTUS_ACCESS_TOKEN');
  final collectionName = dotenv.get('DIRECTUS_COLLECTION_NAME', fallback: 'app_content');
  final enumName = dotenv.get('I18N_ENUM_NAME', fallback: 'MonsterI18nKeys');
  
  print('🚀 Generating I18n keys from Directus...');
  print('Base URL: $baseUrl');
  print('Collection: $collectionName');
  print('Enum Name: $enumName');
  print('');
  
  try {
    // Create generated directory if it doesn't exist
    final generatedDir = Directory('lib/generated');
    if (!await generatedDir.exists()) {
      await generatedDir.create(recursive: true);
    }
    
    // Generate enum with page prefix support
    await DirectusI18nKeyGenerator.generate(
      baseUrl: baseUrl,
      accessToken: accessToken,
      outputPath: 'lib/generated/$enumName.dart',
      collectionName: collectionName,
      collections: [
        // กำหนด pages ที่ต้องการ generate enum
        DirectusCollectionConfig(
          name: collectionName,
          pagePrefix: 'login',
        ),
        DirectusCollectionConfig(
          name: collectionName,
          pagePrefix: 'home',
        ),
        DirectusCollectionConfig(
          name: collectionName,
          pagePrefix: 'profile',
        ),
        // เพิ่ม pages อื่นๆ ตามต้องการ
      ],
      enumName: enumName,
    );
    
    print('✅ Successfully generated $enumName at lib/generated/$enumName.dart');
    print('');
    print('📝 Next steps:');
    print('   1. Import: import \'../generated/$enumName.dart\';');
    print('   2. Use: ${enumName}.LOGIN_TITLE.translate(context: context)');
    print('   3. Run this script again when you add new keys in Directus');
    
  } catch (e, stackTrace) {
    print('❌ Error generating enum: $e');
    if (e.toString().contains('Page prefix')) {
      print('⚠️  Make sure the page prefix exists in app_page collection with status=published');
    }
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
```

### 4.2 Generate Enum

```bash
# Generate enum จาก Directus
dart run scripts/generate_i18n_keys.dart
```

---

## 📋 ขั้นตอนที่ 5: สร้าง Extension สำหรับใช้งานง่าย

### 5.1 สร้างไฟล์ `lib/extensions/i18n_extension.dart`

```dart
// lib/extensions/i18n_extension.dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

extension BuildContextI18nExtension on BuildContext {
  /// Translate key with fallback
  /// 
  /// ใช้ HybridI18nService สำหรับ translation
  /// รองรับทั้ง enum และ dynamic keys
  String i18n(String key, {String? fallback, Map<String, String>? params}) {
    return HybridI18nService.translate(
      key,
      context: this,
      fallback: fallback ?? key,
      params: params,
    );
  }
  
  /// Translate with EasyLocalization fallback (ถ้ายังใช้อยู่)
  String i18nWithFallback(String key, {String? fallback, Map<String, String>? params}) {
    // ลองใช้ HybridI18nService ก่อน
    final directusTranslation = HybridI18nService.translate(
      key,
      context: this,
      fallback: null, // ไม่ใช้ fallback เพื่อให้ลอง EasyLocalization
      params: params,
    );
    
    // ถ้าได้ translation จาก Directus และไม่ใช่ key เดิม
    if (directusTranslation != key) {
      return directusTranslation;
    }
    
    // Fallback ไปใช้ EasyLocalization (ถ้ายังใช้อยู่)
    try {
      return key.tr(); // EasyLocalization
    } catch (e) {
      return fallback ?? key;
    }
  }
}
```

---

## 📋 ขั้นตอนที่ 6: ใช้งานใน Widget

### 6.1 ใช้ Generated Enum (Type Safe)

```dart
// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';
import '../generated/monster_i18n_keys.dart'; // Generated enum
import '../extensions/i18n_extension.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // วิธีที่ 1: ใช้ Generated Enum (Type Safe)
        title: Text(MonsterI18nKeys.LOGIN_TITLE.translate(context: context)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // วิธีที่ 2: ใช้ Extension
            Text(
              context.i18n('TITLE', fallback: 'Login'),
            ),
            
            SizedBox(height: 24),
            
            TextField(
              decoration: InputDecoration(
                // วิธีที่ 3: ใช้ HybridI18nService โดยตรง
                labelText: HybridI18nService.translate(
                  'EMAIL_LABEL',
                  context: context,
                  fallback: 'Email',
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            TextField(
              decoration: InputDecoration(
                labelText: context.i18n('PASSWORD_LABEL', fallback: 'Password'),
              ),
              obscureText: true,
            ),
            
            SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: () {
                // Handle login
              },
              // ใช้ enum
              child: Text(MonsterI18nKeys.LOGIN_BUTTON.translate(context: context)),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 6.2 ใช้ Dynamic Translation (สำหรับ Keys ใหม่)

```dart
// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../extensions/i18n_extension.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // ใช้ dynamic translation (ไม่ต้อง generate enum)
          context.i18n('HOME_TITLE', fallback: 'Home'),
        ),
      ),
      body: Column(
        children: [
          Text(
            context.i18n(
              'HOME_WELCOME',
              params: {'name': 'John'}, // Parameters
              fallback: 'Welcome, {name}!',
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 📋 ขั้นตอนที่ 7: Migration จาก EasyLocalization

### 7.1 ถ้ายังใช้ EasyLocalization อยู่

คุณสามารถใช้ทั้งสองอย่างพร้อมกันได้:

```dart
// ใช้ HybridI18nService สำหรับ keys ใหม่
context.i18n('NEW_KEY', fallback: 'Fallback')

// ใช้ EasyLocalization สำหรับ keys เก่า
'OLD_KEY'.tr()
```

### 7.2 Migrate ทีละน้อย

1. **Phase 1**: ใช้ทั้งสองอย่างพร้อมกัน
2. **Phase 2**: Migrate keys เก่าไปใช้ Directus ทีละส่วน
3. **Phase 3**: ลบ EasyLocalization ออกเมื่อ migrate เสร็จ

---

## 🔄 Workflow การใช้งาน

### สำหรับ Developer

1. **เพิ่ม Keys ใหม่ใน Directus**
   - ไปที่ Directus CMS
   - เพิ่ม content ใน `app_content` collection
   - ตั้งค่า `status = published`

2. **Generate Enum ใหม่** (ถ้าต้องการ type safety)
   ```bash
   dart run scripts/generate_i18n_keys.dart
   ```

3. **ใช้ Enum ในโค้ด**
   ```dart
   Text(MonsterI18nKeys.NEW_KEY.translate(context: context))
   ```

4. **หรือใช้ Dynamic Translation** (ไม่ต้อง generate)
   ```dart
   Text(context.i18n('NEW_KEY', fallback: 'Fallback'))
   ```

### สำหรับ Content Team

1. เพิ่ม/แก้ไข content ใน Directus
2. ตั้งค่า `status = published`
3. Keys จะใช้ได้ทันทีผ่าน Dynamic Translation
4. หรือบอก Developer ให้ generate enum ใหม่

---

## 📝 ตัวอย่างการใช้งานแบบเต็ม

### main.dart (Full Example)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:easy_localization/easy_localization.dart';
import 'config/directus_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: 'env/.env');
  
  // Initialize HybridI18nService
  await HybridI18nService.init(
    baseUrl: DirectusConfig.baseUrl,
    accessToken: DirectusConfig.accessToken,
    collectionName: DirectusConfig.collectionName,
    collections: [
      DirectusCollectionConfig(
        name: DirectusConfig.collectionName,
        pagePrefix: 'login',
      ),
      DirectusCollectionConfig(
        name: DirectusConfig.collectionName,
        pagePrefix: 'home',
      ),
      DirectusCollectionConfig(
        name: DirectusConfig.collectionName,
        pagePrefix: 'profile',
      ),
    ],
    enumName: DirectusConfig.enumName,
    autoGenerateEnum: false, // ใช้ false เพราะ generate แล้วด้วย script
    enableDynamicFallback: true,
  );
  
  // Initialize EasyLocalization (ถ้ายังใช้อยู่)
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('th', 'TH'),
      ],
      path: 'assets/lang',
      fallbackLocale: const Locale('th', 'TH'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monster Mobile App',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: HomePage(),
    );
  }
}
```

---

## 🆘 Troubleshooting

### ปัญหา: Generate Enum ไม่สำเร็จ

**ตรวจสอบ:**
1. `.env` file มีค่าถูกต้องหรือไม่
2. Directus URL และ Access Token ถูกต้องหรือไม่
3. Collection name ตรงกับใน Directus หรือไม่
4. Page prefix ตรงกับ `key` ใน `app_page` collection หรือไม่

### ปัญหา: Translation ไม่ทำงาน

**ตรวจสอบ:**
1. Initialize service แล้วหรือยัง
2. Context ไม่เป็น null หรือไม่
3. Key มีอยู่ใน Directus หรือไม่
4. Status ของ content เป็น `published` หรือไม่

### ปัญหา: Conflict กับ EasyLocalization

**แก้ไข:**
- ใช้ `context.i18n()` สำหรับ Directus keys
- ใช้ `'key'.tr()` สำหรับ EasyLocalization keys
- หรือใช้ `context.i18nWithFallback()` ที่มี fallback ไป EasyLocalization

---

## 📋 ขั้นตอนที่ 8: การทดสอบ

### 8.1 สร้าง Test File

สร้างไฟล์ `test/directus_i18n_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Directus I18n Tests', () {
    setUpAll(() async {
      await dotenv.load(fileName: 'env/.env');
    });

    setUp(() async {
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
      await Future.delayed(Duration(seconds: 2));
    });

    tearDown(() {
      HybridI18nService.refresh();
    });

    test('should initialize successfully', () {
      final status = HybridI18nService.getStatus();
      expect(status['initialized'], isTrue);
    });

    test('should translate key', () {
      final translation = HybridI18nService.translate(
        'TITLE',
        fallback: 'Login',
      );
      expect(translation, isNotEmpty);
    });
  });
}
```

### 8.2 รัน Tests

```bash
# รัน tests ทั้งหมด
flutter test

# รัน test เฉพาะไฟล์
flutter test test/directus_i18n_test.dart
```

📖 **ดูรายละเอียดเพิ่มเติม:** [Testing Guide](TESTING_GUIDE.md)

---

## 📚 เอกสารเพิ่มเติม

- [Project Setup Guide](PROJECT_SETUP_GUIDE.md) - คู่มือการ Setup และใช้งานใน Project
- **[Testing Guide](TESTING_GUIDE.md)** - คู่มือการทดสอบใน Project ⭐
- [New Structure Usage Guide](NEW_STRUCTURE_USAGE.md) - คู่มือการใช้งานโครงสร้างใหม่
- [Enum with Page Prefix Guide](ENUM_WITH_PAGE_PREFIX.md) - คู่มือการใช้งาน Enum พร้อม Page Prefix

---

## ✅ Checklist

- [ ] เพิ่ม dependencies ที่จำเป็น (get_it, synchronized)
- [ ] เพิ่ม environment variables ใน `.env`
- [ ] สร้าง script สำหรับ generate enum
- [ ] Generate enum จาก Directus
- [ ] Initialize service ใน `main.dart`
- [ ] สร้าง extension สำหรับใช้งานง่าย
- [ ] ใช้งานใน Widget
- [ ] ทดสอบการทำงาน

---

**🎉 เสร็จสิ้น! ตอนนี้คุณพร้อมใช้งาน directus_i18n ใน Monster Mobile App แล้ว**
