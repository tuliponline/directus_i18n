# Publishing to pub.dev Guide

คู่มือการ publish package `directus_i18n` ขึ้น pub.dev แบบละเอียดทีละขั้นตอน

## 📋 Pre-requisites (สิ่งที่ต้องเตรียมก่อน)

### 1. Google Account
- ต้องมี Google Account สำหรับ login pub.dev
- แนะนำใช้ account ที่เป็นทางการของบริษัทหรือโปรเจค

### 2. Package ต้องพร้อม
- ✅ Tests ผ่านหมด
- ✅ ไม่มี linter errors
- ✅ Documentation ครบถ้วน
- ✅ LICENSE file
- ✅ README.md ที่ดี
- ✅ CHANGELOG.md

### 3. เครื่องมือ
```bash
# ต้องมี Flutter SDK
flutter --version

# ต้อง login pub.dev
dart pub token add https://pub.dev
```

## 🔧 Step 1: เตรียม Package

### 1.1 แก้ไข pubspec.yaml

**ก่อน publish ต้องแก้:**

```yaml
name: directus_i18n
description: A reusable Flutter package for internationalization using Directus CMS as the content source. Supports dynamic content loading, type-safe keys, and easy integration.
version: 1.0.0
publish_to: none  # ⚠️ เปลี่ยนบรรทัดนี้!

# เพิ่มข้อมูลเหล่านี้:
homepage: https://github.com/your-username/directus_i18n
repository: https://github.com/your-username/directus_i18n
issue_tracker: https://github.com/your-username/directus_i18n/issues
documentation: https://github.com/your-username/directus_i18n#readme

environment:
  sdk: '>=3.0.6 <4.0.0'

# ... rest of file
```

**เปลี่ยนเป็น:**

```yaml
name: directus_i18n
description: A reusable Flutter package for internationalization using Directus CMS as the content source. Supports dynamic content loading, type-safe keys, and easy integration.
version: 1.0.0
# publish_to: none  # ⬅️ ลบหรือ comment บรรทัดนี้ออก

homepage: https://github.com/your-username/directus_i18n
repository: https://github.com/your-username/directus_i18n
issue_tracker: https://github.com/your-username/directus_i18n/issues
documentation: https://github.com/your-username/directus_i18n#readme

environment:
  sdk: '>=3.0.6 <4.0.0'
```

### 1.2 ตรวจสอบ LICENSE

ต้องมีไฟล์ `LICENSE` (มีแล้ว ✅)

### 1.3 ตรวจสอบ README.md

ต้องมีข้อมูลเหล่านี้:
- ✅ Package description
- ✅ Installation instructions
- ✅ Quick start example
- ✅ API documentation
- ✅ Examples

### 1.4 ตรวจสอบ CHANGELOG.md

ต้องมีการบันทึกการเปลี่ยนแปลง (มีแล้ว ✅)

## 🧪 Step 2: ทดสอบ Package

### 2.1 Run Tests

```bash
cd packages/directus_i18n
flutter test
```

ต้องผ่านทุก test! ✅

### 2.2 Check Linter

```bash
flutter analyze
```

ต้องไม่มี errors หรือ warnings!

### 2.3 Dry Run (ทดสอบก่อน publish จริง)

```bash
flutter pub publish --dry-run
```

คำสั่งนี้จะ:
- ✅ ตรวจสอบ package structure
- ✅ ตรวจสอบ pubspec.yaml
- ✅ ตรวจสอบว่าพร้อม publish หรือไม่
- ✅ แสดงไฟล์ที่จะถูก upload

**ถ้าผ่าน dry-run แสดงว่าพร้อม publish!**

## 📤 Step 3: Publish to pub.dev

### 3.1 Login to pub.dev

```bash
dart pub token add https://pub.dev
```

Browser จะเปิดขึ้นให้ login ด้วย Google Account

### 3.2 Publish Package

```bash
flutter pub publish
```

