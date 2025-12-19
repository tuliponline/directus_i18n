part of directus_i18n;

/// Dynamic I18n Service that loads keys from Directus without enum generation
class DynamicI18nService {
  static final Logger _logger = Logger();
  static final Map<String, String> _keyCache = {};
  static final Map<String, String> _fallbackCache = {};
  static bool _isInitialized = false;

  /// Initialize the dynamic i18n service
  static Future<void> init({
    required String baseUrl,
    required String accessToken,
    String collectionName = 'app_content',
    String? pagePrefix,
    Locale? locale,
    bool cacheEnabled = true,
  }) async {
    if (_isInitialized) return;

    try {
      // Load all available keys from Directus
      await _loadAllKeys(baseUrl, accessToken, collectionName, 
        pagePrefix: pagePrefix, locale: locale);
      _isInitialized = true;
      _logger.i('DynamicI18nService initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize DynamicI18nService: $e');
      rethrow;
    }
  }

  /// Load all available keys from Directus
  /// Supports new app_content structure with translations.value(en-US) and translations.value(th-TH)
  static Future<void> _loadAllKeys(
    String baseUrl,
    String accessToken,
    String collectionName,
    {String? pagePrefix, Locale? locale}
  ) async {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    try {
      // Determine locale for translation field
      final targetLocale = locale ?? const Locale('en', 'US');
      final localeString = targetLocale.toString().replaceAll('_', '-');
      final translationField = 'translations.value($localeString)';
      
      // Build query for new app_content structure
      final queryParams = <String, dynamic>{
        'access_token': accessToken,
        'fields': 'key,$translationField,translations.value(en-US),translations.value(th-TH),status',
        'filter[status][_eq]': 'published',
        'limit': '-1',
      };

      // Filter by page prefix if provided
      if (pagePrefix != null && pagePrefix.isNotEmpty) {
        // Get page ID from app_page collection
        final pageResponse = await dio.get(
          '/items/app_page',
          queryParameters: {
            'access_token': accessToken,
            'fields': 'id,key',
            'filter[key][_eq]': pagePrefix,
            'filter[status][_eq]': 'published',
            'limit': '1',
          },
        );

        if (pageResponse.data['data'] != null && 
            (pageResponse.data['data'] as List).isNotEmpty) {
          final pageId = pageResponse.data['data'][0]['id'];
          queryParams['filter[page][_eq]'] = pageId;
        } else {
          _logger.w('Page prefix "$pagePrefix" not found in app_page');
          return;
        }
      }

      final response = await dio.get(
        '/items/$collectionName',
        queryParameters: queryParams,
      );

      _keyCache.clear();
      _fallbackCache.clear();

      for (final item in response.data['data'] ?? []) {
        final String key = item['key']?.toString() ?? '';
        if (key.isEmpty) continue;
        
        final translations = item['translations'] as Map<String, dynamic>?;
        
        if (translations != null && translations.isNotEmpty) {
          // Try to get translation for target locale first
          String? value = translations['value($localeString)']?.toString();
          
          // Fallback to en-US if target locale not found
          if (value == null || value.isEmpty) {
            value = translations['value(en-US)']?.toString();
          }
          
          // Fallback to th-TH if still not found
          if (value == null || value.isEmpty) {
            value = translations['value(th-TH)']?.toString();
          }
          
          // Fallback to any available translation
          if (value == null || value.isEmpty) {
            for (final entry in translations.entries) {
              if (entry.key.startsWith('value(') && entry.value != null) {
                value = entry.value.toString();
                break;
              }
            }
          }
          
          if (value != null && value.isNotEmpty) {
            _keyCache[key] = value;
            _fallbackCache[key] = value;
          }
        }
      }

      _logger.d('Loaded ${_keyCache.length} dynamic i18n keys');
    } catch (e) {
      _logger.e('Failed to load dynamic i18n keys: $e');
      rethrow;
    }
  }

  /// Refresh keys from Directus (useful for hot reload)
  static Future<void> refreshKeys({Locale? locale}) async {
    if (!_isInitialized) return;
    
    final config = DirectusI18nService.config;
    await _loadAllKeys(
      config.baseUrl,
      config.accessToken,
      config.collectionName,
      pagePrefix: config.pagePrefix,
      locale: locale,
    );
  }

  /// Get translation for a key
  static String translate(
    String key, {
    String? fallback,
    Map<String, String>? params,
    BuildContext? context,
  }) {
    if (!_isInitialized) {
      _logger.w('DynamicI18nService not initialized, returning key: $key');
      return fallback ?? key;
    }

    // Get translation from cache
    String translation = _keyCache[key] ?? fallback ?? key;

    // Apply parameter substitution
    if (params != null) {
      for (final paramKey in params.keys) {
        translation = translation.replaceAll(
          '{$paramKey}',
          params[paramKey]!,
        );
      }
    }

    return translation;
  }

  /// Check if a key exists
  static bool hasKey(String key) {
    return _keyCache.containsKey(key);
  }

  /// Get all available keys
  static List<String> getAllKeys() {
    return _keyCache.keys.toList();
  }

  /// Get fallback text for a key
  static String? getFallback(String key) {
    return _fallbackCache[key];
  }

  /// Clear cache (useful for testing)
  static void clearCache() {
    _keyCache.clear();
    _fallbackCache.clear();
    _isInitialized = false;
  }
}
