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
    String collectionName = 'contents',
    bool cacheEnabled = true,
  }) async {
    if (_isInitialized) return;

    try {
      // Load all available keys from Directus
      await _loadAllKeys(baseUrl, accessToken, collectionName);
      _isInitialized = true;
      _logger.i('DynamicI18nService initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize DynamicI18nService: $e');
      rethrow;
    }
  }

  /// Load all available keys from Directus
  static Future<void> _loadAllKeys(
    String baseUrl,
    String accessToken,
    String collectionName,
  ) async {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    try {
      final response = await dio.get(
        '/items/$collectionName',
        queryParameters: {
          'access_token': accessToken,
          'fields': 'key,translations.message',
          'deep[translations][_filter][message][_nnull]': 'true',
          'limit': '-1',
        },
      );

      _keyCache.clear();
      _fallbackCache.clear();

      for (final item in response.data['data']) {
        final String key = item['key'].toString();
        final translations = item['translations'] as List?;
        
        if (translations != null && translations.isNotEmpty) {
          final String? value = translations[0]['message'];
          
          if (value != null) {
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
  static Future<void> refreshKeys() async {
    if (!_isInitialized) return;
    
    final config = DirectusI18nService.config;
    await _loadAllKeys(
      config.baseUrl,
      config.accessToken,
      config.collectionName,
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