**⚠️ คำเตือน:**
- การ publish ทำแล้ว**ถอนไม่ได้**!
- Version ที่ publish แล้วจะอยู่ตลอดไป
- ห้าม publish version เดิมซ้ำ
- ต้องเพิ่ม version ทุกครั้งที่ publish ใหม่

### 3.3 Confirm

Terminal จะถามยืนยัน:
```
Publishing directus_i18n 1.0.0 to https://pub.dev:
|── LICENSE
|── README.md
|── CHANGELOG.md
|── pubspec.yaml
|── lib/
    ... (และไฟล์อื่นๆ)

Do you want to publish directus_i18n 1.0.0 to pub.dev? (y/N):
```

พิมพ์ `y` แล้วกด Enter

### 3.4 รอ Verification

pub.dev จะตรวจสอบ package:
- ✅ Package structure
- ✅ Dependencies
- ✅ Documentation
- ✅ License

ถ้าผ่านทุกอย่าง จะได้ข้อความ:
```
✓ Package uploaded successfully!
✓ Package validation passed.

Your package is now available at:
https://pub.dev/packages/directus_i18n
```

## 🎉 Step 4: After Publishing

### 4.1 ตรวจสอบ pub.dev

ไปที่ https://pub.dev/packages/directus_i18n

ตรวจสอบ:
- ✅ Package information
- ✅ Documentation
- ✅ Score (pub points)
- ✅ Popularity
- ✅ Likes

### 4.2 เพิ่ม Badge ใน README

```markdown
[![pub package](https://img.shields.io/pub/v/directus_i18n.svg)](https://pub.dev/packages/directus_i18n)
[![popularity](https://img.shields.io/pub/popularity/directus_i18n?logo=dart)](https://pub.dev/packages/directus_i18n/score)
[![likes](https://img.shields.io/pub/likes/directus_i18n?logo=dart)](https://pub.dev/packages/directus_i18n/score)
[![pub points](https://img.shields.io/pub/points/directus_i18n?logo=dart)](https://pub.dev/packages/directus_i18n/score)
```

### 4.3 Tag Git Repository

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### 4.4 Create GitHub Release

1. ไปที่ GitHub repository
2. Releases → Create new release
3. Tag: `v1.0.0`
4. Title: `v1.0.0 - Initial Release`
5. Description: Copy จาก CHANGELOG.md

## 🔄 Publishing Updates (การ publish version ใหม่)

### เมื่อต้องการ publish version ใหม่:

#### 1. อัปเดต Version

แก้ `pubspec.yaml`:
```yaml
version: 1.0.1  # เปลี่ยนจาก 1.0.0
```

**Versioning Guidelines:**
- `1.0.0` → `1.0.1` - Bug fixes (patch)
- `1.0.0` → `1.1.0` - New features (minor)
- `1.0.0` → `2.0.0` - Breaking changes (major)

#### 2. อัปเดต CHANGELOG.md

```markdown
## [1.0.1] - 2025-10-02

### Fixed
- Fixed issue with null safety
- Improved error messages

### Changed
- Updated dependencies
```

#### 3. Commit Changes

```bash
git add .
git commit -m "chore: bump version to 1.0.1"
git push
```

#### 4. Publish

```bash
flutter pub publish --dry-run  # ทดสอบก่อน
flutter pub publish            # publish จริง
```

#### 5. Tag & Release

```bash
git tag -a v1.0.1 -m "Release version 1.0.1"
git push origin v1.0.1
```

## ⚠️ Common Issues & Solutions

### Issue 1: "Package name already exists"

**Solution:**
- ต้องเปลี่ยนชื่อ package ใน pubspec.yaml
- ตรวจสอบว่าชื่อซ้ำกับ package อื่นใน pub.dev หรือไม่

### Issue 2: "Missing homepage or repository"

**Solution:**
```yaml
homepage: https://github.com/username/package
repository: https://github.com/username/package
```

### Issue 3: "Package validation failed"

**Reasons:**
- Missing LICENSE file
- Missing README.md
- Missing CHANGELOG.md
- Invalid pubspec.yaml format

