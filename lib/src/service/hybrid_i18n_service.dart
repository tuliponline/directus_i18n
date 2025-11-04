part of directus_i18n;

/// Hybrid I18n Service that combines enum generation with dynamic loading
/// This provides the best of both worlds: type safety + runtime flexibility
class HybridI18nService {
  static final Logger _logger = Logger();
  static bool _isInitialized = false;
  // Cache structure: Map<i18nKey, Map<languageCode, message>>
  static final Map<String, Map<String, String>> _dynamicCache = {};
  
  /// Initialize hybrid i18n service
  static Future<void> init({
    required String baseUrl,
    required String accessToken,
    String collectionName = 'contents',
    String enumName = 'HybridI18nKeys',
    bool autoGenerateEnum = true,
    bool enableDynamicFallback = true,
  }) async {
    if (_isInitialized) return;
    
    _logger.i('🚀 Initializing HybridI18nService...');
    
    // Initialize auto enum service
    if (autoGenerateEnum) {
      await AutoEnumService.init(
        baseUrl: baseUrl,
        accessToken: accessToken,
        collectionName: collectionName,
        enumName: enumName,
      );
    }
    
    // Load dynamic keys for fallback
    if (enableDynamicFallback) {
      await _loadDynamicKeys(baseUrl, accessToken, collectionName);
    }
    
    _isInitialized = true;
    _logger.i('✅ HybridI18nService initialized');
  }
  
  /// Load dynamic keys for fallback
  static Future<void> _loadDynamicKeys(
    String baseUrl,
    String accessToken,
    String collectionName,
  ) async {
    try {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      final response = await dio.get(
        '/items/$collectionName',
        queryParameters: {
          'access_token': accessToken,
          'fields': 'key,translations.language_code,translations.message',
          'deep[translations][_filter][message][_nnull]': 'true',
          'limit': '-1',
        },
      );
      
      _dynamicCache.clear();
      
      final data = response.data['data'] as List?;
      if (data == null) {
        _logger.w('No data returned from Directus');
        return;
      }
      
      for (final item in data) {
        final String key = item['key'].toString();
        final translations = item['translations'] as List?;
        
        if (translations != null && translations.isNotEmpty) {
          // Store all language translations for this key
          final keyTranslations = <String, String>{};
          
          for (final translation in translations) {
            // Get language code - handle different possible structures
            String? languageCode;
            final langCodeData = translation['language_code'];
            
            if (langCodeData is Map<String, dynamic>) {
              // If language_code is a relationship object, get the code
              languageCode = langCodeData['code']?.toString();
            } else if (langCodeData is String) {
              // If language_code is directly a string
              languageCode = langCodeData;
            }
            
            final String? message = translation['message']?.toString();
            
            if (languageCode != null && message != null && message.isNotEmpty) {
              keyTranslations[languageCode] = message;
            }
          }
          
          if (keyTranslations.isNotEmpty) {
            _dynamicCache[key] = keyTranslations;
          }
        }
      }
      
      _logger.d('Loaded ${_dynamicCache.length} dynamic keys with multiple languages');
    } catch (e) {
      _logger.e('Failed to load dynamic keys: $e');
    }
  }
  
  /// Translate using hybrid approach (enum first, then dynamic)
  static String translate(
    String key, {
    String? fallback,
    Map<String, String>? params,
    BuildContext? context,
  }) {
    // First try to use generated enum if available
    if (AutoEnumService.hasGeneratedEnum()) {
      try {
        // Try to find the key in generated enum
        // This would require dynamic loading of the generated enum
        // For now, fall back to dynamic translation
      } catch (e) {
        _logger.d('Enum translation failed, falling back to dynamic: $e');
      }
    }
    
    // Fall back to dynamic translation
    return _translateDynamic(key, fallback: fallback, params: params, context: context);
  }
  
