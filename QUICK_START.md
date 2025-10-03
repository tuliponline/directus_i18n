# Quick Start Guide - การเริ่มต้นใช้งาน

## 🚀 เริ่มต้นใช้งานใน 5 นาที

### Step 1: Setup Project

```bash
# 1. ไปยัง Flutter project ของคุณ
cd your-flutter-project

# 2. Run setup script
dart run packages/directus_i18n/scripts/setup_new_project.dart

# 3. Follow the prompts
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Generate I18n Enum

```bash
# Generate enum from Directus
dart run packages/directus_i18n/scripts/auto_generate_enum.dart

# หรือใช้ Makefile
make i18n-generate
```

### Step 4: เริ่มใช้งาน

```dart
// ใน main.dart
import 'package:directus_i18n/directus_i18n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await HybridI18nService.init(
    baseUrl: 'https://your-directus.com',
    accessToken: 'your-token',
    autoGenerateEnum: true,
  );
  
  runApp(MyApp());
}

// ใน widget
Text('welcome'.tr())
Text(HybridI18nService.translate('welcome_user', params: {'name': 'John'}))
```

## 📋 Configuration

### Environment Variables (.env)

```bash
DIRECTUS_BASE_URL=https://your-directus.com
DIRECTUS_ACCESS_TOKEN=your-token
DIRECTUS_COLLECTION_NAME=app_contents
I18N_ENUM_NAME=MyAppI18nKeys
```

### pubspec.yaml

```yaml
dependencies:
  directus_i18n:
    path: packages/directus_i18n
  flutter_dotenv: ^5.1.0
```

## 🎯 Usage Methods

### 1. String Extension (ง่ายที่สุด)

```dart
Text('welcome'.tr())
Text('welcome_user'.tr(params: {'name': 'John'}))
Text('missing_key'.tr(fallback: 'Fallback text'))
```

### 2. Hybrid Service

```dart
Text(HybridI18nService.translate('welcome'))
Text(HybridI18nService.translate('welcome_user', params: {'name': 'John'}))
```

### 3. DynamicI18nText Widget

```dart
DynamicI18nText('welcome')
DynamicI18nText('welcome_user', params: {'name': 'John'})
```

### 4. Generated Enum (Type Safe)

```dart
// หลังจาก generate enum
Text(MyAppI18nKeys.welcome.translate())
Text(MyAppI18nKeys.welcomeUser.translate(params: {'name': 'John'}))
```

## 🔄 Workflow

### สำหรับ Content Team

1. **เพิ่ม content ใน Directus**
2. **Keys ใช้ได้ทันที** - ไม่ต้อง generate
3. **หรือ generate enum ใหม่** - `make i18n-generate`

### สำหรับ Developer

1. **ใช้ keys ในโค้ด** - `'key'.tr()`
2. **Shorebird patch** - แก้ไขข้อความได้
3. **ไม่ต้อง release** - เพิ่ม keys ใหม่ได้

## 🛠️ Commands

```bash
# Generate enum
make i18n-generate

# Clean generated files
make i18n-clean

# Refresh (clean + generate)
make i18n-refresh

# Check status
make i18n-status

# Help
make help
```

## 🧪 Testing

```dart
// Unit test
test('should translate key', () {
  expect('welcome'.tr(), equals('Welcome!'));
});

// Widget test
testWidgets('should display translated text', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: DynamicI18nText('welcome')),
  );
  expect(find.text('Welcome!'), findsOneWidget);
});
```

## 🔍 Debugging

```dart
// Enable debug logging
Logger.level = Level.debug;

// Check service status
Map<String, dynamic> status = HybridI18nService.getStatus();
print('Status: $status');
```

## 📚 Next Steps

- [Integration Guide](INTEGRATION_GUIDE.md) - การ integrate กับ project อื่น
- [Runtime Enum Guide](RUNTIME_ENUM_GUIDE.md) - การใช้ enum generation
- [Dynamic I18n Guide](DYNAMIC_I18N_GUIDE.md) - การใช้ dynamic i18n

## 🆘 Need Help?

- Check [Troubleshooting](INTEGRATION_GUIDE.md#troubleshooting)
- Run `make i18n-status` to check status
- Enable debug logging for detailed logs
