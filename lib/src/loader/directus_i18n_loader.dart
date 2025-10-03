part of directus_i18n;

/// Internal localization state management
class _Localization {
  static Map<String, String>? translation;
  static Locale? locale;
  static final Lock sync = Lock();
}

/// Custom translation loader for FlutterI18n that loads from Directus
class DirectusI18nLoader extends TranslationLoader {
  final DirectusI18nRepository _repository;
  final Map<String, String>? _forcedTranslation;
  final VoidCallback? _onLocaleUpdated;

  DirectusI18nLoader(
    DirectusI18nRepository repository, {
    Map<String, String>? forcedTranslation,
    VoidCallback? onLocaleUpdated,
  })  : _repository = repository,
        _forcedTranslation = forcedTranslation,
        _onLocaleUpdated = onLocaleUpdated;

  @override
  Future<Map> load() async {
    return _Localization.sync.synchronized(() async {
      final currentLocale = locale ?? await findDeviceLocale();
      
      if (_Localization.locale != currentLocale) {
        _Localization.locale = currentLocale;
        
        try {
          final translationMap = await _repository.load(currentLocale);
          _Localization.translation = translationMap;
          
          // Notify listeners after locale update
          Future.delayed(Duration.zero, () {
            _onLocaleUpdated?.call();
          });
        } catch (e) {
          Logger().e('Error loading translations: $e');
          // Return empty map on error, will use fallback keys
          _Localization.translation ??= {};
        }
      }
      
      return _forcedTranslation ?? _Localization.translation ?? {};
    });
  }
}

