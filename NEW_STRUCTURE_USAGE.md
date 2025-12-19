# 📖 คู่มือการใช้งานโครงสร้าง Directus ใหม่

## 🎯 โครงสร้างใหม่

### Collections ใน Directus

#### 1. `app_page` Collection
เก็บข้อมูล page prefix ของแต่ละหน้า

**Fields:**
- `id` - ID ของ page
- `key` - Page prefix (เช่น "login", "home", "profile")
- `status` - สถานะ (published, draft, archived)

**ตัวอย่างข้อมูล:**
```json
{
  "id": 1,
  "key": "login",
  "status": "published"
}
```

#### 2. `app_content` Collection
เก็บข้อมูลการแปลภาษาของแต่ละ page

**Fields:**
- `id` - ID ของ content
- `page` - Relation ไปยัง `app_page` (ใช้ ID)
- `key` - Key ของ content (เช่น "LOGIN_TITLE", "LOGIN_BUTTON")
- `translations` - Object ที่มี:
  - `value(en-US)` - ข้อความภาษาอังกฤษ
  - `value(th-TH)` - ข้อความภาษาไทย
- `status` - สถานะ (published, draft, archived)

**ตัวอย่างข้อมูล:**
```json
{
  "id": 1,
  "page": 1,
  "key": "LOGIN_TITLE",
  "translations": {
    "value(en-US)": "Login",
    "value(th-TH)": "เข้าสู่ระบบ"
  },
  "status": "published"
}
```

---

## 🚀 วิธีใช้งาน

### 1. การ Initialize Service

#### วิธีที่ 1: ใช้ DirectusI18nService (พื้นฐาน)

```dart
import 'package:directus_i18n/directus_i18n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize service
  DirectusI18nService.init(
    baseUrl: 'https://your-directus.com',
    accessToken: 'your-access-token',
    collectionName: 'app_content', // ใช้ collection ใหม่
    pagePrefix: 'login', // Optional: กรองตาม page prefix
  );
  
  runApp(MyApp());
}
```

#### วิธีที่ 2: ใช้ HybridI18nService (แนะนำ)

```dart
import 'package:directus_i18n/directus_i18n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize HybridI18nService
  await HybridI18nService.init(
    baseUrl: 'https://your-directus.com',
    accessToken: 'your-access-token',
    collectionName: 'app_content',
    collections: [
      // หลาย pages
      DirectusCollectionConfig(
        name: 'app_content',
        pagePrefix: 'login', // Filter ตาม page prefix
        prefix: 'LOGIN.', // Optional: เพิ่ม prefix ให้ key
      ),
      DirectusCollectionConfig(
        name: 'app_content',
        pagePrefix: 'home',
        prefix: 'HOME.',
      ),
    ],
    autoGenerateEnum: true, // Generate enum อัตโนมัติ
    enableDynamicFallback: true, // ใช้ dynamic fallback
  );
  
  runApp(MyApp());
}
```

#### วิธีที่ 3: ใช้ DynamicI18nService (Dynamic เท่านั้น)

```dart
import 'package:directus_i18n/directus_i18n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize DynamicI18nService
  await DynamicI18nService.init(
    baseUrl: 'https://your-directus.com',
    accessToken: 'your-access-token',
    collectionName: 'app_content',
    pagePrefix: 'login', // Optional: กรองตาม page prefix
    locale: const Locale('th', 'TH'), // Optional: ระบุ locale
  );
  
  runApp(MyApp());
}
```

#### วิธีที่ 4: ใช้ CombinedI18nService (รวม I18n + Error Codes)

```dart
import 'package:directus_i18n/directus_i18n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize CombinedI18nService
  await CombinedI18nService.init(
    baseUrl: 'https://your-directus.com',
    accessToken: 'your-access-token',
    i18nCollectionName: 'app_content',
    i18nCollections: [
      DirectusCollectionConfig(
        name: 'app_content',
        pagePrefix: 'login',
      ),
    ],
    errorCollectionName: 'error_codes',
    autoGenerateEnum: true,
    enableDynamicFallback: true,
  );
  
  runApp(MyApp());
}
```

---

### 2. การใช้งานใน Widget

#### วิธีที่ 1: ใช้ HybridI18nService.translate()

```dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          HybridI18nService.translate(
            'LOGIN_TITLE',
            context: context,
            fallback: 'Login',
          ),
        ),
      ),
      body: Column(
        children: [
          Text(
            HybridI18nService.translate(
              'LOGIN_WELCOME',
              context: context,
              params: {'name': 'John'},
              fallback: 'Welcome, {name}!',
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text(
              HybridI18nService.translate(
                'LOGIN_BUTTON',
                context: context,
                fallback: 'Login',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### วิธีที่ 2: ใช้ Extension (แนะนำ)

สร้าง extension สำหรับใช้งานง่าย:

```dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

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
```

ใช้งานใน Widget:

```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.i18n('LOGIN_TITLE', fallback: 'Login')),
      ),
      body: Column(
        children: [
          Text(
            context.i18n(
              'LOGIN_WELCOME',
              params: {'name': 'John'},
              fallback: 'Welcome, {name}!',
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text(context.i18n('LOGIN_BUTTON', fallback: 'Login')),
          ),
        ],
      ),
    );
  }
}
```

#### วิธีที่ 3: ใช้ DynamicI18nWidget

```dart
import 'package:directus_i18n/directus_i18n.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DynamicI18nText(
          'LOGIN_TITLE',
          fallback: 'Login',
        ),
      ),
      body: Column(
        children: [
          DynamicI18nText(
            'LOGIN_WELCOME',
            params: {'name': 'John'},
            fallback: 'Welcome, {name}!',
          ),
          ElevatedButton(
            onPressed: () {},
            child: DynamicI18nText('LOGIN_BUTTON', fallback: 'Login'),
          ),
        ],
      ),
    );
  }
}
```

---

### 3. การกรองตาม Page Prefix

#### กรองเฉพาะ Page เดียว

```dart
// Initialize เฉพาะ login page
await HybridI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_content',
  collections: [
    DirectusCollectionConfig(
      name: 'app_content',
      pagePrefix: 'login', // กรองเฉพาะ login page
    ),
  ],
);
```

#### หลาย Pages พร้อมกัน

```dart
// Initialize หลาย pages
await HybridI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_content',
  collections: [
    DirectusCollectionConfig(
      name: 'app_content',
      pagePrefix: 'login',
      prefix: 'LOGIN.', // เพิ่ม prefix ให้ key
    ),
    DirectusCollectionConfig(
      name: 'app_content',
      pagePrefix: 'home',
      prefix: 'HOME.',
    ),
    DirectusCollectionConfig(
      name: 'app_content',
      pagePrefix: 'profile',
      prefix: 'PROFILE.',
    ),
  ],
);

// ใช้งาน
context.i18n('LOGIN.LOGIN_TITLE'); // จาก login page
context.i18n('HOME.WELCOME'); // จาก home page
context.i18n('PROFILE.USERNAME'); // จาก profile page
```

#### ไม่กรอง (โหลดทุก Pages)

```dart
// Initialize โดยไม่ระบุ pagePrefix
await HybridI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_content',
  // ไม่ระบุ pagePrefix = โหลดทุก pages
);
```

---

### 4. การจัดการ Locale

#### เปลี่ยน Locale

```dart
// ใน MaterialApp
MaterialApp(
  locale: const Locale('th', 'TH'), // ภาษาไทย
  // หรือ
  locale: const Locale('en', 'US'), // ภาษาอังกฤษ
  localizationsDelegates: [
    // ... other delegates
  ],
  supportedLocales: [
    const Locale('en', 'US'),
    const Locale('th', 'TH'),
  ],
  // ...
)
```

#### ตรวจสอบ Locale ปัจจุบัน

```dart
final locale = Localizations.localeOf(context);
print('Current locale: ${locale.toString()}'); // th_TH หรือ en_US
```

---

### 5. การ Refresh/Reload Translations

#### Refresh ทั้งหมด

```dart
// Refresh HybridI18nService
await HybridI18nService.refresh();

// หรือ Refresh CombinedI18nService
await CombinedI18nService.refresh();
```

#### Refresh Dynamic Cache

```dart
await HybridI18nService.refreshDynamicCache(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_content',
  collections: [
    DirectusCollectionConfig(
      name: 'app_content',
      pagePrefix: 'login',
    ),
  ],
);
```

---

### 6. การตรวจสอบ Status

#### ตรวจสอบ Service Status

```dart
// ตรวจสอบ HybridI18nService
final status = HybridI18nService.getStatus();
print('Initialized: ${status['initialized']}');
print('Dynamic Keys Count: ${status['dynamicKeysCount']}');
print('Has Generated Enum: ${status['hasGeneratedEnum']}');

// ตรวจสอบ CombinedI18nService
final combinedStatus = CombinedI18nService.getStatus();
print('I18n Keys: ${combinedStatus['combined']['i18nKeysCount']}');
print('Error Codes: ${combinedStatus['combined']['errorCodesCount']}');
```

#### ตรวจสอบ Key

```dart
// ตรวจสอบว่ามี key หรือไม่
final hasKey = HybridI18nService.hasKey('LOGIN_TITLE');
print('Has LOGIN_TITLE: $hasKey');

