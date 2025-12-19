# 📖 คู่มือการใช้งาน Enum พร้อม Page Prefix

## 🎯 ภาพรวม

เมื่อใช้โครงสร้าง Directus ใหม่ (`app_page` + `app_content`) และระบุ `pagePrefix` ใน config, enum ที่ generate จะรวม page prefix เข้าไปในชื่อ enum ทำให้สามารถใช้ `LOGIN_TITLE` แทน `TITLE` ได้

## 📝 ตัวอย่าง

### โครงสร้างใน Directus

**app_page collection:**
```json
{
  "id": 1,
  "key": "login",
  "status": "published"
}
```

**app_content collection:**
```json
{
  "id": 1,
  "page": 1,
  "key": "TITLE",
  "translations": {
    "value(en-US)": "Login",
    "value(th-TH)": "เข้าสู่ระบบ"
  },
  "status": "published"
}
```

### การ Initialize

```dart
await HybridI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_content',
  collections: [
    DirectusCollectionConfig(
      name: 'app_content',
      pagePrefix: 'login', // ระบุ page prefix
    ),
  ],
  autoGenerateEnum: true,
);
```

### Enum ที่ถูก Generate

```dart
enum HybridI18nKeys implements I18nKey {
  empty('0', defaultFallbackKey: ''),
  LOGIN_TITLE('TITLE', defaultFallbackKey: 'Login'), // ← page prefix + key
  LOGIN_BUTTON('BUTTON', defaultFallbackKey: 'Login'),
  LOGIN_EMAIL('EMAIL', defaultFallbackKey: 'Email'),
  // ...
}
```

### การใช้งานในโค้ด

```dart
// ใช้ enum โดยตรง
Text(HybridI18nKeys.LOGIN_TITLE.translate())

// หรือใช้ key string (ยังคงใช้ key เดิมสำหรับ lookup)
Text(HybridI18nService.translate('TITLE')) // ใช้ key เดิม
```

## 🔧 รายละเอียดการทำงาน

### 1. การสร้าง Enum Name

เมื่อมี `pagePrefix`:
- `pagePrefix = "login"` + `key = "TITLE"` → `LOGIN_TITLE`
- `pagePrefix = "home"` + `key = "WELCOME"` → `HOME_WELCOME`

เมื่อไม่มี `pagePrefix`:
- `key = "TITLE"` → `TITLE` (ใช้ key เดิม)

### 2. Key สำหรับ Translation Lookup

Enum จะเก็บ key เดิมไว้สำหรับ translation lookup:
```dart
LOGIN_TITLE('TITLE', defaultFallbackKey: 'Login')
//          ^^^^^^
//          key เดิมที่ใช้สำหรับ lookup ใน Directus
```

### 3. การ Sanitize Enum Name

Enum name จะถูก sanitize ให้เป็น valid Dart identifier:
- แปลงเป็น uppercase
- แทนที่ dots, dashes, spaces ด้วย underscores
- ลบ invalid characters
- ลบ consecutive underscores

**ตัวอย่าง:**
- `login.title` → `LOGIN_TITLE`
- `home-page.welcome` → `HOME_PAGE_WELCOME`
- `profile.user name` → `PROFILE_USER_NAME`

## 📚 ตัวอย่างการใช้งานแบบเต็ม

### main.dart

```dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load();
  
  // Initialize with page prefix
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
    autoGenerateEnum: true,
  );
  
  runApp(MyApp());
}
```

