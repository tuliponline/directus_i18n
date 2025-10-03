# Directus Setup Guide สำหรับ Error Codes

## โครงสร้าง Collections ใน Directus

ตามโครงสร้างที่คุณมีใน Directus:

### 1. Collection `language`
```
Fields:
- code (String, Primary Key) - เช่น 'th-TH', 'en-US'
- name (String) - ชื่อภาษา เช่น 'Thai', 'English'
```

### 2. Collection `error`
```
Fields:
- code (String, Primary Key) - เช่น 'LOGIN_FAILED', 'VALIDATION_ERROR'
- translations (Many-to-Many relationship กับ error_translations)
```

### 3. Collection `error_translations`
```
Fields:
- id (UUID, Primary Key)
- error_code (Many-to-One relationship กับ error.code)
- language_code (Many-to-One relationship กับ language.code)
- message (Text) - ข้อความ error แปลแล้ว
```

## การตั้งค่าใน Directus

### ขั้นตอนที่ 1: สร้าง Collection `language`
1. ไปที่ Settings > Data Model
2. สร้าง Collection ใหม่ชื่อ `language`
3. เพิ่ม Fields:
   - `code` (String, Primary Key)
   - `name` (String)
4. เพิ่มข้อมูลตัวอย่าง:
   ```
   code: th-TH, name: Thai
   code: en-US, name: English
   ```

### ขั้นตอนที่ 2: สร้าง Collection `error`
1. สร้าง Collection ใหม่ชื่อ `error`
2. เพิ่ม Fields:
   - `code` (String, Primary Key)
   - `translations` (Many-to-Many กับ error_translations)

### ขั้นตอนที่ 3: สร้าง Collection `error_translations`
1. สร้าง Collection ใหม่ชื่อ `error_translations`
2. เพิ่ม Fields:
   - `id` (UUID, Primary Key)
   - `error_code` (Many-to-One กับ error.code)
   - `language_code` (Many-to-One กับ language.code)
   - `message` (Text)

### ขั้นตอนที่ 4: ตั้งค่า Relationships
1. ใน Collection `error_translations`:
   - ตั้งค่า `error_code` เป็น Many-to-One กับ `error.code`
   - ตั้งค่า `language_code` เป็น Many-to-One กับ `language.code`

2. ใน Collection `error`:
   - ตั้งค่า `translations` เป็น Many-to-Many กับ `error_translations`

## ตัวอย่างข้อมูล

### ข้อมูลใน Collection `language`
```json
[
  {"code": "th-TH", "name": "Thai"},
  {"code": "en-US", "name": "English"}
]
```

### ข้อมูลใน Collection `error`
```json
[
  {"code": "LOGIN_FAILED"},
  {"code": "VALIDATION_ERROR"},
  {"code": "NETWORK_ERROR"},
  {"code": "EMAIL_REQUIRED"},
  {"code": "PASSWORD_TOO_SHORT"}
]
```

### ข้อมูลใน Collection `error_translations`
```json
[
  {
    "error_code": "LOGIN_FAILED",
    "language_code": "th-TH",
    "message": "การเข้าสู่ระบบล้มเหลว กรุณาตรวจสอบข้อมูลและลองใหม่"
  },
  {
    "error_code": "LOGIN_FAILED", 
    "language_code": "en-US",
    "message": "Login failed. Please check your credentials and try again."
  },
  {
    "error_code": "VALIDATION_ERROR",
    "language_code": "th-TH",
    "message": "ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบและลองใหม่"
  },
  {
    "error_code": "VALIDATION_ERROR",
    "language_code": "en-US", 
    "message": "Invalid data. Please check and try again."
  },
  {
    "error_code": "EMAIL_REQUIRED",
    "language_code": "th-TH",
    "message": "กรุณากรอกอีเมล"
  },
  {
    "error_code": "EMAIL_REQUIRED",
    "language_code": "en-US",
    "message": "Email is required"
  },
  {
    "error_code": "PASSWORD_TOO_SHORT",
    "language_code": "th-TH",
    "message": "รหัสผ่านต้องมีอย่างน้อย {minLength} ตัวอักษร"
  },
  {
    "error_code": "PASSWORD_TOO_SHORT",
    "language_code": "en-US",
    "message": "Password must be at least {minLength} characters"
  }
]
```

## การใช้งานใน Flutter

### 1. ติดตั้ง Package
```yaml
dependencies:
  directus_i18n:
    git:
      url: https://github.com/YOUR_USERNAME/directus_i18n.git
      ref: main
  flutter_dotenv: ^5.1.0
```

### 2. สร้างไฟล์ `.env`
```env
DIRECTUS_BASE_URL=https://your-directus-instance.com
DIRECTUS_ACCESS_TOKEN=your-access-token
```

### 3. Initialize ใน main.dart
```dart
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await ErrorCodeService.init(
    baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
    accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
    collectionName: 'error', // Collection name
    autoLoad: true,
  );
  
  runApp(MyApp());
}
```

### 4. ใช้งานในโค้ด
```dart
// ใช้ extension methods
Text('LOGIN_FAILED'.getErrorMessage());

// ใช้ parameters
Text('PASSWORD_TOO_SHORT'.getErrorMessage(
  parameters: {'minLength': '6'}
));

// ใช้ใน form validation
validator: (value) {
  if (value?.isEmpty ?? true) {
    return 'EMAIL_REQUIRED'.getErrorMessage();
  }
  return null;
}

// แสดง error dialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('LOGIN_FAILED'.getErrorTitle() ?? 'Error'),
    content: Text('LOGIN_FAILED'.getErrorDescription() ?? 'An error occurred'),
  ),
);
```

## การทดสอบ

รัน example app:
```bash
cd example
flutter run directus_error_example.dart
```

หรือดูตัวอย่างใน:
- `example/directus_error_example.dart` - ตัวอย่างครบถ้วน
- `example/error_code_example.dart` - ตัวอย่างพื้นฐาน

## ข้อดีของโครงสร้างนี้

1. **ความยืดหยุ่น**: เพิ่มภาษาใหม่ได้ง่าย
2. **การจัดการ**: จัดการ error codes และ translations แยกกัน
3. **ประสิทธิภาพ**: ใช้ relationships ของ Directus
4. **มาตรฐาน**: ใช้โครงสร้างมาตรฐานของ Directus
5. **การขยาย**: เพิ่มฟิลด์ใหม่ได้ง่าย (เช่น severity, category)
