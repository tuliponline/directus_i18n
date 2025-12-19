# Real Directus Integration Test

ไฟล์ `real_directus_test.dart` เป็นการทดสอบที่ดึงข้อมูลจริงจาก Directus CMS

## การรัน Test

เนื่องจาก Flutter test framework จะ block HTTP requests โดย default มี 2 วิธีในการรัน:

### วิธีที่ 1: ใช้ dart test (แนะนำ)

```bash
dart test test/real_directus_test.dart
```

หรือรัน test เฉพาะ:

```bash
dart test test/real_directus_test.dart --plain-name "should verify app_content collection structure"
```

### วิธีที่ 2: ใช้ curl เพื่อทดสอบ API โดยตรง

```bash
# ทดสอบดึงข้อมูล app_content
curl "https://cms.monster-fishing.com/items/app_content?access_token=G-F4cQMXX-OZjvdWX5XZ9Z-GZri1ZhE4&fields=id,key,translations.*&limit=1" | python3 -m json.tool

# ทดสอบดึงข้อมูล app_page
curl "https://cms.monster-fishing.com/items/app_page?access_token=G-F4cQMXX-OZjvdWX5XZ9Z-GZri1ZhE4&fields=id,key,status&filter[status][_eq]=published" | python3 -m json.tool
```

## โครงสร้างข้อมูลจาก Directus

จากผลการทดสอบ พบว่าโครงสร้างจริงของ Directus API คือ:

### app_content Collection

```json
{
  "data": [
    {
      "id": 1,
      "key": "TITLE",
      "status": "published",
      "translations": [
        {
          "id": 1,
          "app_content_id": 1,
          "languages_code": "en-US",
          "value": "LoginNew"
        },
        {
          "id": 2,
          "app_content_id": 1,
          "languages_code": "th-TH",
          "value": "เข้าสู่ระบบใหม่"
        }
      ]
    }
  ]
}
```

**สำคัญ:** `translations` เป็น **array** ของ objects ไม่ใช่ Map ที่มี key เป็น `value(en-US)`

แต่ละ translation object มี:
- `id`: ID ของ translation record
- `app_content_id`: Foreign key ไปยัง app_content
- `languages_code`: รหัสภาษา (เช่น "en-US", "th-TH")
- `value`: ข้อความที่แปล

### app_page Collection

```json
{
  "data": [
    {
      "id": 1,
      "key": "login",
      "status": "published"
    }
  ]
}
```

## สิ่งที่ Test ตรวจสอบ

1. ✅ Service initialization
2. ✅ Loading translations from Directus
3. ✅ Translation of specific keys (TITLE)
4. ✅ Page prefix filtering
5. ✅ Widget integration
6. ✅ Directus API structure verification
7. ✅ Translation value extraction

## หมายเหตุ

- Test นี้ใช้ credentials จริงจาก Directus
- ต้องมี internet connection
- อาจจะช้าเพราะต้องรอ network requests
- ถ้า Directus API เปลี่ยนโครงสร้าง test อาจจะ fail