**Solution:**
```bash
flutter pub publish --dry-run
# อ่าน error messages แล้วแก้ไข
```

### Issue 4: "Version already published"

**Solution:**
- ต้องเพิ่ม version ใหม่
- ไม่สามารถ publish version เดิมซ้ำได้

### Issue 5: "Analysis errors found"

**Solution:**
```bash
flutter analyze
# แก้ไข errors ทั้งหมด
```

### Issue 6: "Score is low"

**Improve Score by:**
- ✅ Add comprehensive documentation
- ✅ Add example code
- ✅ Follow Dart/Flutter conventions
- ✅ Add platform support info
- ✅ Keep dependencies up to date
- ✅ Respond to issues

## 📊 Package Score

pub.dev ให้คะแนน package จาก 3 ส่วน:

### 1. Popularity (0-40 points)
- จำนวน package ที่ depend on package นี้
- Download count

### 2. Health (0-40 points)
- Code coverage
- Dependencies up to date
- Platforms supported
- Null safety

### 3. Maintenance (0-20 points)
- Recent commits
- Issue response time
- Changelog updated

**Maximum: 130 points**

## 🎯 Best Practices

### 1. Before Publishing

- [ ] Run all tests
- [ ] Run `flutter analyze`
- [ ] Run `flutter pub publish --dry-run`
- [ ] Review all documentation
- [ ] Test in example app
- [ ] Update CHANGELOG.md

### 2. Version Management

- Follow Semantic Versioning (semver)
- Document breaking changes
- Keep backward compatibility when possible

### 3. Documentation

- Keep README.md updated
- Add inline code documentation
- Provide examples
- Add migration guides for breaking changes

### 4. Maintenance

- Respond to issues promptly
- Update dependencies regularly
- Fix bugs quickly
- Add new features based on feedback

## 📝 Checklist ก่อน Publish

```markdown
- [ ] Tests ผ่านทั้งหมด (`flutter test`)
- [ ] ไม่มี linter errors (`flutter analyze`)
- [ ] Dry run ผ่าน (`flutter pub publish --dry-run`)
- [ ] README.md มีข้อมูลครบถ้วน
- [ ] CHANGELOG.md อัปเดตแล้ว
- [ ] LICENSE file มี
- [ ] Example code ใช้งานได้
- [ ] Version number ถูกต้อง
- [ ] pubspec.yaml มี homepage/repository
- [ ] ลบ `publish_to: none` ออกแล้ว
- [ ] Git repository clean (no uncommitted changes)
- [ ] Documentation ตรวจสอบแล้ว
```

## 🔗 Useful Links

- [pub.dev Publishing Guide](https://dart.dev/tools/pub/publishing)
- [Package Layout Conventions](https://dart.dev/tools/pub/package-layout)
- [Verified Publishers](https://dart.dev/tools/pub/verified-publishers)
- [Package Scoring](https://pub.dev/help/scoring)
- [Writing Package Pages](https://dart.dev/tools/pub/writing-package-pages)

## 🎓 Tips for Success

1. **Start with good documentation** - Users judge packages by README
2. **Provide working examples** - Show how to use your package
3. **Be responsive** - Answer issues and PRs quickly
4. **Version wisely** - Don't break existing users
5. **Test thoroughly** - Bugs hurt your reputation
6. **Market your package** - Share on Reddit, Twitter, etc.
7. **Iterate based on feedback** - Listen to your users

## 🚀 Quick Publish Commands

```bash
# 1. Final checks
flutter test
flutter analyze
flutter pub publish --dry-run

# 2. Publish
flutter pub publish

# 3. Tag release
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

## 💡 Pro Tips

1. **Use GitHub Actions** for automated testing
2. **Enable Dependabot** for dependency updates
3. **Add Code Coverage** badge
4. **Create a website** for your package
5. **Write blog posts** about your package
6. **Join Flutter/Dart communities** to promote

---

**Ready to publish?** Follow the checklist and you'll be live on pub.dev in minutes! 🎉

