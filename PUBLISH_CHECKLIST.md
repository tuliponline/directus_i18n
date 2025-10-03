# 📋 Quick Publish Checklist

## Before Publishing (ก่อน Publish)

### ✅ Step 1: เตรียม Package

- [ ] **แก้ไข `pubspec.yaml`:**
  ```yaml
  # ลบหรือ comment บรรทัดนี้:
  # publish_to: none
  
  # เพิ่มข้อมูลเหล่านี้:
  homepage: https://github.com/your-username/directus_i18n
  repository: https://github.com/your-username/directus_i18n
  issue_tracker: https://github.com/your-username/directus_i18n/issues
  ```

- [ ] **ตรวจสอบไฟล์:**
  - ✅ `README.md` - มีข้อมูลครบถ้วน
  - ✅ `CHANGELOG.md` - บันทึกการเปลี่ยนแปลง
  - ✅ `LICENSE` - MIT License
  - ✅ `example/` - Example code ใช้งานได้

### ✅ Step 2: ทดสอบ

```bash
cd packages/directus_i18n

# 1. Run tests
flutter test

# 2. Check linter
flutter analyze

# 3. Dry run (ทดสอบก่อน publish)
flutter pub publish --dry-run
```

**ต้องผ่านทุกขั้นตอน!**

### ✅ Step 3: Publish

```bash
# 1. Login pub.dev (ครั้งแรกอย่างเดียว)
dart pub token add https://pub.dev

# 2. Publish package
flutter pub publish

# 3. พิมพ์ 'y' เพื่อยืนยัน
```

### ✅ Step 4: After Publishing

```bash
# 1. Tag version
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 2. Create GitHub Release
# ไปที่ GitHub → Releases → Create new release
```

## Publishing Update (Publish version ใหม่)

### เมื่อต้องการ publish version ใหม่:

1. **อัปเดต version ใน `pubspec.yaml`:**
   ```yaml
   version: 1.0.1  # เพิ่มจาก 1.0.0
   ```

2. **อัปเดต `CHANGELOG.md`:**
   ```markdown
   ## [1.0.1] - 2025-10-02
   
   ### Fixed
   - Bug fixes
   
   ### Added
   - New features
   ```

3. **Commit & Push:**
   ```bash
   git add .
   git commit -m "chore: bump version to 1.0.1"
   git push
   ```

4. **Publish:**
   ```bash
   flutter pub publish --dry-run
   flutter pub publish
   ```

5. **Tag:**
   ```bash
   git tag -a v1.0.1 -m "Release v1.0.1"
   git push origin v1.0.1
   ```

## Version Guidelines

- `1.0.0` → `1.0.1` = Bug fixes (patch)
- `1.0.0` → `1.1.0` = New features (minor)
- `1.0.0` → `2.0.0` = Breaking changes (major)

## Quick Commands

```bash
# Full check
flutter test && flutter analyze && flutter pub publish --dry-run

# Publish
flutter pub publish

# Tag & push
git tag -a v1.0.0 -m "v1.0.0" && git push origin v1.0.0
```

## 🎯 Final Checklist

```
- [ ] Tests passing (flutter test)
- [ ] No linter errors (flutter analyze)
- [ ] Dry run passing (flutter pub publish --dry-run)
- [ ] README.md complete
- [ ] CHANGELOG.md updated
- [ ] LICENSE file exists
- [ ] pubspec.yaml has homepage/repository
- [ ] publish_to: none removed
- [ ] Version number correct
- [ ] Example works
```

## 📚 Full Guide

ดูคู่มือฉบับเต็มได้ที่: [PUBLISHING.md](PUBLISHING.md)

---

**Ready? Let's publish! 🚀**

```bash
flutter pub publish
```

