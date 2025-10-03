# Directus Structure Guide สำหรับ Directus I18n

## โครงสร้าง Directus ที่รองรับ

แพ็กเกจ Directus I18n ได้รับการปรับปรุงให้รองรับโครงสร้าง Directus ที่มี:

### 1. Language Collection
```
language
├── code (String) - รหัสภาษา เช่น "th-TH", "en-US"
└── name (String) - ชื่อภาษา เช่น "Thai", "English"
```

### 2. Error Collection
```
error
├── code (String) - รหัส error เช่น "INVALID_EMAIL"
└── translations (One-to-Many) - เชื่อมต่อกับ error_translations
```

### 3. Error Translations Collection
```
error_translations
├── id (Auto Increment)
├── error_code (Many-to-One) - เชื่อมต่อกับ error.code
├── language_code (Many-to-One) - เชื่อมต่อกับ language.code
└── message (Text) - ข้อความ error ที่แปลแล้ว
```

## การตั้งค่าใน Directus

### ขั้นตอนที่ 1: สร้าง Language Collection
1. ไปที่ **Settings** → **Data Model** → **Create Collection**
2. ชื่อ: `language`
3. เพิ่ม fields:
   - `code`: String (Primary Key)
   - `name`: String

### ขั้นตอนที่ 2: สร้าง Error Translations Collection
1. สร้าง collection ใหม่ชื่อ `error_translations`
2. เพิ่ม fields:
   - `id`: Auto Increment (Primary Key)
   - `error_code`: String (Foreign Key)
   - `language_code`: String (Foreign Key)
   - `message`: Text

### ขั้นตอนที่ 3: สร้าง Error Collection
1. สร้าง collection ใหม่ชื่อ `error`
2. เพิ่ม fields:
   - `code`: String (Primary Key)
   - `translations`: One-to-Many relation ไปยัง `error_translations`

### ขั้นตอนที่ 4: ตั้งค่า Relations
1. ใน `error_translations`:
   - `error_code` → `error.code` (Many-to-One)
   - `language_code` → `language.code` (Many-to-One)

## ตัวอย่างข้อมูล

### Language Data
```json
[
  {
    "code": "th-TH",
    "name": "Thai"
  },
  {
    "code": "en-US", 
    "name": "English"
  }
]
```

### Error Data
```json
[
  {
    "code": "INVALID_EMAIL",
    "translations": [
      {
        "error_code": "INVALID_EMAIL",
        "language_code": "th-TH",
        "message": "กรุณาใส่อีเมลที่ถูกต้อง"
      },
      {
        "error_code": "INVALID_EMAIL", 
        "language_code": "en-US",
        "message": "Please enter a valid email address"
      }
    ]
  }
]
```

## การใช้งานในโค้ด

### เริ่มต้น Service
```dart
await ErrorCodeService.init(
  baseUrl: 'https://your-directus-url.com',
  accessToken: 'your-access-token',
  collectionName: 'error', // ใช้ collection 'error'
);
```

### ใช้งาน Error Messages
```dart
// ใช้ภาษาไทย
final thaiMessage = 'INVALID_EMAIL'.getErrorMessage(languageCode: 'th-TH');

// ใช้ภาษาอังกฤษ  
final englishMessage = 'INVALID_EMAIL'.getErrorMessage(languageCode: 'en-US');

// ใช้กับ parameters
final messageWithParams = 'USER_NOT_FOUND'.getErrorMessage(
  languageCode: 'th-TH',
  parameters: {'username': 'john_doe'},
);
```

### โหลดข้อมูลภาษา
```dart
// โหลดภาษาที่มีในระบบ
final availableLanguages = await ErrorCodeService.loadAvailableLanguages();
print('Available languages: $availableLanguages');
// Output: Available languages: {th-TH, en-US}
```

## API Endpoints ที่ใช้

### 1. โหลด Error Codes
```
GET /items/error?fields=code,translations.id,translations.error_code,translations.language_code,translations.message&deep[translations][_filter][message][_nnull]=true&limit=-1
```

### 2. โหลด Languages
```
GET /items/language?fields=code&limit=-1
```

## ข้อดีของโครงสร้างใหม่

1. **แยกข้อมูลภาษา**: ข้อมูลภาษาอยู่ใน collection แยกต่างหาก
2. **ความยืดหยุ่น**: สามารถเพิ่มภาษาใหม่ได้ง่าย
3. **การจัดการที่ดีขึ้น**: สามารถจัดการข้อมูลภาษาและ error แยกกัน
4. **Performance**: โหลดเฉพาะข้อมูลที่จำเป็น

## Migration จากโครงสร้างเก่า

หากคุณมีโครงสร้างเก่าที่ใช้ `error_codes` collection:

1. สร้าง collections ใหม่ตามโครงสร้างข้างต้น
2. Migrate ข้อมูลจากโครงสร้างเก่า
3. อัปเดตโค้ดให้ใช้ `collectionName: 'error'`
4. ทดสอบการทำงาน

## การ Debug

หากมีปัญหาในการโหลดข้อมูล:

1. ตรวจสอบ API endpoints ใน Directus
2. ตรวจสอบ permissions ของ collections
3. ตรวจสอบ relations ระหว่าง collections
4. ดู logs ใน console เพื่อดู error messages