// ตรวจสอบ key สำหรับภาษาเฉพาะ
final hasKeyForLang = HybridI18nService.hasKeyForLanguage(
  'LOGIN_TITLE',
  'th-TH',
);
print('Has LOGIN_TITLE for th-TH: $hasKeyForLang');

// ดึง keys ทั้งหมด
final allKeys = HybridI18nService.getAllKeys();
print('All keys: $allKeys');
```

---

## 📝 ตัวอย่างการใช้งานแบบเต็ม

### main.dart

```dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        prefix: 'LOGIN.',
      ),
      DirectusCollectionConfig(
        name: 'app_content',
        pagePrefix: 'home',
        prefix: 'HOME.',
      ),
    ],
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
      locale: const Locale('th', 'TH'),
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('th', 'TH'),
      ],
      localizationsDelegates: [
        // ... other delegates
      ],
      home: HomePage(),
    );
  }
}
```

### login_page.dart

```dart
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

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

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.i18n('LOGIN.LOGIN_TITLE', fallback: 'Login')),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.i18n('LOGIN.WELCOME_MESSAGE', fallback: 'Welcome'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 24),
            TextField(
              decoration: InputDecoration(
                labelText: context.i18n('LOGIN.EMAIL_LABEL', fallback: 'Email'),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: context.i18n('LOGIN.PASSWORD_LABEL', fallback: 'Password'),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Handle login
              },
              child: Text(
                context.i18n('LOGIN.LOGIN_BUTTON', fallback: 'Login'),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Handle forgot password
              },
              child: Text(
                context.i18n('LOGIN.FORGOT_PASSWORD', fallback: 'Forgot Password?'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔍 Debugging

### ตรวจสอบว่า Service Initialize แล้วหรือไม่

```dart
final status = HybridI18nService.getStatus();
if (status['initialized'] == true) {
  print('✅ Service initialized');
} else {
  print('❌ Service not initialized');
}
```

### ตรวจสอบ Keys ที่โหลดมา

```dart
final allKeys = HybridI18nService.getAllKeys();
print('Loaded keys: ${allKeys.length}');
for (final key in allKeys) {
  print('- $key');
}
```

### ตรวจสอบ Translation โดยตรง

```dart
final translation = HybridI18nService.translate(
  'LOGIN_TITLE',
  context: context,
  fallback: 'Login',
);
print('Translation: $translation');
```

### Enable Debug Logging

```dart
import 'package:logger/logger.dart';

// ใน main.dart
Logger.level = Level.debug;
```

---

## ⚠️ สิ่งสำคัญที่ต้องจำ

1. **Page Prefix**: ต้องตรงกับ `key` ใน `app_page` collection
2. **Status**: เฉพาะ `status = 'published'` เท่านั้นที่จะถูกโหลด
3. **Translations Structure**: ใช้ `translations.value(en-US)` และ `translations.value(th-TH)`
4. **Locale Format**: ใช้ format `en-US` หรือ `th-TH` (มี dash)
5. **Collection Name**: ใช้ `app_content` สำหรับโครงสร้างใหม่

---

## 🆘 Troubleshooting

### ปัญหา: ไม่พบ Translation

**ตรวจสอบ:**
1. Page prefix ถูกต้องหรือไม่
2. Key มีอยู่ใน `app_content` หรือไม่
3. Status เป็น `published` หรือไม่
4. Translation field มีค่า (`value(en-US)` หรือ `value(th-TH)`) หรือไม่

### ปัญหา: Service ไม่ Initialize

**ตรวจสอบ:**
1. เรียก `init()` แล้วหรือยัง
2. `baseUrl` และ `accessToken` ถูกต้องหรือไม่
3. Network connection ใช้งานได้หรือไม่

### ปัญหา: Locale ไม่เปลี่ยน

**ตรวจสอบ:**
1. ตั้งค่า `locale` ใน `MaterialApp` แล้วหรือยัง
2. `supportedLocales` รวม locale ที่ต้องการหรือไม่
3. Translation มีค่าสำหรับ locale นั้นหรือไม่

---

## 📚 เอกสารเพิ่มเติม

- [QUICK_START.md](QUICK_START.md) - คู่มือเริ่มต้นใช้งาน
- **[ENUM_WITH_PAGE_PREFIX.md](ENUM_WITH_PAGE_PREFIX.md)** - คู่มือการใช้งาน Enum พร้อม Page Prefix ⭐
- [API_DOCUMENTATION_TH.md](API_DOCUMENTATION_TH.md) - เอกสาร API ภาษาไทย
- [DYNAMIC_I18N_GUIDE.md](DYNAMIC_I18N_GUIDE.md) - คู่มือ Dynamic I18n
- [RUNTIME_ENUM_GUIDE.md](RUNTIME_ENUM_GUIDE.md) - คู่มือ Runtime Enum