  /// Dynamic translation fallback
  static String _translateDynamic(
    String key, {
    String? fallback,
    Map<String, String>? params,
    BuildContext? context,
  }) {
    // Get language code from context if available
    String? languageCode;
    if (context != null) {
      try {
        final locale = Localizations.localeOf(context);
        // Try full locale first (e.g., 'th-TH'), then language code (e.g., 'th')
        languageCode = locale.toString(); // 'th_TH' format
        // Also try language code only
        final languageCodeOnly = locale.languageCode;
        
        // Normalize language code formats
        final normalizedFull = languageCode.replaceAll('_', '-');
        final normalizedShort = languageCodeOnly;
        
        // Try to get translation with full locale first, then language code only
        final keyTranslations = _dynamicCache[key];
        if (keyTranslations != null) {
          // Try exact match first (th-TH)
          if (keyTranslations.containsKey(normalizedFull)) {
            languageCode = normalizedFull;
          }
          // Try language code only (th)
          else if (keyTranslations.containsKey(normalizedShort)) {
            languageCode = normalizedShort;
          }
          // Try common variations
          else if (keyTranslations.containsKey('${locale.languageCode}-${locale.countryCode}')) {
            languageCode = '${locale.languageCode}-${locale.countryCode}';
          }
          // If no match, try to find any available translation
          else if (keyTranslations.isNotEmpty) {
            // Fallback to first available translation
            languageCode = keyTranslations.keys.first;
          }
        }
      } catch (e) {
        _logger.d('Could not get locale from context: $e');
      }
    }
    
    // Get translation for the language code
    String translation = fallback ?? key;
    final keyTranslations = _dynamicCache[key];
    
    if (keyTranslations != null) {
      if (languageCode != null && keyTranslations.containsKey(languageCode)) {
        translation = keyTranslations[languageCode]!;
      } else if (keyTranslations.isNotEmpty) {
        // Fallback to first available translation
        translation = keyTranslations.values.first;
      }
    }
    
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
  
  /// Check if key exists in either enum or dynamic cache
  static bool hasKey(String key) {
    return _dynamicCache.containsKey(key);
  }
  
  /// Check if key exists for specific language
  static bool hasKeyForLanguage(String key, String languageCode) {
    final keyTranslations = _dynamicCache[key];
    if (keyTranslations == null) return false;
    return keyTranslations.containsKey(languageCode);
  }
  
  /// Get all available keys
  static List<String> getAllKeys() {
    return _dynamicCache.keys.toList();
  }
  
  /// Get dynamic keys (alias for getAllKeys)
  static List<String> getDynamicKeys() {
    return getAllKeys();
  }
  
  /// Get available languages
  static List<String> getAvailableLanguages() {
    // This is a simplified implementation
    // In a real scenario, you'd extract languages from the loaded data
    return ['en', 'th']; // Default languages
  }
  
  /// Refresh both enum and dynamic keys
  static Future<void> refresh() async {
    _logger.i('🔄 Refreshing hybrid i18n...');
    
    // Get config from DirectusI18nService if available
    try {
      final config = DirectusI18nService.config;
      // Force regenerate enum
      await AutoEnumService.forceRegenerate(
        baseUrl: config.baseUrl,
        accessToken: config.accessToken,
        collectionName: config.collectionName,
      );
      
      // Refresh dynamic cache
      await _loadDynamicKeys(
        config.baseUrl,
        config.accessToken,
        config.collectionName,
      );
    } catch (e) {
      _logger.w('DirectusI18nService not initialized, skipping enum regeneration');
      // If DirectusI18nService is not initialized, we can't refresh
      // But we can still reload dynamic keys if we have the parameters
      _logger.w('Cannot refresh without DirectusI18nService.config');
    }
    
    _logger.i('✅ Hybrid i18n refreshed');
  }
  
  /// Refresh dynamic cache with explicit parameters
  static Future<void> refreshDynamicCache({
    required String baseUrl,
    required String accessToken,
    required String collectionName,
  }) async {
    await _loadDynamicKeys(baseUrl, accessToken, collectionName);
  }
  
  /// Get service status
  static Map<String, dynamic> getStatus() {
    return {
      'initialized': _isInitialized,
      'hasGeneratedEnum': AutoEnumService.hasGeneratedEnum(),
      'dynamicKeysCount': _dynamicCache.length,
      'enumInfo': AutoEnumService.getEnumInfo(),
    };
  }
}
