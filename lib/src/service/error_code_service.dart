part of directus_i18n;

/// Simple Error Code Service for managing error codes from Directus
class ErrorCodeService {
  static final Logger _logger = Logger();
  static final Map<String, ErrorCode> _errorCodeCache = {};
  static bool _isInitialized = false;
  static String? _baseUrl;
  static String? _accessToken;
  static String _collectionName = 'error_codes';

  /// Initialize the Error Code Service
  static Future<void> init({
    required String baseUrl,
    required String accessToken,
    String collectionName = 'error_codes',
    bool autoLoad = true,
  }) async {
    _baseUrl = baseUrl;
    _accessToken = accessToken;
    _collectionName = collectionName;

    if (autoLoad) {
      await loadErrorCodes();
    }

    _isInitialized = true;
    _logger.i('ErrorCodeService initialized with collection: $collectionName');
  }

  /// Load error codes from Directus
  static Future<void> loadErrorCodes() async {
    if (_baseUrl == null || _accessToken == null) {
      _logger.e('ErrorCodeService not initialized. Call init() first.');
      return;
    }

    try {
      _logger.i('🔄 Loading error codes from Directus...');
      
      final dio = Dio(BaseOptions(baseUrl: _baseUrl!));
      
      // Load error codes with translations from error_translations collection
      final response = await dio.get(
        '/items/$_collectionName',
        queryParameters: {
          'access_token': _accessToken,
          'fields': 'code,translations.id,translations.error_code,translations.language_code,translations.message',
          'deep[translations][_filter][message][_nnull]': 'true',
          'limit': '-1',
        },
      );

      _errorCodeCache.clear();

      for (final item in response.data['data']) {
        final errorCode = ErrorCode.fromDirectus(item);
        if (errorCode.code.isNotEmpty) {
          _errorCodeCache[errorCode.code] = errorCode;
        }
      }

      _logger.i('✅ Loaded ${_errorCodeCache.length} error codes from Directus');
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to load error codes', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get error code by code
  static ErrorCode? getErrorCode(String code) {
    if (!_isInitialized) {
      _logger.w('ErrorCodeService not initialized. Call init() first.');
      return null;
    }
    return _errorCodeCache[code];
  }

  /// Get all error codes
  static List<ErrorCode> getAllErrorCodes() {
    if (!_isInitialized) {
      _logger.w('ErrorCodeService not initialized. Call init() first.');
      return [];
    }
    return _errorCodeCache.values.toList();
  }

  /// Get localized error message
  static String getLocalizedMessage(
    String code, {
    String? languageCode,
    Map<String, String>? parameters,
    String? fallback,
  }) {
    final errorCode = getErrorCode(code);
    if (errorCode == null) {
      return fallback ?? code;
    }

    return errorCode.getLocalizedMessage(
      languageCode: languageCode,
      parameters: parameters,
      fallback: fallback,
    );
  }

  /// Check if error code exists
  static bool hasErrorCode(String code) {
    return _errorCodeCache.containsKey(code);
  }

  /// Get error codes count
  static int getErrorCodesCount() {
    return _errorCodeCache.length;
  }

  /// Refresh error codes from Directus
  static Future<void> refresh() async {
    await loadErrorCodes();
    _logger.i('🔄 Error codes refreshed');
  }

  /// Clear cache
  static void clearCache() {
    _errorCodeCache.clear();
    _isInitialized = false;
    _logger.i('🧹 Error codes cache cleared');
  }

  /// Get service status
  static Map<String, dynamic> getStatus() {
    return {
      'initialized': _isInitialized,
      'errorCodesCount': _errorCodeCache.length,
      'collectionName': _collectionName,
      'baseUrl': _baseUrl,
    };
  }

  /// Get error codes by search term
  static List<ErrorCode> searchErrorCodes(String searchTerm) {
    if (!_isInitialized) {
      _logger.w('ErrorCodeService not initialized. Call init() first.');
      return [];
    }

    final term = searchTerm.toLowerCase();
    return _errorCodeCache.values.where((errorCode) {
      return errorCode.code.toLowerCase().contains(term) ||
             (errorCode.message?.toLowerCase().contains(term) ?? false);
    }).toList();
  }

  /// Get all available languages across all error codes
  static Set<String> getAllAvailableLanguages() {
    if (!_isInitialized) {
      _logger.w('ErrorCodeService not initialized. Call init() first.');
      return {};
    }

    final languages = <String>{};
    for (final errorCode in _errorCodeCache.values) {
      if (errorCode.translations != null) {
        languages.addAll(errorCode.translations!.keys);
      }
    }
    return languages;
  }
  
  /// Load available languages from Directus language collection
  static Future<Set<String>> loadAvailableLanguages() async {
    if (_baseUrl == null || _accessToken == null) {
      _logger.e('ErrorCodeService not initialized. Call init() first.');
      return {};
    }

    try {
      _logger.i('🔄 Loading available languages from Directus...');
      
      final dio = Dio(BaseOptions(baseUrl: _baseUrl!));
      final response = await dio.get(
        '/items/language',
        queryParameters: {
          'access_token': _accessToken,
          'fields': 'code',
          'limit': '-1',
        },
      );

      final languages = <String>{};
      for (final item in response.data['data']) {
        final code = item['code']?.toString();
        if (code != null && code.isNotEmpty) {
          languages.add(code);
        }
      }

      _logger.i('✅ Loaded ${languages.length} available languages from Directus');
      return languages;
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to load available languages', error: e, stackTrace: stackTrace);
      return {};
    }
  }
  
  /// Get available languages (alias for getAllAvailableLanguages as List)
  static List<String> getAvailableLanguages() {
    return getAllAvailableLanguages().toList();
  }

  /// Get error codes that have translation for specific language
  static List<ErrorCode> getErrorCodesWithLanguage(String languageCode) {
    if (!_isInitialized) {
      _logger.w('ErrorCodeService not initialized. Call init() first.');
      return [];
    }

    return _errorCodeCache.values
        .where((errorCode) => errorCode.hasTranslationFor(languageCode))
        .toList();
  }
}
