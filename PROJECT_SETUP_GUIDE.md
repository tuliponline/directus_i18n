# 📖 คู่มือการ Setup และใช้งานใน Project

## 🎯 ภาพรวม

คู่มือนี้จะสอนวิธีการ setup และใช้งาน `directus_i18n` package ใน Flutter project ของคุณ โดยเฉพาะสำหรับโครงสร้าง Directus ใหม่ (`app_page` + `app_content`)

---

## 📋 ขั้นตอนที่ 1: เพิ่ม Package

### 1.1 แก้ไข `pubspec.yaml`

```yaml
name: your_app
description: Your Flutter app

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Directus I18n Package
  directus_i18n:
    path: ../directus_i18n  # หรือ path ไปยัง package location
  
  # Dependencies ที่จำเป็น
  dio: ^5.4.0
  flutter_dotenv: ^5.1.0
  logger: ^2.0.0
  get_it: ^7.6.7
  synchronized: ^4.0.0
  
  # สำหรับ i18n
  flutter_i18n: ^0.30.0
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### 1.2 Install Dependencies

```bash
flutter pub get
```

---

## 📋 ขั้นตอนที่ 2: สร้างไฟล์ Configuration

### 2.1 สร้างไฟล์ `.env` ใน root ของ project

```bash
# .env
DIRECTUS_BASE_URL=https://your-directus-instance.com
DIRECTUS_ACCESS_TOKEN=your-access-token-here
DIRECTUS_COLLECTION_NAME=app_content
I18N_ENUM_NAME=AppI18nKeys
```

### 2.2 สร้างไฟล์ `lib/config/env.dart` (Optional)

```dart
// lib/config/env.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get directusBaseUrl => dotenv.get('DIRECTUS_BASE_URL');
  static String get directusAccessToken => dotenv.get('DIRECTUS_ACCESS_TOKEN');
  static String get collectionName => dotenv.get('DIRECTUS_COLLECTION_NAME', fallback: 'app_content');
  static String get enumName => dotenv.get('I18N_ENUM_NAME', fallback: 'AppI18nKeys');
}
```

---

## 📋 ขั้นตอนที่ 3: สร้าง Script สำหรับ Generate Enum

### 3.1 สร้างไฟล์ `scripts/generate_i18n_keys.dart`

**วิธีที่ 1: Copy จาก Example Script**

```bash
# Copy example script จาก package
cp packages/directus_i18n/scripts/generate_i18n_example.dart scripts/generate_i18n_keys.dart
```

**วิธีที่ 2: สร้างเอง**

```dart
// scripts/generate_i18n_keys.dart
import 'dart:io';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  final baseUrl = dotenv.get('DIRECTUS_BASE_URL');
  final accessToken = dotenv.get('DIRECTUS_ACCESS_TOKEN');
  final collectionName = dotenv.get('DIRECTUS_COLLECTION_NAME', fallback: 'app_content');
  final enumName = dotenv.get('I18N_ENUM_NAME', fallback: 'AppI18nKeys');
  
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
        // Configure your pages here
        DirectusCollectionConfig(
          name: collectionName,
          pagePrefix: 'login', // Page prefix จาก app_page collection
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
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
```

### 3.2 สร้าง directory สำหรับ generated files

```bash
mkdir -p lib/generated
```

### 3.3 เพิ่ม `.gitignore` สำหรับ generated files (Optional)

```gitignore
# Generated files (optional - คุณอาจจะต้องการ commit ไฟล์เหล่านี้)
# lib/generated/
```

---

## 📋 ขั้นตอนที่ 4: Generate Enum

### 4.1 Run Script

```bash
# Generate enum จาก Directus
dart run scripts/generate_i18n_keys.dart
```

### 4.2 ตรวจสอบ Generated File

ไฟล์ที่ถูก generate จะอยู่ที่ `lib/generated/AppI18nKeys.dart`:

```dart
// lib/generated/AppI18nKeys.dart
/// GENERATED CODE - DO NOT MODIFY BY HAND
enum AppI18nKeys implements I18nKey {
  empty('0', defaultFallbackKey: ''),
  LOGIN_TITLE('TITLE', defaultFallbackKey: 'Login'),
  LOGIN_BUTTON('BUTTON', defaultFallbackKey: 'Login'),
  HOME_WELCOME('WELCOME', defaultFallbackKey: 'Welcome'),
  // ...
}
```

---

## 📋 ขั้นตอนที่ 5: Initialize Service ใน main.dart

### 5.1 แก้ไข `lib/main.dart`

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/env.dart'; // Optional: ถ้าสร้างไฟล์ config

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize HybridI18nService
  await HybridI18nService.init(
    baseUrl: Env.directusBaseUrl, // หรือ dotenv.get('DIRECTUS_BASE_URL')
    accessToken: Env.directusAccessToken,
    collectionName: Env.collectionName,
    collections: [
      DirectusCollectionConfig(
        name: Env.collectionName,
        pagePrefix: 'login',
      ),
      DirectusCollectionConfig(
        name: Env.collectionName,
        pagePrefix: 'home',
      ),
      DirectusCollectionConfig(
        name: Env.collectionName,
        pagePrefix: 'profile',
      ),
      // เพิ่ม pages อื่นๆ ตามต้องการ
    ],
    enumName: Env.enumName,
    autoGenerateEnum: false, // ใช้ false เพราะเรา generate แล้วด้วย script
    enableDynamicFallback: true, // ใช้ dynamic fallback สำหรับ keys ใหม่
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      // ตั้งค่า locale
      locale: const Locale('th', 'TH'), // หรือ Locale('en', 'US')
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('th', 'TH'),
      ],
      localizationsDelegates: const [
        // เพิ่ม delegates อื่นๆ ตามต้องการ
      ],
      home: HomePage(),
    );
  }
}
```

---

## 📋 ขั้นตอนที่ 6: สร้าง Extension สำหรับใช้งานง่าย

### 6.1 สร้างไฟล์ `lib/extensions/i18n_extension.dart`

```dart
// lib/extensions/i18n_extension.dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

extension BuildContextI18nExtension on BuildContext {
  /// Translate key with fallback
  String i18n(String key, {String? fallback, Map<String, String>? params}) {
    return HybridI18nService.translate(
      key,
      context: this,
      fallback: fallback ?? key,
      params: params,
    );
  }
}
```

---

## 📋 ขั้นตอนที่ 7: ใช้งานใน Widget

### 7.1 ใช้ Generated Enum (Type Safe)

```dart
// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';
import '../generated/app_i18n_keys.dart'; // Generated enum
import '../extensions/i18n_extension.dart'; // Extension

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // วิธีที่ 1: ใช้ Generated Enum (Type Safe)
        title: Text(AppI18nKeys.LOGIN_TITLE.translate(context: context)),
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
              child: Text(AppI18nKeys.LOGIN_BUTTON.translate(context: context)),
            ),
            
            SizedBox(height: 16),
            
            TextButton(
              onPressed: () {
                // Handle forgot password
              },
              child: Text(
                context.i18n('FORGOT_PASSWORD', fallback: 'Forgot Password?'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 7.2 ใช้ Dynamic Translation (สำหรับ Keys ใหม่)

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

## 📋 ขั้นตอนที่ 8: สร้าง Makefile หรือ Script สำหรับ Convenience

### 8.1 สร้าง `Makefile` (Optional)

```makefile
# Makefile
.PHONY: help generate-i18n clean-i18n

help:
	@echo "Available commands:"
	@echo "  make generate-i18n  - Generate I18n enum from Directus"
	@echo "  make clean-i18n     - Clean generated I18n files"

generate-i18n:
	@echo "🚀 Generating I18n keys..."
	@dart run scripts/generate_i18n_keys.dart

clean-i18n:
	@echo "🧹 Cleaning generated I18n files..."
	@rm -rf lib/generated/*.dart
	@echo "✅ Clean complete!"
```

### 8.2 ใช้งาน Makefile

```bash
# Generate enum
make generate-i18n

# Clean generated files
make clean-i18n
```

---

## 🔄 Workflow การใช้งาน

### สำหรับ Developer

1. **เพิ่ม Keys ใหม่ใน Directus**
   - ไปที่ Directus CMS
   - เพิ่ม content ใน `app_content` collection
   - ตั้งค่า `status = published`

2. **Generate Enum ใหม่**
   ```bash
   dart run scripts/generate_i18n_keys.dart
   # หรือ
   make generate-i18n
   ```

3. **ใช้ Enum ในโค้ด**
   ```dart
   Text(AppI18nKeys.NEW_KEY.translate(context: context))
   ```

4. **หรือใช้ Dynamic Translation (ไม่ต้อง generate)**
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

### โครงสร้าง Project

```
your_app/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   └── env.dart
│   ├── extensions/
│   │   └── i18n_extension.dart
│   ├── pages/
│   │   ├── login_page.dart
│   │   └── home_page.dart
│   └── generated/          # Generated files
│       └── app_i18n_keys.dart
├── scripts/
│   └── generate_i18n_keys.dart
├── .env
├── pubspec.yaml
└── Makefile
```

### main.dart (Full Example)

```dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize HybridI18nService
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
    enumName: 'AppI18nKeys',
    autoGenerateEnum: false,
    enableDynamicFallback: true,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      locale: const Locale('th', 'TH'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('th', 'TH'),
      ],
      home: LoginPage(),
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

### ปัญหา: Enum ไม่มี Page Prefix

**ตรวจสอบ:**
1. ระบุ `pagePrefix` ใน `DirectusCollectionConfig` แล้วหรือไม่
2. `pagePrefix` ตรงกับ `key` ใน `app_page` collection หรือไม่
3. Status ของ page เป็น `published` หรือไม่

### ปัญหา: Translation ไม่ทำงาน

**ตรวจสอบ:**
1. Initialize service แล้วหรือยัง
2. Context ไม่เป็น null หรือไม่
3. Key มีอยู่ใน Directus หรือไม่
4. Status ของ content เป็น `published` หรือไม่

---

## 📚 เอกสารเพิ่มเติม

- [New Structure Usage Guide](NEW_STRUCTURE_USAGE.md) - คู่มือการใช้งานโครงสร้างใหม่
- [Enum with Page Prefix Guide](ENUM_WITH_PAGE_PREFIX.md) - คู่มือการใช้งาน Enum พร้อม Page Prefix
- [API Documentation](API_DOCUMENTATION_TH.md) - เอกสาร API ภาษาไทย

---

## ✅ Checklist

- [ ] เพิ่ม package ใน `pubspec.yaml`
- [ ] สร้างไฟล์ `.env` พร้อม configuration
- [ ] สร้าง script สำหรับ generate enum
- [ ] Generate enum จาก Directus
- [ ] Initialize service ใน `main.dart`
- [ ] สร้าง extension สำหรับใช้งานง่าย
- [ ] ใช้งานใน Widget
- [ ] ทดสอบการทำงาน

---

**🎉 เสร็จสิ้น! ตอนนี้คุณพร้อมใช้งาน directus_i18n ใน project ของคุณแล้ว**
