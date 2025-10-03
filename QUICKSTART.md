# Quick Start Guide

Get started with `directus_i18n` in 5 minutes!

## 1. Install (30 seconds)

Add to `pubspec.yaml`:
```yaml
dependencies:
  directus_i18n:
    path: packages/directus_i18n
```

Run:
```bash
flutter pub get
```

## 2. Initialize (1 minute)

```dart
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize
  DirectusI18nService.init(
    baseUrl: 'https://your-directus.com',
    accessToken: 'your-token',
  );
  
  runApp(MyApp());
}
```

## 3. Setup MaterialApp (1 minute)

```dart
import 'package:get_it/get_it.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: DirectusI18nLoader(
            GetIt.I<DirectusI18nRepository>(),
          ),
        ),
        // Add other delegates...
      ],
      supportedLocales: [
        Locale('en'),
        Locale('th'),
      ],
      home: HomePage(),
    );
  }
}
```

## 4. Generate Keys (1 minute)

Create `scripts/generate_keys.dart`:
```dart
import 'package:directus_i18n/directus_i18n.dart';

void main() async {
  await DirectusI18nKeyGenerator.generate(
    baseUrl: 'https://your-directus.com',
    accessToken: 'your-token',
    outputPath: 'lib/i18n_keys.dart',
  );
}
```

Run:
```bash
dart run scripts/generate_keys.dart
```

## 5. Use in UI (30 seconds)

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18nKeys.key1.translate(context: context)),
      ),
      body: Text(I18nKeys.key2.translate(context: context)),
    );
  }
}
```

## Done! 🎉

You now have a working i18n setup with Directus CMS!

## Next Steps

- **Add more languages**: Update `supportedLocales` in MaterialApp
- **Add parameters**: Use `translationParams: {'key': 'value'}`
- **Change language**: Call `FlutterI18n.refresh(context, newLocale)`
- **Read full docs**: Check [README.md](README.md) and [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)

## Common Issues

**Translations not showing?**
- Check Directus URL and token are correct
- Verify collection name (default: 'app_contents')
- Run key generator script

**Context error?**
- Pass `context` to `translate()` method
- Or configure `navigatorKey` in initialization

**Need help?**
- See example app in `example/`
- Check integration guide
- Review test files for patterns