### login_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'lib/generated/runtime_i18n_keys.dart'; // Generated enum

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ใช้ enum ที่มี page prefix
        title: Text(RuntimeI18nKeys.LOGIN_TITLE.translate()),
      ),
      body: Column(
        children: [
          // ใช้ enum
          Text(RuntimeI18nKeys.LOGIN_WELCOME.translate()),
          
          // หรือใช้ dynamic translation (ใช้ key เดิม)
          Text(
            HybridI18nService.translate(
              'TITLE', // ใช้ key เดิม
              context: context,
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🎨 หลาย Pages พร้อมกัน

### Initialize หลาย Pages

```dart
await HybridI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
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
    DirectusCollectionConfig(
      name: 'app_content',
      pagePrefix: 'profile',
    ),
  ],
  autoGenerateEnum: true,
);
```

### Enum ที่ถูก Generate

```dart
enum HybridI18nKeys implements I18nKey {
  empty('0', defaultFallbackKey: ''),
  
  // Login page
  LOGIN_TITLE('TITLE', defaultFallbackKey: 'Login'),
  LOGIN_BUTTON('BUTTON', defaultFallbackKey: 'Login'),
  
  // Home page
  HOME_WELCOME('WELCOME', defaultFallbackKey: 'Welcome'),
  HOME_DESCRIPTION('DESCRIPTION', defaultFallbackKey: 'Description'),
  
  // Profile page
  PROFILE_USERNAME('USERNAME', defaultFallbackKey: 'Username'),
  PROFILE_EMAIL('EMAIL', defaultFallbackKey: 'Email'),
  // ...
}
```

### การใช้งาน

```dart
// Login page
Text(RuntimeI18nKeys.LOGIN_TITLE.translate())
Text(RuntimeI18nKeys.LOGIN_BUTTON.translate())

// Home page
Text(RuntimeI18nKeys.HOME_WELCOME.translate())
Text(RuntimeI18nKeys.HOME_DESCRIPTION.translate())

// Profile page
Text(RuntimeI18nKeys.PROFILE_USERNAME.translate())
Text(RuntimeI18nKeys.PROFILE_EMAIL.translate())
```

## 🔍 การ Generate Enum

### ใช้ RuntimeEnumGenerator

```dart
await RuntimeEnumGenerator.generateAndStore(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_content',
  collections: [
    DirectusCollectionConfig(
      name: 'app_content',
      pagePrefix: 'login',
    ),
  ],
  enumName: 'AppI18nKeys',
);
```

### ใช้ DirectusI18nKeyGenerator

```dart
await DirectusI18nKeyGenerator.generate(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  outputPath: 'lib/generated/app_i18n_keys.dart',
  collectionName: 'app_content',
  pagePrefix: 'login', // ระบุ page prefix
  enumName: 'AppI18nKeys',
);
```

### ใช้ Script

```bash
# Generate enum with page prefix
dart run scripts/auto_generate_enum.dart \
  --base-url=https://your-directus.com \
  --access-token=your-token \
  --collection-name=app_content \
  --page-prefix=login
```

## ⚠️ สิ่งสำคัญที่ต้องจำ

1. **Enum Name vs Key**: Enum name จะรวม page prefix แต่ key สำหรับ lookup ยังคงเป็น key เดิม
2. **Case Sensitivity**: Enum name จะถูกแปลงเป็น uppercase อัตโนมัติ
3. **Sanitization**: Enum name จะถูก sanitize ให้เป็น valid Dart identifier
4. **Multiple Pages**: เมื่อมีหลาย pages, enum จะรวม keys จากทุก pages เข้าด้วยกัน

## 🆘 Troubleshooting

### ปัญหา: Enum name ไม่ถูกต้อง

**ตรวจสอบ:**
1. `pagePrefix` ถูกต้องหรือไม่
2. Key ใน Directus มีค่าหรือไม่
3. Status เป็น `published` หรือไม่

### ปัญหา: Enum ไม่มี page prefix

**ตรวจสอบ:**
1. ระบุ `pagePrefix` ใน `DirectusCollectionConfig` แล้วหรือไม่
2. `pagePrefix` ตรงกับ `key` ใน `app_page` หรือไม่

### ปัญหา: Enum name ซ้ำกัน

**แก้ไข:**
- ใช้ `prefix` ใน `DirectusCollectionConfig` เพื่อแยก keys จาก pages ต่างๆ
- หรือใช้ `pagePrefix` ที่แตกต่างกัน

---

## 📚 เอกสารเพิ่มเติม

- [New Structure Usage Guide](NEW_STRUCTURE_USAGE.md) - คู่มือการใช้งานโครงสร้างใหม่
- [Runtime Enum Guide](RUNTIME_ENUM_GUIDE.md) - คู่มือ Runtime Enum
- [API Documentation](API_DOCUMENTATION_TH.md) - เอกสาร API ภาษาไทย
