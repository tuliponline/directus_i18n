# คู่มือการใช้งาน Directus I18n แบบละเอียด

คู่มือฉบับสมบูรณ์สำหรับการใช้งาน `directus_i18n` package ใน Flutter project

## สารบัญ

1. [การติดตั้ง](#การติดตั้ง)
2. [การตั้งค่า Directus](#การตั้งค่า-directus)
3. [การตั้งค่าใน Flutter Project](#การตั้งค่าใน-flutter-project)
4. [วิธีการใช้งาน](#วิธีการใช้งาน)
5. [ตัวอย่างโค้ด](#ตัวอย่างโค้ด)
6. [การ Generate Enum Keys](#การ-generate-enum-keys)
7. [การจัดการ Locale](#การจัดการ-locale)
8. [Error Handling](#error-handling)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

---

## การติดตั้ง

### 1. เพิ่ม Package ใน pubspec.yaml

```yaml
dependencies:
  directus_i18n:
    git:
      url: https://github.com/tuliponline/directus_i18n.git
      ref: v1.0.9  # หรือใช้ branch/commit ที่ต้องการ
```

หรือถ้า publish แล้ว:

```yaml
dependencies:
  directus_i18n: ^1.0.9
```

### 2. ติดตั้ง Dependencies

```bash
flutter pub get
```

### 3. เพิ่ม Environment Variables

สร้างไฟล์ `.env` ใน root ของ project:

```env
DIRECTUS_BASE_URL=https://your-directus-instance.com
DIRECTUS_ACCESS_TOKEN=your-access-token-here
DIRECTUS_COLLECTION_NAME=app_content
I18N_ENUM_NAME=AppI18nKeys
```

**หมายเหตุ:** อย่าลืมเพิ่ม `.env` ใน `.gitignore` เพื่อความปลอดภัย

---

## การตั้งค่า Directus

### โครงสร้าง Collections ที่ต้องมี

#### 1. Collection: `app_page`

ใช้สำหรับเก็บ page prefixes:

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `key` | String | Page prefix (เช่น "login", "home") |
| `status` | String | Status: "published", "draft", "archived" |

**ตัวอย่างข้อมูล:**
```json
{
  "id": "uuid-1",
  "key": "login",
  "status": "published"
}
```

#### 2. Collection: `app_content`

ใช้สำหรับเก็บ translations:

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `page` | Relation | Foreign key ไปยัง `app_page` |
| `key` | String | Translation key (เช่น "TITLE", "SUBTITLE") |
| `translations` | Relation | Relation ไปยัง `app_content_translations` |
| `status` | String | Status: "published", "draft", "archived" |

#### 3. Collection: `app_content_translations`

ใช้สำหรับเก็บค่า translations แต่ละภาษา:

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `app_content_id` | Relation | Foreign key ไปยัง `app_content` |
| `languages_code` | String | Language code (เช่น "en-US", "th-TH") |
| `value` | String | ข้อความที่แปล |

**ตัวอย่างโครงสร้างข้อมูล:**

```json
{
  "id": 1,
  "key": "TITLE",
  "page": {
    "id": "uuid-1",
    "key": "login"
  },
  "status": "published",
  "translations": [
    {
      "id": 1,
      "app_content_id": 1,
      "languages_code": "en-US",
      "value": "Login"
    },
    {
      "id": 2,
      "app_content_id": 1,
      "languages_code": "th-TH",
      "value": "เข้าสู่ระบบ"
    }
  ]
}
```

---

## การตั้งค่าใน Flutter Project

### 1. ตั้งค่า Environment Variables

ติดตั้ง `flutter_dotenv`:

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

โหลด `.env` ใน `main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // โหลด environment variables
  await dotenv.load(fileName: ".env");
  
  runApp(MyApp());
}
```

### 2. Initialize Directus I18n Service

ใน `main.dart` หรือ `initState` ของ app:

```dart
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> initializeI18n() async {
  await HybridI18nService.init(
    baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
    accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
    collectionName: dotenv.env['DIRECTUS_COLLECTION_NAME'] ?? 'app_content',
    collections: [
      DirectusCollectionConfig(
        name: 'app_content',
        pagePrefix: 'login', // Optional: filter by page prefix
      ),
      DirectusCollectionConfig(
        name: 'app_content',
        pagePrefix: 'home', // สามารถมีหลาย page prefixes
      ),
    ],
    enumName: dotenv.env['I18N_ENUM_NAME'] ?? 'AppI18nKeys',
    autoGenerateEnum: true, // Auto generate enum on init
    enableDynamicFallback: true, // Enable dynamic loading fallback
  );
}
```

### 3. ตั้งค่า MaterialApp

```dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      // ตั้งค่า supported locales
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('th', 'TH'),
      ],
      // ตั้งค่า locale delegates
      localizationsDelegates: const [
        DirectusI18nDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // ตั้งค่า locale resolution
      localeResolutionCallback: (locale, supportedLocales) {
        // Return locale if supported, otherwise return first supported locale
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      home: MyHomePage(),
    );
  }
}
```

---

## วิธีการใช้งาน

### 1. การใช้งานแบบ Dynamic (ไม่ต้อง Generate Enum)

```dart
import 'package:directus_i18n/directus_i18n.dart';

// ใช้งานใน Widget
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          HybridI18nService.translate(
            'TITLE',
            context: context,
            fallback: 'Login',
          ),
        ),
      ),
      body: Column(
        children: [
          Text(
            HybridI18nService.translate(
              'SUBTITLE',
              context: context,
              fallback: 'Welcome back',
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: HybridI18nService.translate(
                'EMAIL_LABEL',
                context: context,
                fallback: 'Email',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2. การใช้งานแบบ Enum (Type-Safe)

#### Step 1: Generate Enum Keys

สร้าง script `scripts/generate_i18n.dart`:

```dart
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  
  await KeyGenerator.generate(
    baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
    accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
    outputPath: 'lib/generated/app_i18n_keys.dart',
    collectionName: 'app_content',
    enumName: 'AppI18nKeys',
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
  
  print('✅ I18n keys generated successfully!');
}
```

รัน script:

```bash
dart run scripts/generate_i18n.dart
```

#### Step 2: ใช้งาน Enum ในโค้ด

```dart
import 'package:directus_i18n/directus_i18n.dart';
import 'package:my_app/generated/app_i18n_keys.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppI18nKeys.LOGIN_TITLE.translate(context: context),
        ),
      ),
      body: Column(
        children: [
          Text(
            AppI18nKeys.LOGIN_SUBTITLE.translate(context: context),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: AppI18nKeys.LOGIN_EMAIL_LABEL.translate(context: context),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. การใช้งานแบบ Hybrid (แนะนำ)

Hybrid approach จะใช้ enum ก่อน แล้ว fallback ไป dynamic ถ้าไม่พบ:

```dart
import 'package:directus_i18n/directus_i18n.dart';
import 'package:my_app/generated/app_i18n_keys.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ใช้ HybridI18nService ซึ่งจะใช้ enum ก่อน แล้ว fallback ไป dynamic
    final title = HybridI18nService.translate(
      'LOGIN_TITLE', // หรือ AppI18nKeys.LOGIN_TITLE.key
      context: context,
      fallback: 'Login',
    );
    
    return Text(title);
  }
}
```

---

## ตัวอย่างโค้ด

### ตัวอย่างที่ 1: Login Page

```dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          HybridI18nService.translate(
            'TITLE',
            context: context,
            fallback: 'Login',
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              HybridI18nService.translate(
                'WELCOME_MESSAGE',
                context: context,
                fallback: 'Welcome back!',
              ),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 32),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: HybridI18nService.translate(
                  'EMAIL_LABEL',
                  context: context,
                  fallback: 'Email',
                ),
                hintText: HybridI18nService.translate(
                  'EMAIL_HINT',
                  context: context,
                  fallback: 'Enter your email',
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: HybridI18nService.translate(
                  'PASSWORD_LABEL',
                  context: context,
                  fallback: 'Password',
                ),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Handle login
              },
              child: Text(
                HybridI18nService.translate(
                  'LOGIN_BUTTON',
                  context: context,
                  fallback: 'Login',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Handle forgot password
              },
              child: Text(
                HybridI18nService.translate(
                  'FORGOT_PASSWORD',
                  context: context,
                  fallback: 'Forgot password?',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

### ตัวอย่างที่ 2: ใช้กับ Parameters

```dart
// ใน Directus: WELCOME_MESSAGE = "Welcome, {name}!"

Text(
  HybridI18nService.translate(
    'WELCOME_MESSAGE',
    context: context,
    params: {'name': 'John'},
    fallback: 'Welcome, {name}!',
  ),
)
// Output: "Welcome, John!"
```

### ตัวอย่างที่ 3: เปลี่ยนภาษาแบบ Dynamic

```dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

class LanguageSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<Locale>(
      value: Localizations.localeOf(context),
      items: [
        DropdownMenuItem(
          value: Locale('en', 'US'),
          child: Text('English'),
        ),
        DropdownMenuItem(
          value: Locale('th', 'TH'),
          child: Text('ไทย'),
        ),
      ],
      onChanged: (Locale? locale) {
        if (locale != null) {
          // เปลี่ยน locale ของ app
          // ต้องใช้ state management หรือ package เช่น easy_localization
        }
      },
    );
  }
}
```

---

## การ Generate Enum Keys

### วิธีที่ 1: ใช้ Script

สร้างไฟล์ `scripts/generate_i18n.dart`:

```dart
import 'dart:io';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // โหลด environment variables
  await dotenv.load(fileName: ".env");
  
  try {
    await KeyGenerator.generate(
      baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
      accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
      outputPath: 'lib/generated/app_i18n_keys.dart',
      collectionName: 'app_content',
      enumName: 'AppI18nKeys',
      collections: [
        DirectusCollectionConfig(
          name: 'app_content',
          pagePrefix: 'login',
        ),
        DirectusCollectionConfig(
          name: 'app_content',
          pagePrefix: 'home',
        ),
        // เพิ่ม page prefixes อื่นๆ ตามต้องการ
      ],
    );
    
    print('✅ I18n keys generated successfully!');
    print('📁 Output: lib/generated/app_i18n_keys.dart');
  } catch (e) {
    print('❌ Error generating i18n keys: $e');
    exit(1);
  }
}
```

รัน script:

```bash
dart run scripts/generate_i18n.dart
```

### วิธีที่ 2: ใช้ Auto Enum Service

```dart
await AutoEnumService.init(
  baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
  accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
  collectionName: 'app_content',
  collections: [
    DirectusCollectionConfig(
      name: 'app_content',
      pagePrefix: 'login',
    ),
  ],
  enumName: 'AppI18nKeys',
  outputPath: 'lib/generated/app_i18n_keys.dart',
  autoGenerate: true, // Auto generate on init
  checkForUpdates: true, // Check for updates periodically
);
```

### วิธีที่ 3: ใช้ Runtime Enum Generator

```dart
await RuntimeEnumGenerator.generateAndStore(
  baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
  accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
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

---

## การจัดการ Locale

### 1. ตั้งค่า Supported Locales

```dart
MaterialApp(
  supportedLocales: const [
    Locale('en', 'US'),
    Locale('th', 'TH'),
    Locale('ja', 'JP'), // เพิ่มภาษาอื่นๆ ตามต้องการ
  ],
  // ...
)
```

### 2. ตั้งค่า Default Locale

```dart
MaterialApp(
  locale: Locale('th', 'TH'), // ตั้งค่า default locale
  // ...
)
```

### 3. เปลี่ยน Locale แบบ Dynamic

```dart
import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en', 'US');

  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('th', 'TH'),
      ],
      // ...
    );
  }
}
```

### 4. ใช้กับ easy_localization

```dart
import 'package:easy_localization/easy_localization.dart';

// Initialize
await EasyLocalization.ensureInitialized();

// ใน MaterialApp
EasyLocalization(
  supportedLocales: [Locale('en'), Locale('th')],
  path: 'assets/translations',
  fallbackLocale: Locale('en'),
  child: MaterialApp(
    localizationsDelegates: [
      DirectusI18nDelegate(), // เพิ่ม DirectusI18nDelegate
      ...context.localizationDelegates,
    ],
    // ...
  ),
)
```

---

## Error Handling

### 1. Handle Missing Translations

```dart
final translation = HybridI18nService.translate(
  'SOME_KEY',
  context: context,
  fallback: 'Default Text', // จะใช้ถ้าไม่พบ translation
);
```

### 2. Handle API Errors

```dart
await HybridI18nService.init(
  baseUrl: baseUrl,
  accessToken: accessToken,
  collectionName: 'app_content',
  onError: (error, stackTrace) {
    // Handle error
    print('Error loading translations: $error');
    // อาจจะแสดง error dialog หรือ fallback ไปใช้ local translations
  },
);
```

### 3. Check Service Status

```dart
final status = HybridI18nService.getStatus();
print('Initialized: ${status['initialized']}');
print('Dynamic Keys Count: ${status['dynamicKeysCount']}');
print('Has Generated Enum: ${status['hasGeneratedEnum']}');
```

### 4. Refresh Translations

```dart
// Refresh translations from Directus
await HybridI18nService.refresh();

// หรือ refresh specific locale
await DynamicI18nService.refreshKeys(locale: Locale('th', 'TH'));
```

---

## Best Practices

### 1. ใช้ Enum Keys เมื่อเป็นไปได้

```dart
// ✅ Good: Type-safe, auto-complete
AppI18nKeys.LOGIN_TITLE.translate(context: context)

// ⚠️ Acceptable: Dynamic fallback
HybridI18nService.translate('LOGIN_TITLE', context: context)
```

### 2. ใช้ Fallback เสมอ

```dart
// ✅ Good: มี fallback
HybridI18nService.translate(
  'KEY',
  context: context,
  fallback: 'Default Text',
)

// ❌ Bad: ไม่มี fallback
HybridI18nService.translate('KEY', context: context)
```

### 3. ตั้งค่า Error Handler

```dart
await HybridI18nService.init(
  // ...
  onError: (error, stackTrace) {
    // Log error
    logger.error('Translation error', error: error);
    // อาจจะส่งไปยัง error tracking service
  },
);
```

### 4. Cache Translations

Library จะ cache translations อัตโนมัติ แต่ถ้าต้องการ refresh:

```dart
// Refresh เมื่อ app start หรือเมื่อ user pull to refresh
await HybridI18nService.refresh();
```

### 5. ใช้ Page Prefixes

```dart
// ✅ Good: แยก translations ตาม page
DirectusCollectionConfig(
  name: 'app_content',
  pagePrefix: 'login', // เฉพาะ login page
)

// ⚠️ Acceptable: ใช้ทั้งหมด
DirectusCollectionConfig(
  name: 'app_content',
  // ไม่ระบุ pagePrefix = ใช้ทั้งหมด
)
```

### 6. Generate Enum Keys ใน CI/CD

```yaml
# .github/workflows/generate_i18n.yml
name: Generate I18n Keys

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: dart run scripts/generate_i18n.dart
      - run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add lib/generated/
          git commit -m "chore: Update i18n keys" || exit 0
          git push
```

---

## Troubleshooting

### ปัญหา: ไม่พบ Translations

**สาเหตุ:**
- Key ไม่ถูกต้อง
- Locale ไม่ตรงกับ Directus
- Page prefix ไม่ถูกต้อง
- Status ไม่ใช่ "published"

**แก้ไข:**
```dart
// ตรวจสอบ keys ที่มี
final allKeys = HybridI18nService.getAllKeys();
print('Available keys: $allKeys');

// ตรวจสอบ service status
final status = HybridI18nService.getStatus();
print('Status: $status');
```

### ปัญหา: API Error 400

**สาเหตุ:**
- Access token ไม่ถูกต้อง
- Base URL ไม่ถูกต้อง
- Collection name ไม่ถูกต้อง

**แก้ไข:**
```dart
// ตรวจสอบ configuration
print('Base URL: ${dotenv.env['DIRECTUS_BASE_URL']}');
print('Collection: ${dotenv.env['DIRECTUS_COLLECTION_NAME']}');

// ทดสอบ API โดยตรง
final dio = Dio();
final response = await dio.get(
  '${baseUrl}/items/app_content',
  queryParameters: {
    'access_token': accessToken,
    'limit': 1,
  },
);
print('Response: ${response.data}');
```

### ปัญหา: Enum ไม่ Generate

**สาเหตุ:**
- Output path ไม่ถูกต้อง
- Permissions ไม่เพียงพอ
- Collection ไม่มีข้อมูล

**แก้ไข:**
```dart
// ตรวจสอบ output path
final outputFile = File('lib/generated/app_i18n_keys.dart');
print('Output path exists: ${await outputFile.exists()}');

// ตรวจสอบข้อมูลใน Directus
final response = await dio.get(
  '${baseUrl}/items/app_content',
  queryParameters: {
    'access_token': accessToken,
    'filter[status][_eq]': 'published',
    'limit': 5,
  },
);
print('Data count: ${response.data['data'].length}');
```

### ปัญหา: Locale ไม่เปลี่ยน

**สาเหตุ:**
- MaterialApp ไม่มี locale resolution
- Locale ไม่ได้อยู่ใน supportedLocales

**แก้ไข:**
```dart
MaterialApp(
  locale: currentLocale, // ตั้งค่า locale
  supportedLocales: [Locale('en'), Locale('th')],
  localeResolutionCallback: (locale, supportedLocales) {
    return locale ?? supportedLocales.first;
  },
  // ...
)
```

---

## สรุป

### Quick Start Checklist

- [ ] ติดตั้ง package ใน `pubspec.yaml`
- [ ] สร้างไฟล์ `.env` และตั้งค่า credentials
- [ ] Initialize service ใน `main.dart`
- [ ] ตั้งค่า `MaterialApp` พร้อม `DirectusI18nDelegate`
- [ ] Generate enum keys (optional แต่แนะนำ)
- [ ] ทดสอบการใช้งาน

### Resources

- [Directus Setup Guide](./DIRECTUS_SETUP_GUIDE.md)
- [New Structure Usage](./NEW_STRUCTURE_USAGE.md)
- [Project Setup Guide](./PROJECT_SETUP_GUIDE.md)
- [Testing Guide](./TESTING_GUIDE.md)
- [Monster App Integration](./MONSTER_APP_INTEGRATION.md)

### Support

หากพบปัญหาหรือต้องการความช่วยเหลือ:
- ตรวจสอบ [Troubleshooting](#troubleshooting) section
- ดูตัวอย่างใน [example/](./example/) directory
- ตรวจสอบ test files ใน [test/](./test/) directory
