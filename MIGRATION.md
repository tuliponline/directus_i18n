# Migration Guide

Guide for migrating from the old `i18n` package to `directus_i18n`.

## Quick Migration

### 1. Update Dependencies

**Old:**
```yaml
dependencies:
  i18n:
    path: ../i18n
```

**New:**
```yaml
dependencies:
  directus_i18n:
    path: ../directus_i18n
```

### 2. Update Imports

**Old:**
```dart
import 'package:i18n/i18n.dart';
```

**New:**
```dart
import 'package:directus_i18n/directus_i18n.dart';
```

### 3. Update Initialization

**Old:**
```dart
// In app_module.dart or similar
I18nService.init();
```

**New:**
```dart
DirectusI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'app_contents',
  isProduction: true,
  navigatorKey: NavigationService.navigatorKey, // Optional
);
```

### 4. Update Repository Usage

**Old:**
```dart
RepositoryProvider(create: (_) => GetIt.I<I18nRepository>()),
```

**New:**
```dart
RepositoryProvider(create: (_) => GetIt.I<DirectusI18nRepository>()),
```

### 5. Update Loader Usage

**Old:**
```dart
FlutterI18nDelegate(
  translationLoader: DirectusI18nLoader(
    i18nRepository,
    onLocaleUpdated: onLocaleUpdated,
  ),
)
```

**New:**
```dart
FlutterI18nDelegate(
  translationLoader: DirectusI18nLoader(
    directusI18nRepository,
    onLocaleUpdated: onLocaleUpdated,
  ),
)
```

### 6. Translation Usage (No Change!)

The translation API remains backward compatible:

```dart
// Still works the same way
Text(I18nKeys.key1.translate(context: context))

// With parameters
Text(I18nKeys.key2.translate(
  context: context,
  translationParams: {'name': 'John'},
))
```

## Key Differences

### Removed Dependencies

The new package removes dependency on:
- `utils` package (PiPlatformChannel, NavigationService)
- `injector` package
- `env` package

### New Features

1. **Configuration Object**: All settings in one place
2. **Optional Navigator Key**: Can be configured or passed explicitly
3. **Better Error Handling**: Custom error callbacks
4. **Standalone**: No dependencies on project-specific packages

## Advanced Migration

### Platform Channel Integration

**Old (using PiPlatformChannel):**
```dart
I18nRepository({
  PiPlatformChannel? platformChannel
})
```

**New (using callback):**
```dart
DirectusI18nService.init(
  // ...
  platformChannelGetter: () async {
    final channel = MethodChannel('your_channel');
    final result = await channel.invokeMethod('getAppContents');
    return Map<String, String>.from(result);
  },
);
```

### Custom HTTP Client

**Old:**
```dart
I18nRepository(
  httpClient: customDio,
)
```

**New:**
```dart
DirectusI18nService.init(
  // ...
  httpClient: customDio,
);
```

### Navigation Context

**Old (using NavigationService.navigatorKey):**
```dart
I18nKeys.key1.translate()
// Uses NavigationService.navigatorKey.currentContext
```

**New (configurable):**
```dart
DirectusI18nService.init(
  // ...
  navigatorKey: yourNavigatorKey,
);

I18nKeys.key1.translate()
// Or pass context explicitly
I18nKeys.key1.translate(context: context)
```

## Testing Migration

**Old:**
```dart
class MockI18nRepository extends Mock implements I18nRepository {}
```

**New:**
```dart
class MockDirectusI18nRepository extends Mock implements DirectusI18nRepository {}
```

## Checklist

- [ ] Update `pubspec.yaml` dependencies
- [ ] Update all imports
- [ ] Update service initialization
- [ ] Update repository providers
- [ ] Configure navigator key (if needed)
- [ ] Configure platform channel (if needed)
- [ ] Update tests
- [ ] Run tests to verify
- [ ] Update documentation

## Need Help?

If you encounter issues during migration:
1. Check the example app in `directus_i18n/example/`
2. Review the API documentation in `README.md`
3. Check the test files for usage examples

