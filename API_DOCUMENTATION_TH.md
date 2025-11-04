# เอกสาร API ฉบับสมบูรณ์ - Directus I18n Package

## สารบัญ

1. [DirectusI18nService](#directusi18nservice)
2. [HybridI18nService](#hybridi18nservice)
3. [DynamicI18nService](#directusi18nservice)
4. [CombinedI18nService](#combinedi18nservice)
5. [ErrorCodeService](#errorcodeservice)
6. [AutoEnumService](#autoenumservice)
7. [RuntimeEnumGenerator](#runtimeenumgenerator)
8. [Extensions](#extensions)
9. [Widgets](#widgets)
10. [Models](#models)
11. [Configuration](#configuration)
12. [Repository](#repository)

---

## DirectusI18nService

Service หลักสำหรับจัดการการแปลภาษา (I18n) จาก Directus CMS

### Methods

#### `init()`

เริ่มต้นการใช้งาน DirectusI18nService

**Parameters:**
- `baseUrl` (required, String): URL ฐานของ Directus instance
- `accessToken` (required, String): Access token สำหรับเรียกใช้ Directus API
- `collectionName` (optional, String, default: 'app_contents'): ชื่อ collection ใน Directus ที่เก็บ translations
- `isProduction` (optional, bool, default: true): ระบุว่าแอปอยู่ในโหมด production หรือไม่
- `cacheEnabled` (optional, bool, default: true): เปิด/ปิดการใช้งาน cache
- `onError` (optional, Function): Callback สำหรับจัดการ error
- `httpClient` (optional, Dio): Custom Dio client (ถ้าไม่ระบุจะสร้างใหม่)
- `platformChannelGetter` (optional, Function): Function สำหรับดึงข้อมูลจาก platform channel
- `navigatorKey` (optional, GlobalKey<NavigatorState>): Global navigator key สำหรับเข้าถึง context

**Example:**
```dart
DirectusI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_contents',
  isProduction: true,
  cacheEnabled: true,
);
```

**Returns:** `void`

---

#### `config`

ดึงค่าการตั้งค่าปัจจุบัน

**Returns:** `DirectusI18nConfig`

**Throws:** `StateError` ถ้ายังไม่ได้ initialize

**Example:**
```dart
final config = DirectusI18nService.config;
print('Base URL: ${config.baseUrl}');
```

---

#### `updateConfig()`

อัพเดทการตั้งค่าหลังจาก initialize แล้ว

**Parameters:**
- `newConfig` (required, DirectusI18nConfig): การตั้งค่าใหม่

**Example:**
```dart
DirectusI18nService.updateConfig(
  DirectusI18nConfig(
    baseUrl: 'https://new-directus.com',
    accessToken: 'new-token',
  ),
);
```

**Returns:** `void`

---

#### `reset()`

รีเซ็ต service (มีประโยชน์สำหรับ testing)

**Returns:** `void`

**Example:**
```dart
DirectusI18nService.reset();
```

---

## HybridI18nService

Service ที่รวม enum generation กับ dynamic loading เข้าด้วยกัน เพื่อให้ได้ทั้ง type safety และความยืดหยุ่นที่ runtime

### Methods

#### `init()`

เริ่มต้นการใช้งาน HybridI18nService

**Parameters:**
- `baseUrl` (required, String): URL ฐานของ Directus instance
- `accessToken` (required, String): Access token สำหรับเรียกใช้ Directus API
- `collectionName` (optional, String, default: 'contents'): ชื่อ collection ใน Directus
- `enumName` (optional, String, default: 'HybridI18nKeys'): ชื่อ enum ที่จะ generate
- `autoGenerateEnum` (optional, bool, default: true): เปิด/ปิดการ generate enum อัตโนมัติ
- `enableDynamicFallback` (optional, bool, default: true): เปิด/ปิด dynamic fallback

**Returns:** `Future<void>`

**Example:**
```dart
await HybridI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'contents',
  enumName: 'MyAppI18nKeys',
  autoGenerateEnum: true,
  enableDynamicFallback: true,
);
```

---

#### `translate()`

แปลข้อความโดยใช้ hybrid approach (enum ก่อน แล้วค่อย dynamic)

**Parameters:**
- `key` (required, String): คีย์สำหรับแปลข้อความ
- `fallback` (optional, String): ข้อความสำรองถ้าไม่พบการแปล
- `params` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่ในข้อความ (เช่น `{'name': 'John'}`)
- `context` (optional, BuildContext): BuildContext สำหรับดึง locale

**Returns:** `String`

**Example:**
```dart
// แปลง่ายๆ
Text(HybridI18nService.translate('welcome'))

// แปลพร้อมพารามิเตอร์
Text(HybridI18nService.translate(
  'welcome_user',
  params: {'name': 'John'},
))

// แปลพร้อม fallback
Text(HybridI18nService.translate(
  'missing_key',
  fallback: 'Default text',
))
```

---

#### `hasKey()`

ตรวจสอบว่ามี key นี้อยู่ใน enum หรือ dynamic cache หรือไม่

**Parameters:**
- `key` (required, String): คีย์ที่ต้องการตรวจสอบ

**Returns:** `bool`

**Example:**
```dart
if (HybridI18nService.hasKey('welcome')) {
  print('Key exists!');
}
```

---

#### `getAllKeys()`

ดึงรายการ key ทั้งหมดที่มี

**Returns:** `List<String>`

**Example:**
```dart
final keys = HybridI18nService.getAllKeys();
print('Total keys: ${keys.length}');
```

---

#### `getDynamicKeys()`

ดึงรายการ dynamic keys (alias ของ getAllKeys)

**Returns:** `List<String>`

---

#### `getAvailableLanguages()`

ดึงรายการภาษาที่รองรับ

**Returns:** `List<String>`

**Example:**
```dart
final languages = HybridI18nService.getAvailableLanguages();
print('Available languages: $languages');
```

---

#### `refresh()`

รีเฟรชทั้ง enum และ dynamic keys จาก Directus

**Returns:** `Future<void>`

**Example:**
```dart
await HybridI18nService.refresh();
```

---

#### `getStatus()`

ดึงสถานะของ service

**Returns:** `Map<String, dynamic>`

**Example:**
```dart
final status = HybridI18nService.getStatus();
print('Initialized: ${status['initialized']}');
print('Dynamic keys: ${status['dynamicKeysCount']}');
```

---

## DynamicI18nService

Service สำหรับโหลด keys จาก Directus โดยไม่ต้อง generate enum

### Methods

#### `init()`

เริ่มต้นการใช้งาน DynamicI18nService

**Parameters:**
- `baseUrl` (required, String): URL ฐานของ Directus instance
- `accessToken` (required, String): Access token สำหรับเรียกใช้ Directus API
- `collectionName` (optional, String, default: 'contents'): ชื่อ collection ใน Directus
- `cacheEnabled` (optional, bool, default: true): เปิด/ปิดการใช้งาน cache

**Returns:** `Future<void>`

**Example:**
```dart
await DynamicI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'contents',
  cacheEnabled: true,
);
```

---

#### `translate()`

แปลข้อความสำหรับ key ที่ระบุ

**Parameters:**
- `key` (required, String): คีย์สำหรับแปลข้อความ
- `fallback` (optional, String): ข้อความสำรองถ้าไม่พบการแปล
- `params` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่ในข้อความ
- `context` (optional, BuildContext): BuildContext สำหรับดึง locale

**Returns:** `String`

**Example:**
```dart
Text(DynamicI18nService.translate('welcome'))
Text(DynamicI18nService.translate(
  'welcome_user',
  params: {'name': 'John'},
))
```

---

#### `hasKey()`

ตรวจสอบว่ามี key นี้หรือไม่

**Parameters:**
- `key` (required, String): คีย์ที่ต้องการตรวจสอบ

**Returns:** `bool`

---

#### `getAllKeys()`

ดึงรายการ key ทั้งหมดที่มี

**Returns:** `List<String>`

---

#### `getFallback()`

ดึงข้อความ fallback สำหรับ key ที่ระบุ

**Parameters:**
- `key` (required, String): คีย์ที่ต้องการดึง fallback

**Returns:** `String?`

**Example:**
```dart
final fallback = DynamicI18nService.getFallback('welcome');
```

---

#### `refreshKeys()`

รีเฟรช keys จาก Directus (มีประโยชน์สำหรับ hot reload)

**Returns:** `Future<void>`

**Example:**
```dart
await DynamicI18nService.refreshKeys();
```

---

#### `clearCache()`

ล้าง cache (มีประโยชน์สำหรับ testing)

**Returns:** `void`

**Example:**
```dart
DynamicI18nService.clearCache();
```

---

## CombinedI18nService

Service สำหรับจัดการทั้ง I18n content และ Error codes ในที่เดียว

### Methods

#### `init()`

เริ่มต้นทั้ง I18n และ Error Code services

**Parameters:**
- `baseUrl` (required, String): URL ฐานของ Directus instance
- `accessToken` (required, String): Access token สำหรับเรียกใช้ Directus API
- `i18nCollectionName` (optional, String, default: 'contents'): ชื่อ collection สำหรับ I18n
- `errorCollectionName` (optional, String, default: 'error_codes'): ชื่อ collection สำหรับ error codes
- `i18nEnumName` (optional, String, default: 'AppI18nKeys'): ชื่อ enum สำหรับ I18n
- `autoGenerateEnum` (optional, bool, default: true): เปิด/ปิดการ generate enum อัตโนมัติ
- `enableDynamicFallback` (optional, bool, default: true): เปิด/ปิด dynamic fallback
- `autoLoadErrorCodes` (optional, bool, default: true): เปิด/ปิดการโหลด error codes อัตโนมัติ

**Returns:** `Future<void>`

**Example:**
```dart
await CombinedI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  i18nCollectionName: 'contents',
  errorCollectionName: 'error',
  autoGenerateEnum: true,
);
```

---

#### `refresh()`

รีเฟรชทั้งสอง services

**Returns:** `Future<void>`

**Example:**
```dart
await CombinedI18nService.refresh();
```

---

#### `getStatus()`

ดึงสถานะรวมของทั้งสอง services

**Returns:** `Map<String, dynamic>`

**Example:**
```dart
final status = CombinedI18nService.getStatus();
print('I18n keys: ${status['i18n']['dynamicKeysCount']}');
print('Error codes: ${status['errorCodes']['errorCodesCount']}');
```

---

#### `translate()`

แปลข้อความ I18n

**Parameters:**
- `key` (required, String): คีย์สำหรับแปลข้อความ
- `params` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่ในข้อความ

**Returns:** `String`

**Example:**
```dart
Text(CombinedI18nService.translate('welcome'))
```

---

#### `getErrorMessage()`

ดึงข้อความ error ที่แปลแล้ว

**Parameters:**
- `errorCode` (required, String): รหัส error
- `languageCode` (optional, String): รหัสภาษา
- `parameters` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่ในข้อความ
- `fallback` (optional, String): ข้อความสำรอง

**Returns:** `String`

**Example:**
```dart
Text(CombinedI18nService.getErrorMessage(
  'E001',
  languageCode: 'th-TH',
))
```

---

#### `getErrorCode()`

ดึง error code object

**Parameters:**
- `code` (required, String): รหัส error

**Returns:** `ErrorCode?`

**Example:**
```dart
final errorCode = CombinedI18nService.getErrorCode('E001');
if (errorCode != null) {
  print('Error: ${errorCode.message}');
}
```

---

#### `isInitialized`

ตรวจสอบว่า service ถูก initialize แล้วหรือไม่

**Returns:** `bool`

---

#### `getI18nKeys()`

ดึงรายการ I18n keys ทั้งหมด

**Returns:** `List<String>`

---

#### `getErrorCodes()`

ดึงรายการ error codes ทั้งหมด

**Returns:** `List<String>`

---

#### `getI18nLanguages()`

ดึงรายการภาษาที่รองรับสำหรับ I18n

**Returns:** `List<String>`

---

#### `getErrorCodeLanguages()`

ดึงรายการภาษาที่รองรับสำหรับ error codes

**Returns:** `List<String>`

---

#### `loadAvailableLanguages()`

โหลดรายการภาษาที่มีจาก Directus

**Returns:** `Future<List<String>>`

---

#### `getAllLanguages()`

ดึงรายการภาษาทั้งหมด (รวมทั้ง I18n และ error codes)

**Returns:** `List<String>`

---

#### `hasI18nKey()`

ตรวจสอบว่ามี I18n key นี้หรือไม่

**Parameters:**
- `key` (required, String): คีย์ที่ต้องการตรวจสอบ

**Returns:** `bool`

---

#### `hasErrorCode()`

ตรวจสอบว่ามี error code นี้หรือไม่

**Parameters:**
- `code` (required, String): รหัส error ที่ต้องการตรวจสอบ

**Returns:** `bool`

---

#### `getTranslationWithFallback()`

ดึงการแปลพร้อม fallback

**Parameters:**
- `key` (required, String): คีย์สำหรับแปลข้อความ
- `fallback` (optional, String): ข้อความสำรอง

**Returns:** `String`

---

#### `getErrorMessageWithFallback()`

ดึงข้อความ error พร้อม fallback

**Parameters:**
- `errorCode` (required, String): รหัส error
- `fallback` (optional, String): ข้อความสำรอง

**Returns:** `String`

---

#### `getCombinedData()`

ดึงข้อมูลทั้ง I18n และ error สำหรับ key ที่ระบุ

**Parameters:**
- `key` (required, String): คีย์ที่ต้องการดึงข้อมูล

**Returns:** `Map<String, dynamic>`

**Example:**
```dart
final data = CombinedI18nService.getCombinedData('welcome');
print('Has I18n: ${data['hasI18n']}');
print('Has Error: ${data['hasError']}');
```

---

#### `searchKeys()`

ค้นหา keys ที่มีคำที่ระบุ

**Parameters:**
- `term` (required, String): คำที่ต้องการค้นหา

**Returns:** `List<String>`

**Example:**
```dart
final results = CombinedI18nService.searchKeys('welcome');
```

---

#### `getStatistics()`

ดึงสถิติของ service

**Returns:** `Map<String, dynamic>`

**Example:**
```dart
final stats = CombinedI18nService.getStatistics();
print('Total keys: ${stats['totalKeys']}');
print('Languages: ${stats['languages']}');
```

---

## ErrorCodeService

Service สำหรับจัดการ error codes จาก Directus

### Methods

#### `init()`

เริ่มต้นการใช้งาน ErrorCodeService

**Parameters:**
- `baseUrl` (required, String): URL ฐานของ Directus instance
- `accessToken` (required, String): Access token สำหรับเรียกใช้ Directus API
- `collectionName` (optional, String, default: 'error'): ชื่อ collection สำหรับ error codes
- `autoLoad` (optional, bool, default: true): เปิด/ปิดการโหลด error codes อัตโนมัติ

**Returns:** `Future<void>`

**Example:**
```dart
await ErrorCodeService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'error',
  autoLoad: true,
);
```

---

#### `loadErrorCodes()`

โหลด error codes จาก Directus

**Returns:** `Future<void>`

**Example:**
```dart
await ErrorCodeService.loadErrorCodes();
```

---

#### `getErrorCode()`

ดึง error code object จากรหัส

**Parameters:**
- `code` (required, String): รหัส error

**Returns:** `ErrorCode?`

**Example:**
```dart
final errorCode = ErrorCodeService.getErrorCode('E001');
```

---

#### `getAllErrorCodes()`

ดึงรายการ error codes ทั้งหมด

**Returns:** `List<ErrorCode>`

---

#### `getLocalizedMessage()`

ดึงข้อความ error ที่แปลแล้วตามภาษา

**Parameters:**
- `code` (required, String): รหัส error
- `languageCode` (optional, String): รหัสภาษา
- `parameters` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่ในข้อความ
- `fallback` (optional, String): ข้อความสำรอง

**Returns:** `String`

**Example:**
```dart
final message = ErrorCodeService.getLocalizedMessage(
  'E001',
  languageCode: 'th-TH',
  parameters: {'field': 'email'},
);
```

---

#### `hasErrorCode()`

ตรวจสอบว่ามี error code นี้หรือไม่

**Parameters:**
- `code` (required, String): รหัส error ที่ต้องการตรวจสอบ

**Returns:** `bool`

---

#### `getErrorCodesCount()`

ดึงจำนวน error codes ทั้งหมด

**Returns:** `int`

---

#### `refresh()`

รีเฟรช error codes จาก Directus

**Returns:** `Future<void>`

---

#### `clearCache()`

ล้าง cache

**Returns:** `void`

---

#### `getStatus()`

ดึงสถานะของ service

**Returns:** `Map<String, dynamic>`

---

#### `searchErrorCodes()`

ค้นหา error codes ที่มีคำที่ระบุ

**Parameters:**
- `searchTerm` (required, String): คำที่ต้องการค้นหา

**Returns:** `List<ErrorCode>`

**Example:**
```dart
final results = ErrorCodeService.searchErrorCodes('invalid');
```

---

#### `getAllAvailableLanguages()`

ดึงรายการภาษาทั้งหมดที่มีใน error codes

**Returns:** `Set<String>`

---

#### `loadAvailableLanguages()`

โหลดรายการภาษาจาก Directus language collection

**Returns:** `Future<Set<String>>`

---

#### `getAvailableLanguages()`

ดึงรายการภาษาที่รองรับ (alias ของ getAllAvailableLanguages เป็น List)

**Returns:** `List<String>`

---

#### `getErrorCodesWithLanguage()`

ดึง error codes ที่มีการแปลสำหรับภาษาที่ระบุ

**Parameters:**
- `languageCode` (required, String): รหัสภาษา

**Returns:** `List<ErrorCode>`

---

## AutoEnumService

Service สำหรับ generate และจัดการ enum files อัตโนมัติ

### Methods

#### `init()`

เริ่มต้น auto enum service

**Parameters:**
- `baseUrl` (required, String): URL ฐานของ Directus instance
- `accessToken` (required, String): Access token สำหรับเรียกใช้ Directus API
- `collectionName` (optional, String, default: 'contents'): ชื่อ collection ใน Directus
- `enumName` (optional, String, default: 'AutoI18nKeys'): ชื่อ enum ที่จะ generate
- `autoGenerate` (optional, bool, default: true): เปิด/ปิดการ generate อัตโนมัติ
- `checkInterval` (optional, Duration): ช่วงเวลาที่จะตรวจสอบการอัพเดท

**Returns:** `Future<void>`

**Example:**
```dart
await AutoEnumService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  enumName: 'MyAppI18nKeys',
);
```

---

#### `generateEnumIfNeeded()`

Generate enum ถ้าจำเป็น (ตรวจสอบการอัพเดท)

**Parameters:**
- `baseUrl` (required, String): URL ฐานของ Directus instance
- `accessToken` (required, String): Access token สำหรับเรียกใช้ Directus API
- `collectionName` (optional, String, default: 'contents'): ชื่อ collection ใน Directus
- `enumName` (optional, String, default: 'AutoI18nKeys'): ชื่อ enum ที่จะ generate

**Returns:** `Future<void>`

---

#### `forceRegenerate()`

บังคับให้ regenerate enum

**Parameters:**
- `baseUrl` (required, String): URL ฐานของ Directus instance
- `accessToken` (required, String): Access token สำหรับเรียกใช้ Directus API
- `collectionName` (optional, String, default: 'contents'): ชื่อ collection ใน Directus
- `enumName` (optional, String, default: 'AutoI18nKeys'): ชื่อ enum ที่จะ generate

**Returns:** `Future<void>`

**Example:**
```dart
await AutoEnumService.forceRegenerate(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
);
```

---

#### `getGeneratedEnumPath()`

ดึง path ของไฟล์ enum ที่ generate แล้ว

**Returns:** `String`

---

#### `hasGeneratedEnum()`

ตรวจสอบว่ามี enum ที่ generate แล้วหรือไม่

**Returns:** `bool`

---

#### `getEnumInfo()`

ดึงข้อมูลเกี่ยวกับไฟล์ enum

**Returns:** `Map<String, dynamic>`

**Example:**
```dart
final info = AutoEnumService.getEnumInfo();
print('Path: ${info['path']}');
print('Exists: ${info['exists']}');
```

---

#### `cleanup()`

ลบไฟล์ที่ generate แล้ว

**Returns:** `Future<void>`

---

## RuntimeEnumGenerator

Generator สำหรับสร้าง enum code และเก็บไว้ใน codebase

### Methods

#### `generateAndStore()`

Generate enum ที่ runtime และเก็บไว้ใน codebase

**Parameters:**
- `baseUrl` (required, String): URL ฐานของ Directus instance
- `accessToken` (required, String): Access token สำหรับเรียกใช้ Directus API
- `collectionName` (optional, String, default: 'contents'): ชื่อ collection ใน Directus
- `enumName` (optional, String, default: 'RuntimeI18nKeys'): ชื่อ enum ที่จะ generate

**Returns:** `Future<void>`

**Example:**
```dart
await RuntimeEnumGenerator.generateAndStore(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  enumName: 'MyRuntimeI18nKeys',
);
```

---

#### `hasGeneratedEnum()`

ตรวจสอบว่ามี enum ที่ generate แล้วหรือไม่

**Returns:** `bool`

---

#### `getGeneratedEnumPath()`

ดึง path ของไฟล์ enum ที่ generate แล้ว

**Returns:** `String`

---

#### `deleteGeneratedEnum()`

ลบไฟล์ enum ที่ generate แล้ว

**Returns:** `Future<void>`

---

#### `getGeneratedEnumModificationTime()`

ดึงเวลาที่แก้ไขไฟล์ enum ล่าสุด

**Returns:** `DateTime?`

---

## Extensions

### DynamicI18nExtension

Extension สำหรับ String เพื่อให้ใช้งาน dynamic i18n ได้ง่าย

#### `tr()`

แปลข้อความ string นี้เป็น i18n key

**Parameters:**
- `fallback` (optional, String): ข้อความสำรอง
- `params` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่
- `context` (optional, BuildContext): BuildContext สำหรับดึง locale

**Returns:** `String`

**Example:**
```dart
Text('welcome'.tr())
Text('welcome_user'.tr(params: {'name': 'John'}))
Text('missing_key'.tr(fallback: 'Fallback text'))
```

---

#### `hasTranslation`

ตรวจสอบว่ามีการแปล key นี้หรือไม่

**Returns:** `bool`

**Example:**
```dart
if ('welcome'.hasTranslation) {
  print('Translation exists');
}
```

---

#### `fallbackText`

ดึงข้อความ fallback สำหรับ key นี้

**Returns:** `String?`

---

### DynamicI18nContextExtension

Extension สำหรับ BuildContext เพื่อให้ใช้งาน i18n ได้ง่ายขึ้น

#### `tr()`

แปล key ด้วย context นี้

**Parameters:**
- `key` (required, String): คีย์สำหรับแปลข้อความ
- `fallback` (optional, String): ข้อความสำรอง
- `params` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่

**Returns:** `String`

**Example:**
```dart
Text(context.tr('welcome'))
```

---

### ErrorCodeExtension

Extension สำหรับ String เพื่อให้ใช้งาน error code ได้ง่าย

#### `errorCode`

ดึง error code object จาก string นี้

**Returns:** `ErrorCode?`

**Example:**
```dart
final errorCode = 'E001'.errorCode;
```

---

#### `getErrorMessage()`

ดึงข้อความ error ที่แปลแล้ว

**Parameters:**
- `languageCode` (optional, String): รหัสภาษา
- `parameters` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่
- `fallback` (optional, String): ข้อความสำรอง

**Returns:** `String`

**Example:**
```dart
final message = 'E001'.getErrorMessage(languageCode: 'th-TH');
```

---

#### `getErrorTitle()`

ดึง title ของ error code

**Parameters:**
- `languageCode` (optional, String): รหัสภาษา

**Returns:** `String?`

---

#### `getErrorDescription()`

ดึง description ของ error code

**Parameters:**
- `languageCode` (optional, String): รหัสภาษา

**Returns:** `String?`

---

#### `isErrorCode`

ตรวจสอบว่า string นี้เป็น error code ที่ถูกต้องหรือไม่

**Returns:** `bool`

---

### ErrorCodeContextExtension

Extension สำหรับ BuildContext เพื่อให้ใช้งาน error code ได้ง่าย

#### `currentLanguageCode`

ดึงรหัสภาษาปัจจุบันจาก context

**Returns:** `String?`

---

#### `getErrorMessage()`

ดึงข้อความ error ที่แปลแล้วด้วยภาษาปัจจุบัน

**Parameters:**
- `errorCode` (required, String): รหัส error
- `parameters` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่
- `fallback` (optional, String): ข้อความสำรอง

**Returns:** `String`

---

#### `getErrorTitle()`

ดึง title ของ error code ด้วยภาษาปัจจุบัน

**Parameters:**
- `errorCode` (required, String): รหัส error

**Returns:** `String?`

---

#### `getErrorDescription()`

ดึง description ของ error code ด้วยภาษาปัจจุบัน

**Parameters:**
- `errorCode` (required, String): รหัส error

**Returns:** `String?`

---

### I18nKeyTranslation

Extension สำหรับ I18nKey เพื่อเพิ่มฟังก์ชันการแปล

#### `translate()`

แปล key นี้เป็นภาษาปัจจุบัน

**Parameters:**
- `context` (optional, BuildContext): BuildContext สำหรับดึง locale
- `fallbackKey` (optional, String): ข้อความสำรอง (override defaultFallbackKey)
- `translationParams` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่

**Returns:** `String`

**Example:**
```dart
Text(I18nKeys.welcome.translate(
  context: context,
  translationParams: {'name': userName},
))
```

---

#### `tr()`

แปลโดยไม่ต้องระบุ context (ต้องตั้งค่า global navigator key)

**Parameters:**
- `params` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่

**Returns:** `String`

---

### I18nKeyHelpers

Extension เพิ่มเติมสำหรับ I18nKey

#### `hasTranslation()`

ตรวจสอบว่า key นี้มีการแปลใน locale ปัจจุบันหรือไม่

**Parameters:**
- `context` (required, BuildContext): BuildContext สำหรับดึง locale

**Returns:** `bool`

---

#### `getRawTranslation()`

ดึงการแปลแบบดิบโดยไม่มีการแทนที่พารามิเตอร์

**Parameters:**
- `context` (required, BuildContext): BuildContext สำหรับดึง locale

**Returns:** `String?`

---

#### `plural()`

แปลพร้อมรองรับ plural

**Parameters:**
- `context` (required, BuildContext): BuildContext สำหรับดึง locale
- `count` (required, int): จำนวน
- `zero` (optional, String): ข้อความสำหรับ 0
- `one` (optional, String): ข้อความสำหรับ 1
- `other` (optional, String): ข้อความสำหรับอื่นๆ

**Returns:** `String`

---

## Widgets

### DynamicI18nText

Widget แสดงข้อความที่ใช้ dynamic i18n

**Properties:**
- `i18nKey` (required, String): คีย์สำหรับแปลข้อความ
- `fallback` (optional, String): ข้อความสำรอง
- `params` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่
- `style` (optional, TextStyle): สไตล์ข้อความ
- `textAlign` (optional, TextAlign): การจัดตำแหน่งข้อความ
- `maxLines` (optional, int): จำนวนบรรทัดสูงสุด
- `overflow` (optional, TextOverflow): การจัดการข้อความที่ล้น

**Example:**
```dart
DynamicI18nText('welcome')
DynamicI18nText(
  'welcome_user',
  params: {'name': 'John'},
  style: TextStyle(fontSize: 16),
)
```

---

### DynamicI18nButton

Widget ปุ่มที่ใช้ dynamic i18n

**Properties:**
- `i18nKey` (required, String): คีย์สำหรับแปลข้อความ
- `fallback` (optional, String): ข้อความสำรอง
- `params` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่
- `onPressed` (optional, VoidCallback): Callback เมื่อกดปุ่ม
- `style` (optional, ButtonStyle): สไตล์ปุ่ม
- `child` (optional, Widget): Widget child (ถ้าไม่ระบุจะใช้ DynamicI18nText)

**Example:**
```dart
DynamicI18nButton(
  'submit',
  onPressed: () => print('Submitted'),
)
```

---

### DynamicI18nWidget

Widget ที่อัพเดทอัตโนมัติเมื่อ i18n keys เปลี่ยน

**Properties:**
- `builder` (required, Function): Function ที่สร้าง widget
- `refreshTrigger` (optional, String): Key สำหรับ watch การเปลี่ยนแปลง

**Example:**
```dart
DynamicI18nWidget(
  builder: (context) => Text('welcome'.tr()),
)
```

---

### ErrorCodeWidget

Widget แสดง error code พร้อมข้อความที่แปลแล้ว

**Properties:**
- `errorCode` (required, String): รหัส error
- `parameters` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่
- `languageCode` (optional, String): รหัสภาษา
- `fallback` (optional, String): ข้อความสำรอง
- `textStyle` (optional, TextStyle): สไตล์ข้อความ
- `textAlign` (optional, TextAlign): การจัดตำแหน่งข้อความ
- `maxLines` (optional, int): จำนวนบรรทัดสูงสุด
- `overflow` (optional, TextOverflow): การจัดการข้อความที่ล้น
- `showCode` (optional, bool, default: false): แสดงรหัส error หรือไม่

**Example:**
```dart
ErrorCodeWidget(
  'E001',
  showCode: true,
  parameters: {'field': 'email'},
)
```

---

### ErrorMessageWidget

Widget แสดงข้อความ error

**Properties:**
- `errorCode` (required, String): รหัส error
- `parameters` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่
- `languageCode` (optional, String): รหัสภาษา
- `fallback` (optional, String): ข้อความสำรอง
- `textStyle` (optional, TextStyle): สไตล์ข้อความ
- `textAlign` (optional, TextAlign): การจัดตำแหน่งข้อความ
- `maxLines` (optional, int): จำนวนบรรทัดสูงสุด
- `overflow` (optional, TextOverflow): การจัดการข้อความที่ล้น

**Example:**
```dart
ErrorMessageWidget('E001')
```

---

### ErrorCardWidget

Widget แสดง error ในรูปแบบ Card

**Properties:**
- `errorCode` (required, String): รหัส error
- `parameters` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่
- `languageCode` (optional, String): รหัสภาษา
- `fallback` (optional, String): ข้อความสำรอง
- `showCode` (optional, bool, default: true): แสดงรหัส error หรือไม่

**Example:**
```dart
ErrorCardWidget(
  'E001',
  showCode: true,
)
```

---

### ErrorListWidget

Widget แสดงรายการ error codes

**Properties:**
- `errorCodes` (required, List<String>): รายการรหัส error
- `parameters` (optional, Map<String, Map<String, String>>): พารามิเตอร์สำหรับแต่ละ error code
- `languageCode` (optional, String): รหัสภาษา
- `showCode` (optional, bool, default: true): แสดงรหัส error หรือไม่
- `itemBuilder` (optional, Function): Function สำหรับสร้าง widget แต่ละรายการ

**Example:**
```dart
ErrorListWidget(
  ['E001', 'E002'],
  showCode: true,
)
```

---

## Models

### ErrorCode

Model สำหรับ error code

**Properties:**
- `code` (String): รหัส error
- `message` (String?): ข้อความ error
- `translations` (Map<String, String>?): การแปลหลายภาษา
- `severity` (ErrorSeverity?): ระดับความรุนแรง
- `category` (String?): หมวดหมู่
- `title` (String?): หัวข้อ
- `description` (String?): คำอธิบาย
- `actionText` (String?): ข้อความสำหรับ action

**Methods:**

#### `fromDirectus()`

สร้าง ErrorCode จากข้อมูล Directus

**Parameters:**
- `data` (Map<String, dynamic>): ข้อมูลจาก Directus

**Returns:** `ErrorCode`

---

#### `toMap()`

แปลงเป็น Map สำหรับ JSON serialization

**Returns:** `Map<String, dynamic>`

---

#### `getLocalizedMessage()`

ดึงข้อความที่แปลแล้วตามภาษา

**Parameters:**
- `languageCode` (optional, String): รหัสภาษา
- `parameters` (optional, Map<String, String>): พารามิเตอร์สำหรับแทนที่
- `fallback` (optional, String): ข้อความสำรอง

**Returns:** `String`

---

#### `getAvailableLanguages()`

ดึงรายการภาษาทั้งหมดที่มี

**Returns:** `List<String>`

---

#### `hasTranslationFor()`

ตรวจสอบว่ามีการแปลสำหรับภาษาที่ระบุหรือไม่

**Parameters:**
- `languageCode` (required, String): รหัสภาษา

**Returns:** `bool`

---

### ErrorSeverity

Enum สำหรับระดับความรุนแรงของ error

**Values:**
- `info`: ข้อมูล
- `warning`: คำเตือน
- `error`: ข้อผิดพลาด
- `critical`: วิกฤต

---

### I18nKey

Abstract class สำหรับ translation keys

**Properties:**
- `key` (String): คีย์ identifier (usually ID จาก Directus)
- `defaultFallbackKey` (String?): ข้อความ fallback เริ่มต้น

**Static Properties:**
- `isDisplayContentKey` (bool): แสดง key แทนข้อความที่แปล (สำหรับ debugging)

---

## Configuration

### DirectusI18nConfig

Class สำหรับการตั้งค่า DirectusI18n

**Properties:**
- `baseUrl` (String): URL ฐานของ Directus instance
- `accessToken` (String): Access token สำหรับเรียกใช้ Directus API
- `collectionName` (String, default: 'contents'): ชื่อ collection ใน Directus
- `isProduction` (bool, default: true): ระบุว่าแอปอยู่ในโหมด production หรือไม่
- `cacheEnabled` (bool, default: true): เปิด/ปิดการใช้งาน cache
- `onError` (Function?): Callback สำหรับจัดการ error
- `httpClient` (Dio?): Custom Dio client
- `platformChannelGetter` (Function?): Function สำหรับดึงข้อมูลจาก platform channel
- `navigatorKey` (GlobalKey<NavigatorState>?): Global navigator key

**Methods:**

#### `copyWith()`

สร้าง config ใหม่โดยคัดลอกค่าปัจจุบันและแก้ไขเฉพาะที่ระบุ

**Parameters:**
- `baseUrl` (optional, String)
- `accessToken` (optional, String)
- `collectionName` (optional, String)
- `isProduction` (optional, bool)
- `cacheEnabled` (optional, bool)
- `onError` (optional, Function)
- `httpClient` (optional, Dio)
- `platformChannelGetter` (optional, Function)
- `navigatorKey` (optional, GlobalKey<NavigatorState>)

**Returns:** `DirectusI18nConfig`

---

## Repository

### DirectusI18nRepository

Repository สำหรับโหลด translations จาก Directus CMS

**Properties:**
- `config` (DirectusI18nConfig): การตั้งค่า
- `lastUpdatedLocale` (Locale): Locale ล่าสุดที่อัพเดท

**Methods:**

#### `load()`

โหลด translations สำหรับ locale ที่ระบุ

**Parameters:**
- `locale` (required, Locale): Locale ที่ต้องการโหลด

**Returns:** `Future<Map<String, String>>`

**Example:**
```dart
final translations = await repository.load(Locale('th', 'TH'));
```

---

#### `loadWithDefaults()`

โหลด translations ด้วย default locale (en-US)

**Returns:** `Future<Map<String, String>>`

---

#### `getTermsConditions()`

ดึงเนื้อหา Terms and Conditions

**Returns:** `Future<String>`

---

#### `getCollectionContent()`

ดึงเนื้อหาจาก collection ที่ระบุ

**Parameters:**
- `collectionName` (required, String): ชื่อ collection
- `contentField` (optional, String, default: 'content'): ชื่อ field ที่เก็บเนื้อหา

**Returns:** `Future<List<String>>`

**Example:**
```dart
final contents = await repository.getCollectionContent(
  collectionName: 'articles',
  contentField: 'content',
);
```

---

## ตัวอย่างการใช้งาน

### 1. การเริ่มต้นใช้งานพื้นฐาน

```dart
import 'package:directus_i18n/directus_i18n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // เริ่มต้น HybridI18nService
  await HybridI18nService.init(
    baseUrl: 'https://your-directus.com',
    accessToken: 'your-token',
    collectionName: 'contents',
    enumName: 'MyAppI18nKeys',
    autoGenerateEnum: true,
  );
  
  runApp(MyApp());
}
```

### 2. การใช้งาน String Extension

```dart
// แปลง่ายๆ
Text('welcome'.tr())

// แปลพร้อมพารามิเตอร์
Text('welcome_user'.tr(params: {'name': 'John'}))

// แปลพร้อม fallback
Text('missing_key'.tr(fallback: 'Default text'))
```

### 3. การใช้งาน Service

```dart
// ใช้ HybridI18nService
Text(HybridI18nService.translate('welcome'))
Text(HybridI18nService.translate(
  'welcome_user',
  params: {'name': 'John'},
))

// ใช้ CombinedI18nService
Text(CombinedI18nService.translate('welcome'))
Text(CombinedI18nService.getErrorMessage('E001'))
```

### 4. การใช้งาน Error Code

```dart
// ใช้ Extension
Text('E001'.getErrorMessage(languageCode: 'th-TH'))

// ใช้ Service
final message = ErrorCodeService.getLocalizedMessage(
  'E001',
  languageCode: 'th-TH',
  parameters: {'field': 'email'},
);

// ใช้ Widget
ErrorCodeWidget('E001', showCode: true)
```

### 5. การใช้งาน Widgets

```dart
// DynamicI18nText
DynamicI18nText('welcome')
DynamicI18nText(
  'welcome_user',
  params: {'name': 'John'},
  style: TextStyle(fontSize: 16),
)

// DynamicI18nButton
DynamicI18nButton(
  'submit',
  onPressed: () => print('Submitted'),
)

// ErrorCodeWidget
ErrorCodeWidget(
  'E001',
  showCode: true,
  parameters: {'field': 'email'},
)
```

### 6. การใช้งาน Generated Enum

```dart
// หลังจาก generate enum แล้ว
Text(MyAppI18nKeys.welcome.translate(context: context))
Text(MyAppI18nKeys.welcomeUser.translate(
  context: context,
  translationParams: {'name': 'John'},
))
```

### 7. การ Refresh และ Update

```dart
// Refresh HybridI18nService
await HybridI18nService.refresh();

// Refresh CombinedI18nService
await CombinedI18nService.refresh();

// Refresh ErrorCodeService
await ErrorCodeService.refresh();

// Refresh DynamicI18nService
await DynamicI18nService.refreshKeys();
```

### 8. การตรวจสอบและค้นหา

```dart
// ตรวจสอบว่ามี key หรือไม่
if (HybridI18nService.hasKey('welcome')) {
  print('Key exists!');
}

// ดึงรายการ keys ทั้งหมด
final keys = HybridI18nService.getAllKeys();

// ค้นหา keys
final results = CombinedI18nService.searchKeys('welcome');

// ดึงสถานะ
final status = HybridI18nService.getStatus();
print('Status: $status');
```

---

## หมายเหตุสำคัญ

1. **ต้อง Initialize Service ก่อนใช้งาน**: ต้องเรียก `init()` ก่อนใช้งาน service ใดๆ
2. **Context สำหรับ Locale**: บางฟังก์ชันต้องการ BuildContext เพื่อดึง locale ปัจจุบัน
3. **Parameter Substitution**: ใช้รูปแบบ `{paramName}` ในข้อความ และส่ง params เป็น Map
4. **Fallback**: ควรกำหนด fallback text เสมอเพื่อป้องกันการแสดง key แทนข้อความ
5. **Error Handling**: ควรตั้งค่า `onError` callback สำหรับจัดการ error
6. **Cache**: Service จะ cache translations อัตโนมัติเพื่อเพิ่มประสิทธิภาพ
7. **Hot Reload**: ใช้ `refresh()` เมื่อต้องการอัพเดท translations โดยไม่ต้อง restart app

---

## สรุป

Package นี้ให้เครื่องมือครบครันสำหรับจัดการการแปลภาษาและ error codes จาก Directus CMS ใน Flutter project โดยมีทั้ง:

- **Type Safety**: ด้วย enum generation
- **Runtime Flexibility**: ด้วย dynamic loading
- **Easy to Use**: ด้วย extensions และ widgets
- **Error Management**: ด้วย error code service
- **Combined Service**: สำหรับจัดการทั้งสองอย่างในที่เดียว

เลือกใช้ตามความต้องการของโปรเจกต์ของคุณ!

