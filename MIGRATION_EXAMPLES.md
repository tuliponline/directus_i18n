## 🔍 การ Debug ปัญหา Fallback

### ตรวจสอบ HybridI18nService ได้ Init แล้วหรือไม่

```dart
// เพิ่มโค้ดนี้ใน main.dart หลัง init
final status = HybridI18nService.getStatus();
print('HybridI18n Status: $status');

// หรือใน Widget
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final status = HybridI18nService.getStatus();
    print('HybridI18n Status: $status');
  });
}
```

### ตรวจสอบ Key มีอยู่ใน Cache หรือไม่

```dart
// ตรวจสอบ key ต่างๆ
final allKeys = HybridI18nService.getAllKeys();
print('Available keys: $allKeys');

// ตรวจสอบ key เฉพาะ
final hasKey = HybridI18nService.hasKey('LOGIN_TITLE');
print('Has LOGIN_TITLE: $hasKey');
```

### ทดสอบ Translation โดยตรง

```dart
// ทดสอบโดยตรง (ไม่ใช้ extension)
final translation = HybridI18nService.translate(
  'LOGIN_TITLE',
  context: context,
  fallback: 'Login'
);
print('Direct translation: $translation');
```

### ตรวจสอบ Extension ที่สร้างเอง

```dart
// แก้ไข extension ให้มี debug
extension BuildContextHybridI18nExtension on BuildContext {
  String i18n(String key, {String? fallback}) {
    print('🔍 Translating key: $key, fallback: $fallback');

    final result = HybridI18nService.translate(
      key,
      fallback: fallback ?? key,
      context: this,
    );

    print('📝 Result: $result');
    return result;
  }
}
```

### สาเหตุที่เป็นไปได้

#### 1. HybridI18nService ยังไม่ได้ Init
```dart
// ตรวจสอบใน main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ตรวจสอบว่ามี dotenv หรือ env ต่างๆ
  await dotenv.load();

  // Init ตรงนี้
  await HybridI18nService.init(
    baseUrl: dotenv.get('DIRECTUS_BASE_URL'),
    accessToken: dotenv.get('DIRECTUS_ACCESS_TOKEN'),
    collections: [
      DirectusCollectionConfig(name: 'contents', prefix: ''),
      DirectusCollectionConfig(name: 'login_page', prefix: 'LOGINPAGE.'),
    ],
    autoGenerateEnum: true,
  );

  runApp(MyApp());
}
```

#### 2. Directus Collection ไม่มี Key
- ตรวจสอบใน Directus CMS ว่ามี collection `login_page` และมี field `LOGIN_TITLE` หรือไม่
- ตรวจสอบโครงสร้าง: collection → items → translations → message

#### 3. Network Error หรือ Auth Error
```dart
// เพิ่ม error handling
try {
  await HybridI18nService.init(...);
  print('✅ Init success');
} catch (e) {
  print('❌ Init failed: $e');
}
```

#### 4. Context เป็น Null
```dart
// ตรวจสอบ context
Text(context != null ? context.i18n('LOGIN_TITLE', fallback: 'Login') : 'No context');
```

### โครงสร้าง Directus ที่ถูกต้อง

#### Collection: `login_page`
```json
{
  "LOGIN_TITLE": {
    "key": "LOGIN_TITLE",
    "translations": [
      {
        "language_code": "en",
        "message": "Login"
      },
      {
        "language_code": "th",
        "message": "เข้าสู่ระบบ"
      }
    ]
  }
}
```

### วิธีแก้ไขด่วน

#### ถ้าอยากให้ทำงานก่อน
```dart
// ใช้แบบตรงๆ ไม่ต้องรอ init
Text('Login'); // Hard-coded ชั่วคราว

// หรือใช้ FutureBuilder
FutureBuilder<String>(
  future: _loadTranslation('LOGIN_TITLE'),
  builder: (context, snapshot) {
    return Text(snapshot.data ?? 'Login');
  },
);

Future<String> _loadTranslation(String key) async {
  await Future.delayed(Duration(seconds: 1)); // รอให้ init เสร็จ
  return context.i18n(key, fallback: 'Login');
}
```

### Checklist สำหรับ Debug

- [ ] HybridI18nService.init() เรียกแล้วหรือไม่
- [ ] Console ไม่มี error จาก init หรือไม่
- [ ] Directus URL/Token ถูกต้องหรือไม่
- [ ] Collection name ใน Directus ตรงกับที่ตั้งหรือไม่
- [ ] Key ใน Directus มีอยู่จริงหรือไม่
- [ ] Translations ใน Directus มี message หรือไม่
- [ ] Context ไม่เป็น null หรือไม่
- [ ] Extension ทำงานถูกต้องหรือไม่