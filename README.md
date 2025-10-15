# Directus I18n Package

A powerful Flutter package for internationalization using Directus CMS as the content source, with support for runtime enum generation and dynamic translation loading.

## ✨ Features

- 🌍 **Dynamic Content Loading** - Load translations from Directus CMS
- 🔄 **Runtime Enum Generation** - Generate enum files in codebase without releasing new app versions
- 💾 **Hybrid Approach** - Combine enum type safety with dynamic flexibility
- 🚀 **Shorebird Compatible** - Full support for code push updates
- 🎯 **Type Safe** - Compile-time checking with generated enums
- 📝 **Parameter Substitution** - Support for dynamic parameters in translations
- 🧪 **Fully Testable** - Mock support for unit and widget tests
- 🔧 **Easy Migration** - Simple migration from existing i18n solutions

## 🚀 Quick Start

### 1. Setup New Project

```bash
# Run setup script
dart run packages/directus_i18n/scripts/setup_new_project.dart

# Follow the prompts
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate I18n Enum

```bash
# Generate enum from Directus
dart run packages/directus_i18n/scripts/auto_generate_enum.dart

# Or use Makefile
make i18n-generate
```

### 4. Start Using

```dart
// In main.dart
import 'package:directus_i18n/directus_i18n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await HybridI18nService.init(
    baseUrl: 'https://your-directus.com',
    accessToken: 'your-token',
    collectionName: 'contents',
    autoGenerateEnum: true,
  );
  
  runApp(MyApp());
}

// In widgets
Text('welcome'.tr())
Text(HybridI18nService.translate('welcome_user', params: {'name': 'John'}))
```

## 📚 Documentation

- [Quick Start Guide](QUICK_START.md) - เริ่มต้นใช้งานใน 5 นาที
- [Integration Guide](INTEGRATION_GUIDE.md) - การนำไปใช้กับ project อื่น
- [Runtime Enum Guide](RUNTIME_ENUM_GUIDE.md) - การใช้ enum generation
- [Dynamic I18n Guide](DYNAMIC_I18N_GUIDE.md) - การใช้ dynamic i18n

## 🔧 Usage Methods

### 1. String Extension (Easiest)

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
// After generating enum
Text(MyAppI18nKeys.welcome.translate())
Text(MyAppI18nKeys.welcomeUser.translate(params: {'name': 'John'}))
```

## 🔄 Migration

### From Existing I18n Solutions

```bash
# Run migration script
dart run packages/directus_i18n/scripts/migrate_existing_project.dart

# Follow the prompts
```

### Supported Migrations

- ✅ flutter_i18n
- ✅ intl package
- ✅ easy_localization
- ✅ custom i18n solutions

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

## 📋 Configuration

### Environment Variables (.env)

```bash
DIRECTUS_BASE_URL=https://your-directus.com
DIRECTUS_ACCESS_TOKEN=your-token
DIRECTUS_COLLECTION_NAME=contents
I18N_ENUM_NAME=MyAppI18nKeys
```

### pubspec.yaml

```yaml
dependencies:
  directus_i18n:
    path: packages/directus_i18n
  flutter_dotenv: ^5.1.0
```

## 🚀 Shorebird Integration

### What Can Be Patched

✅ **Can Patch:**
- Generated enum files in `lib/generated/`
- Translation values (text content)
- UI layout changes
- New enum usage in code

❌ **Cannot Patch:**
- Core service initialization changes
- API endpoint changes
- Major structural changes

### Patch Workflow

1. **Update translations in Directus**
2. **Regenerate enum files**
   ```bash
   dart run packages/directus_i18n/scripts/auto_generate_enum.dart
   ```
3. **Update Flutter code to use new keys**
4. **Create Shorebird patch**
   ```bash
   shorebird patch android
   shorebird patch ios
   ```

## 📊 Performance

- **Memory Usage**: ~2-10MB for 1000+ keys
- **Network Usage**: Single API call at startup
- **File Generation**: Minimal performance impact
- **Caching**: In-memory caching for better performance

## 🆘 Troubleshooting

### Common Issues

**Q: Package not found**
A: Check pubspec.yaml and run `flutter pub get`

**Q: Environment variables not loaded**
A: Ensure `.env` file exists and `flutter_dotenv` is added

**Q: Generated enum not found**
A: Check if `lib/generated/` directory exists and run generation script

**Q: Translations not working**
A: Check Directus connection and access token

### Debug Commands

```bash
# Check package installation
flutter pub deps | grep directus_i18n

# Generate enum manually
dart run packages/directus_i18n/scripts/auto_generate_enum.dart

# Check generated files
ls -la lib/generated/

# Test translation
flutter test test/i18n_test.dart
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Related Resources

- [Directus Documentation](https://docs.directus.io)
- [Shorebird Documentation](https://shorebird.dev)
- [Flutter I18n Package](https://pub.dev/packages/flutter_i18n)
- [Example App](example/runtime_enum_example.dart)

## 📞 Support

- 📧 Email: support@example.com
- 💬 Discord: [Join our community](https://discord.gg/example)
- 🐛 Issues: [GitHub Issues](https://github.com/example/directus_i18n/issues)
- 📖 Wiki: [GitHub Wiki](https://github.com/example/directus_i18n/wiki)