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
  /// 
  /// Supports new Directus structure:
  /// - app_content collection with page relation
  /// - translations.value(en-US) and translations.value(th-TH)
  /// - status filtering (only published)
  Future<Map<String, String>> load(Locale locale, {String? pagePrefix}) async {
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

      // Map locale to Directus translation field format
      // en-US -> en-US, th-TH -> th-TH
      final localeString = locale.toString().replaceAll('_', '-');
      
      // Build query parameters for new app_content structure
      // Use translations.* to get the full translations array
      final queryParams = <String, dynamic>{
        'access_token': config.accessToken,
        'fields': 'key,page.id,page.key,translations.*,status',
        'filter[status][_eq]': 'published',
        'limit': '-1',
      };

      // Use pagePrefix from parameter or config
      final effectivePagePrefix = pagePrefix ?? config.pagePrefix;

      // Filter by page prefix if provided
      if (effectivePagePrefix != null && effectivePagePrefix.isNotEmpty) {
        // First, get the page ID from app_page collection
        final pageResponse = await _httpClient.get(
          '/items/app_page',
          queryParameters: {
            'access_token': config.accessToken,
            'fields': 'id,key',
            'filter[key][_eq]': effectivePagePrefix,
            'filter[status][_eq]': 'published',
            'limit': '1',
          },
        );

        if (pageResponse.data['data'] != null && 
            (pageResponse.data['data'] as List).isNotEmpty) {
          final pageId = pageResponse.data['data'][0]['id'];
          queryParams['filter[page][_eq]'] = pageId;
        } else {
          _logger.w('Page prefix "$effectivePagePrefix" not found in app_page');
          return {};
        }
      }

      // Fallback to HTTP request
      final response = await _httpClient.get(
        '/items/${config.collectionName}',
        queryParameters: queryParams,
      );

      final translations = <String, String>{};
      final data = (response.data?['data'] ?? []) as List<dynamic>;

      for (final item in data) {
        final itemMap = item as Map<String, dynamic>;
        final String key = itemMap['key']?.toString() ?? '';
        if (key.isEmpty) continue;

        // Get translation value from new structure
        // Structure: translations = [{languages_code: "en-US", value: "LoginNew"}, ...]
        final translationsObj = itemMap['translations'];
        String? value;
        
        if (translationsObj is List) {
          // New structure: translations array with languages_code and value
          for (final trans in translationsObj) {
            if (trans is Map<String, dynamic>) {
              final langCode = trans['languages_code']?.toString();
              final transValue = trans['value']?.toString();
              
              // Try exact locale match first
              if (langCode == localeString && transValue != null && transValue.isNotEmpty) {
                value = transValue;
                break;
              }
            }
          }
          
          // Fallback: try to find any value if exact locale not found
          if (value == null || value.isEmpty) {
            for (final trans in translationsObj) {
              if (trans is Map<String, dynamic>) {
                final transValue = trans['value']?.toString();
                if (transValue != null && transValue.isNotEmpty) {
                  value = transValue;
                  break;
                }
              }
            }
          }
        } else if (translationsObj is Map<String, dynamic>) {
          // Fallback: Support old Map structure (translations.value(en-US))
          value = translationsObj['value($localeString)']?.toString();
          
          // Fallback: try to find any value if exact locale not found
          if (value == null || value.isEmpty) {
            for (final entry in translationsObj.entries) {
              if (entry.key.startsWith('value(') && entry.value != null) {
                value = entry.value.toString();
                break;
              }
            }
          }
        }

        if (value != null && value.isNotEmpty) {
          translations[key] = value;
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
  /// 
  /// Supports both old structure (translations.message) and new structure (translations.value(en-US))
  Future<String> getTermsConditions() async {
    try {
      final localeString = _lastUpdatedLocale.toString().replaceAll('_', '-');
      
      // Try new structure first (translations.value(en-US))
      try {
        final response = await _httpClient.get(
          '/items/terms_conditions',
          queryParameters: {
            'access_token': config.accessToken,
            'fields': 'key,translations.value($localeString),translations.content,status',
            'filter[status][_eq]': 'published',
            'limit': '-1',
          },
        );

        final data = (response.data['data'] ?? []) as List<dynamic>;
        final matchingItems = data.where((element) => ((element['key'] ?? '') as String) == 'terms');
        if (matchingItems.isEmpty) {
          throw Exception('Terms item not found');
        }
        final item = matchingItems.first as Map<String, dynamic>;
        
        final translations = item['translations'] as Map<String, dynamic>?;
        if (translations != null) {
          // Try new structure: translations.value(en-US)
          final value = translations['value($localeString)']?.toString() ?? 
                       translations['value(en-US)']?.toString();
          if (value != null && value.isNotEmpty) {
            return value;
          }
          
          // Try content field
          final content = translations['content']?.toString();
          if (content != null && content.isNotEmpty) {
            return content;
          }
        }
      } catch (e) {
        _logger.d('New structure failed, trying old structure: $e');
      }
      
      // Fallback to old structure (translations.message)
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

      final oldData = (response.data?['data'] ?? []) as List<dynamic>;
      final oldItem = oldData.where((element) => ((element as Map<String, dynamic>)['key']?.toString() ?? '') == 'terms').first as Map<String, dynamic>;
      final oldTranslations = oldItem['translations'] as List<dynamic>;
      return (oldTranslations[0] as Map<String, dynamic>)['content'] as String;
    } catch (e, stackTrace) {
      _logger.e('Error loading terms and conditions', error: e, stackTrace: stackTrace);
      config.onError?.call(e, stackTrace);
      rethrow;
    }
  }

  /// Get content from a specific Directus collection
  /// 
  /// This is a generic method for fetching content from any collection
  /// Supports both old structure (translations.message) and new structure (translations.value(en-US))
  Future<List<String>> getCollectionContent({
    required String collectionName,
    String contentField = 'content',
  }) async {
    try {
      final localeString = _lastUpdatedLocale.toString().replaceAll('_', '-');
      
      // Try new structure first (translations.value(en-US))
      try {
        final response = await _httpClient.get(
          '/items/$collectionName',
          queryParameters: {
            'access_token': config.accessToken,
            'fields': 'key,translations.value($localeString),translations.$contentField,status',
            'filter[status][_eq]': 'published',
            'limit': '-1',
          },
        );

        final data = (response.data['data'] ?? []) as List<dynamic>;
        final result = <String>[];
        
        for (final item in data) {
          final itemMap = item as Map<String, dynamic>;
          final translations = itemMap['translations'] as Map<String, dynamic>?;
          if (translations != null) {
            // Try new structure: translations.value(en-US)
            String? value = translations['value($localeString)']?.toString() ?? 
                           translations['value(en-US)']?.toString();
            
            // Fallback to contentField
            if (value == null || value.isEmpty) {
              value = translations[contentField]?.toString();
            }
            
            if (value != null && value.isNotEmpty) {
              result.add(value);
            }
          }
        }
        
        if (result.isNotEmpty) {
          return result;
        }
      } catch (e) {
        _logger.d('New structure failed, trying old structure: $e');
      }
      
      // Fallback to old structure (translations.message)
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

      final oldData = (response.data?['data'] ?? []) as List<dynamic>;
      final oldResult = oldData
          .map((e) {
            final item = e as Map<String, dynamic>;
            final translations = item['translations'] as List<dynamic>;
            return (translations[0] as Map<String, dynamic>)[contentField] as String;
          })
          .toList();
      
      return List<String>.from(oldResult);
    } catch (e, stackTrace) {
      _logger.e('Error loading collection content', error: e, stackTrace: stackTrace);
      config.onError?.call(e, stackTrace);
      rethrow;
    }
  }
}

