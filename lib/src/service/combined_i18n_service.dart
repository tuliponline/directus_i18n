part of directus_i18n;

/// Combined I18n Service for managing both I18n content and Error codes
/// This service provides a unified interface for both services
class CombinedI18nService {
  static final Logger _logger = Logger();
  static bool _isInitialized = false;

  /// Initialize both I18n and Error Code services
  static Future<void> init({
    required String baseUrl,
    required String accessToken,
    String i18nCollectionName = 'app_contents',
    String errorCollectionName = 'error_codes',
    String i18nEnumName = 'AppI18nKeys',
    bool autoGenerateEnum = true,
    bool enableDynamicFallback = true,
    bool autoLoadErrorCodes = true,
  }) async {
    try {
      _logger.i('🚀 Initializing Combined I18n Service...');

      // Initialize I18n Service
      await HybridI18nService.init(
        baseUrl: baseUrl,
        accessToken: accessToken,
        collectionName: i18nCollectionName,
        enumName: i18nEnumName,
        autoGenerateEnum: autoGenerateEnum,
        enableDynamicFallback: enableDynamicFallback,
      );

      // Initialize Error Code Service
      await ErrorCodeService.init(
        baseUrl: baseUrl,
        accessToken: accessToken,
        collectionName: errorCollectionName,
        autoLoad: autoLoadErrorCodes,
      );

      _isInitialized = true;
      _logger.i('✅ Combined I18n Service initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize Combined I18n Service', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Refresh both services
  static Future<void> refresh() async {
    if (!_isInitialized) {
      _logger.w('CombinedI18nService not initialized. Call init() first.');
      return;
    }

    try {
      _logger.i('🔄 Refreshing both services...');
      
      await Future.wait([
        HybridI18nService.refresh(),
        ErrorCodeService.refresh(),
      ]);
      
      _logger.i('✅ Both services refreshed successfully');
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to refresh services', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get combined status of both services
  static Map<String, dynamic> getStatus() {
    final i18nStatus = HybridI18nService.getStatus();
    final errorStatus = ErrorCodeService.getStatus();
    
    return {
      'initialized': _isInitialized,
      'i18n': i18nStatus,
      'errorCodes': errorStatus,
      'combined': {
        'i18nKeysCount': i18nStatus['dynamicKeysCount'] ?? 0,
        'errorCodesCount': errorStatus['errorCodesCount'] ?? 0,
        'totalItems': (i18nStatus['dynamicKeysCount'] ?? 0) + (errorStatus['errorCodesCount'] ?? 0),
      },
    };
  }

  /// Get I18n content
  static String translate(String key, {Map<String, String>? params}) {
    return HybridI18nService.translate(key, params: params);
  }

  /// Get error message
  static String getErrorMessage(
    String errorCode, {
    String? languageCode,
    Map<String, String>? parameters,
    String? fallback,
  }) {
    return ErrorCodeService.getLocalizedMessage(
      errorCode,
      languageCode: languageCode,
      parameters: parameters,
      fallback: fallback,
    );
  }

  /// Get error code object
  static ErrorCode? getErrorCode(String code) {
    return ErrorCodeService.getErrorCode(code);
  }

  /// Check if service is initialized
  static bool get isInitialized => _isInitialized;

  /// Get all available I18n keys
  static List<String> getI18nKeys() {
    return HybridI18nService.getDynamicKeys();
  }

  /// Get all available error codes
  static List<String> getErrorCodes() {
    return ErrorCodeService.getAllErrorCodes().map((e) => e.code).toList();
  }

  /// Get all available languages for I18n
  static List<String> getI18nLanguages() {
    return HybridI18nService.getAvailableLanguages();
  }

  /// Get all available languages for error codes
  static List<String> getErrorCodeLanguages() {
    return ErrorCodeService.getAvailableLanguages();
  }
  
  /// Load available languages from Directus
  static Future<List<String>> loadAvailableLanguages() async {
    final languages = await ErrorCodeService.loadAvailableLanguages();
    return languages.toList();
  }

  /// Get all available languages (combined)
  static List<String> getAllLanguages() {
    final i18nLanguages = getI18nLanguages();
    final errorLanguages = getErrorCodeLanguages();
    final allLanguages = <String>{};
    allLanguages.addAll(i18nLanguages);
    allLanguages.addAll(errorLanguages);
    return allLanguages.toList()..sort();
  }

  /// Check if I18n key exists
  static bool hasI18nKey(String key) {
    return HybridI18nService.hasKey(key);
  }

  /// Check if error code exists
  static bool hasErrorCode(String code) {
    return ErrorCodeService.hasErrorCode(code);
  }

  /// Get translation with fallback
  static String getTranslationWithFallback(String key, {String? fallback}) {
    if (hasI18nKey(key)) {
      return translate(key);
    }
    return fallback ?? key;
  }

  /// Get error message with fallback
  static String getErrorMessageWithFallback(String errorCode, {String? fallback}) {
    if (hasErrorCode(errorCode)) {
      return getErrorMessage(errorCode);
    }
    return fallback ?? errorCode;
  }

  /// Get both I18n and error data for a key
  static Map<String, dynamic> getCombinedData(String key) {
    final i18nValue = hasI18nKey(key) ? translate(key) : null;
    final errorValue = hasErrorCode(key) ? getErrorMessage(key) : null;
    
    return {
      'key': key,
      'i18nValue': i18nValue,
      'errorValue': errorValue,
      'hasI18n': hasI18nKey(key),
      'hasError': hasErrorCode(key),
    };
  }

  /// Search for keys containing a term
  static List<String> searchKeys(String term) {
    final i18nKeys = getI18nKeys().where((key) => key.toLowerCase().contains(term.toLowerCase())).toList();
    final errorKeys = getErrorCodes().where((key) => key.toLowerCase().contains(term.toLowerCase())).toList();
    
    final allKeys = <String>{};
    allKeys.addAll(i18nKeys);
    allKeys.addAll(errorKeys);
    
    return allKeys.toList()..sort();
  }

  /// Get statistics
  static Map<String, dynamic> getStatistics() {
    final status = getStatus();
    final languages = getAllLanguages();
    
    return {
      'totalKeys': status['combined']['totalItems'],
      'i18nKeys': status['combined']['i18nKeysCount'],
      'errorCodes': status['combined']['errorCodesCount'],
      'languages': languages.length,
      'availableLanguages': languages,
      'initialized': _isInitialized,
    };
  }
}
