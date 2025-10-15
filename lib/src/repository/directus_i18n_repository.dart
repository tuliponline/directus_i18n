part of directus_i18n;

/// Repository for loading translations from Directus CMS
class DirectusI18nRepository {
  final DirectusI18nConfig config;
  final Dio _httpClient;
  final Logger _logger = Logger();

  Locale _lastUpdatedLocale = const Locale('en', 'US');

  DirectusI18nRepository({required this.config})
      : _httpClient = config.httpClient ??
            Dio(BaseOptions(
              baseUrl: config.baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ));

  /// Get the last updated locale
  Locale get lastUpdatedLocale => _lastUpdatedLocale;

  /// Load translations for a specific locale
  /// 
  /// First tries to get from platform channel (if configured),
  /// then falls back to HTTP request to Directus API.
  Future<Map<String, String>> load(Locale locale) async {
    _lastUpdatedLocale = locale;

    try {
      // Try platform channel first (for native integration)
      if (config.platformChannelGetter != null) {
        try {
          final response = await config.platformChannelGetter!();
          _logger.d('Loaded translations from platform channel');
          return response;
        } catch (e) {
          _logger.w('Platform channel failed, falling back to HTTP: $e');
        }
      }

      // Fallback to HTTP request
      final response = await _httpClient.get(
        '/items/${config.collectionName}',
        queryParameters: {
          'access_token': config.accessToken,
          'fields': 'key,translations.message',
          'deep[translations][_filter][language_code][_starts_with]':
              locale.languageCode,
          'deep[translations][_filter][message][_nnull]': 'true',
          'limit': '-1',
        },
      );

      final translations = <String, String>{};

      for (final item in response.data['data']) {
        final String key = item['key'].toString();
        if (item['translations'].length > 0) {
          final String? value = item['translations'][0]['message'];
          if (value != null) {
            translations[key] = value;
          }
        }
      }

      _logger.d('Loaded ${translations.length} translations from Directus');
      return translations;
    } on DioException catch (e, stackTrace) {
      _logger.e('Dio error loading translations', error: e, stackTrace: stackTrace);
      config.onError?.call(e, stackTrace);
      return {};
    } catch (e, stackTrace) {
      _logger.e('Error loading translations', error: e, stackTrace: stackTrace);
      config.onError?.call(e, stackTrace);
      return {};
    }
  }

  /// Load translations with default locale (useful for scripts)
  Future<Map<String, String>> loadWithDefaults() async {
    return load(const Locale('en', 'US'));
  }

  /// Get terms and conditions content
  Future<String> getTermsConditions() async {
    try {
      final response = await _httpClient.get(
        '/items/terms_conditions',
        queryParameters: {
          'access_token': config.accessToken,
          'fields': 'key,translations.message,translations.content',
          'deep[translations][_filter][language_code][_starts_with]':
              _lastUpdatedLocale.languageCode,
          'deep[translations][content]': 'true',
          'limit': '-1',
        },
      );

      return ((response.data['data'] ?? []) as List)
          .where((element) => ((element['key'] ?? '') as String) == 'terms')
          .first['translations'][0]['content'];
    } catch (e, stackTrace) {
      _logger.e('Error loading terms and conditions', error: e, stackTrace: stackTrace);
      config.onError?.call(e, stackTrace);
      rethrow;
    }
  }

  /// Get content from a specific Directus collection
  /// 
  /// This is a generic method for fetching content from any collection
  Future<List<String>> getCollectionContent({
    required String collectionName,
    String contentField = 'content',
  }) async {
    try {
      final response = await _httpClient.get(
        '/items/$collectionName',
        queryParameters: {
          'access_token': config.accessToken,
          'fields': 'key,translations.message,translations.$contentField',
          'deep[translations][_filter][language_code][_starts_with]':
              _lastUpdatedLocale.languageCode,
          'deep[translations][$contentField]': 'true',
          'limit': '-1',
        },
      );

      final result = ((response.data['data'] ?? []) as List)
          .map((e) => e['translations'][0][contentField] as String)
          .toList();
      
      return List<String>.from(result);
    } catch (e, stackTrace) {
      _logger.e('Error loading collection content', error: e, stackTrace: stackTrace);
      config.onError?.call(e, stackTrace);
      rethrow;
    }
  }
}

