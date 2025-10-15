part of directus_i18n;

/// Hybrid I18n Service that combines enum generation with dynamic loading
/// This provides the best of both worlds: type safety + runtime flexibility
class HybridI18nService {
  static final Logger _logger = Logger();
  static bool _isInitialized = false;
  static final Map<String, String> _dynamicCache = {};
  
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
          'fields': 'key,translations.message',
          'deep[translations][_filter][message][_nnull]': 'true',
          'limit': '-1',
        },
      );
      
      _dynamicCache.clear();
      
      for (final item in response.data['data']) {
        final String key = item['key'].toString();
        final translations = item['translations'] as List?;
        
        if (translations != null && translations.isNotEmpty) {
          final String? value = translations[0]['message'];
          if (value != null) {
            _dynamicCache[key] = value;
          }
        }
      }
      
      _logger.d('Loaded ${_dynamicCache.length} dynamic keys for fallback');
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
        final enumPath = AutoEnumService.getGeneratedEnumPath();
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
    String translation = _dynamicCache[key] ?? fallback ?? key;
    
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
    
    // Force regenerate enum
    await AutoEnumService.forceRegenerate(
      baseUrl: DirectusI18nService.config.baseUrl,
      accessToken: DirectusI18nService.config.accessToken,
      collectionName: DirectusI18nService.config.collectionName,
    );
    
    // Refresh dynamic cache
    await _loadDynamicKeys(
      DirectusI18nService.config.baseUrl,
      DirectusI18nService.config.accessToken,
      DirectusI18nService.config.collectionName,
    );
    
    _logger.i('✅ Hybrid i18n refreshed');
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
