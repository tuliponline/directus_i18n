# Integration Test Guide

## การทดสอบการเรียกข้อมูลจริงจาก Directus

### 1. การตั้งค่า Environment Variables

สร้างไฟล์ `.env` ในโฟลเดอร์ root ของโปรเจค:

```env
# Directus Configuration
DIRECTUS_BASE_URL=https://your-directus-instance.com
DIRECTUS_ACCESS_TOKEN=your-actual-access-token

# Collection Names
DIRECTUS_COLLECTION_NAME=error
I18N_ENUM_NAME=AppI18nKeys
```

### 2. การรัน Integration Test

```bash
# รัน integration test
flutter test test/integration_test.dart

# หรือรัน test ทั้งหมด
flutter test
```

### 3. Test Cases ที่จะรัน

#### ✅ **Test 1: Initialize ErrorCodeService**
- ทดสอบการเชื่อมต่อกับ Directus
- ตรวจสอบการ initialize service
- แสดงข้อมูลการเชื่อมต่อ

#### ✅ **Test 2: Load Error Codes**
- โหลดข้อมูล error codes จาก Directus
- แสดงจำนวน error codes ที่โหลดได้
- แสดงตัวอย่าง error codes แรก 5 ตัว

#### ✅ **Test 3: Find COM10003**
- ค้นหา error code COM10003
- แสดงรายละเอียดของ COM10003
- ทดสอบ translations ในภาษาไทยและอังกฤษ

#### ✅ **Test 4: Search Error Codes**
- ค้นหา error codes ที่ขึ้นต้นด้วย "COM"
- ค้นหา error codes ที่มี "LOGIN"
- แสดงผลการค้นหา

#### ✅ **Test 5: Extension Methods**
- ทดสอบ extension methods กับข้อมูลจริง
- ทดสอบการแสดงข้อความในภาษาไทย
- ตรวจสอบ error title และ description

#### ✅ **Test 6: Data Structure Verification**
- ตรวจสอบโครงสร้างข้อมูลจาก Directus
- ตรวจสอบ translations
- ตรวจสอบ language codes

### 4. ตัวอย่างผลลัพธ์ที่คาดหวัง

```
✅ ErrorCodeService initialized successfully
Base URL: https://your-directus-instance.com
Collection: error

✅ Loaded 15 error codes from Directus
Error Code 1: COM10003
  Severity: error
  Category: communication
  Available Languages: en-US, th-TH
  Sample Translation (EN): Communication error occurred
  Sample Translation (TH): เกิดข้อผิดพลาดในการสื่อสาร

✅ Found COM10003 in Directus
Code: COM10003
Severity: error
Category: communication
Title: Communication Error
Description: A communication error has occurred
Available Languages: en-US, th-TH
English Message: Communication error occurred
Thai Message: เกิดข้อผิดพลาดในการสื่อสาร
```

### 5. การแก้ไขปัญหา

#### ❌ **Error: DIRECTUS_BASE_URL not found**
- ตรวจสอบไฟล์ `.env` ว่ามีอยู่
- ตรวจสอบชื่อตัวแปรว่าเขียนถูกต้อง

#### ❌ **Error: DIRECTUS_ACCESS_TOKEN not found**
- ตรวจสอบ access token ในไฟล์ `.env`
- ตรวจสอบว่า token ยังไม่หมดอายุ

#### ❌ **Error: Connection failed**
- ตรวจสอบ URL ของ Directus
- ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
- ตรวจสอบ firewall หรือ proxy

#### ❌ **Error: No error codes found**
- ตรวจสอบ collection name ใน `.env`
- ตรวจสอบว่า collection `error` มีข้อมูล
- ตรวจสอบ permissions ของ access token

### 6. การใช้งานจริง

หลังจากรัน integration test สำเร็จแล้ว คุณสามารถใช้งานในแอปจริงได้:

```dart
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize with real Directus
  await ErrorCodeService.init(
    baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
    accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
    collectionName: 'error',
    autoLoad: true,
  );
  
  runApp(MyApp());
}

// ใช้งานในแอป
Text('COM10003'.getErrorMessage(languageCode: 'th-TH'));
```

### 7. หมายเหตุ

- Integration test จะเรียกข้อมูลจริงจาก Directus
- ต้องมี access token ที่ถูกต้อง
- ต้องมีข้อมูลใน collection `error`
- Test อาจใช้เวลานานขึ้นเนื่องจากต้องเชื่อมต่อ network
