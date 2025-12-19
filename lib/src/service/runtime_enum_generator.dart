part of directus_i18n;

/// Runtime Enum Generator that generates enum code and stores it in codebase
/// This allows adding new keys without releasing new app versions
class RuntimeEnumGenerator {
  static final Logger _logger = Logger();
  static const String _generatedDir = 'lib/generated';
  static const String _enumFileName = 'runtime_i18n_keys.dart';
  
  /// Generate enum at runtime and store in codebase
  /// 
  /// For new Directus structure, use collectionName: 'app_content'
  static Future<void> generateAndStore({
    required String baseUrl,
    required String accessToken,
    String collectionName = 'app_content',
    List<DirectusCollectionConfig>? collections,
    String enumName = 'RuntimeI18nKeys',
  }) async {
    try {
      _logger.i('🔄 Generating runtime enum from Directus...');
      final normalizedCollections =
          _normalizeCollections(collections, collectionName);
      
      // Create generated directory if it doesn't exist
      final generatedDir = Directory(_generatedDir);
      if (!await generatedDir.exists()) {
        await generatedDir.create(recursive: true);
      }
      
      final dio = Dio(BaseOptions(baseUrl: baseUrl));

      // Fetch data from Directus (multiple collections)
      // Supports new app_content structure
      final allItems = <Map<String, dynamic>>[];
      for (final collection in normalizedCollections) {
        try {
          // Build query for new app_content structure
          // Use translations.* to get the full translations array
          final queryParams = <String, dynamic>{
            'access_token': accessToken,
            'fields': 'key,translations.*,status',
            'filter[status][_eq]': 'published',
            'limit': '-1',
          };

          // Filter by page prefix if provided
          if (collection.pagePrefix != null && collection.pagePrefix!.isNotEmpty) {
            // Get page ID from app_page collection
            final pageResponse = await dio.get<Map<String, dynamic>>(
              '/items/app_page',
              queryParameters: {
                'access_token': accessToken,
                'fields': 'id,key',
                'filter[key][_eq]': collection.pagePrefix,
                'filter[status][_eq]': 'published',
                'limit': '1',
              },
            );

            if (pageResponse.data != null &&
                pageResponse.data!['data'] != null && 
                (pageResponse.data!['data'] as List).isNotEmpty) {
              final pageId = (pageResponse.data!['data'] as List)[0]['id'];
              queryParams['filter[page][_eq]'] = pageId;
            } else {
              _logger.w('Page prefix "${collection.pagePrefix}" not found in app_page');
              continue;
            }
          }

          final response = await dio.get<Map<String, dynamic>>(
            '/items/${collection.name}',
            queryParameters: queryParams,
          );
          final data = (response.data?['data'] ?? []) as List<dynamic>;
          for (final item in data) {
            final key = item['key']?.toString() ?? '';
            if (key.isEmpty) continue;
            
            // Build enum key with page prefix
            String enumKey;
            if (collection.pagePrefix != null && collection.pagePrefix!.isNotEmpty) {
              // Convert page prefix to uppercase and combine with key
              final pagePrefixUpper = collection.pagePrefix!.toUpperCase();
              enumKey = '${pagePrefixUpper}_$key';
            } else {
              // Use prefix if provided, otherwise use key as-is
              enumKey = collection.applyPrefix(key);
            }
            
            allItems.add({
              'key': collection.applyPrefix(key), // Keep original key for translation lookup
              'enumKey': enumKey, // Enum name with page prefix
              'translations': item['translations'],
            });
          }
        } catch (e) {
          _logger.w('Failed to fetch collection ${collection.name}: $e');
        }
      }

      // Generate enum content
      final buffer = StringBuffer();
      _generateEnumHeader(buffer, enumName);
      
      _logger.i('Found ${allItems.length} translation keys across ${normalizedCollections.length} collection(s)');
      
      // Generate enum cases
      // Handle new translations structure: translations array with languages_code and value
      for (var item in allItems) {
        final key = item['key'] as String; // Original key for translation lookup
        final enumKey = item['enumKey'] as String? ?? key; // Enum name (with page prefix if applicable)
        final translationsObj = item['translations'];
        String? value;
        
        if (translationsObj is List) {
          // New structure: translations array with languages_code and value
          // Try to get en-US first, then th-TH, then any available
          for (final trans in translationsObj) {
            if (trans is Map<String, dynamic>) {
              final langCode = trans['languages_code']?.toString();
              final transValue = trans['value']?.toString();
              
              if (langCode == 'en-US' && transValue != null && transValue.isNotEmpty) {
                value = transValue;
                break;
              }
            }
          }
          
          if (value == null || value.isEmpty) {
            for (final trans in translationsObj) {
              if (trans is Map<String, dynamic>) {
                final langCode = trans['languages_code']?.toString();
                final transValue = trans['value']?.toString();
                
                if (langCode == 'th-TH' && transValue != null && transValue.isNotEmpty) {
                  value = transValue;
                  break;
                }
              }
            }
          }
          
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
          final translations = translationsObj;
          if (translations.isNotEmpty) {
            // Try to get en-US first, then th-TH, then any available
            value = translations['value(en-US)']?.toString();
            if (value == null || value.isEmpty) {
              value = translations['value(th-TH)']?.toString();
            }
            if (value == null || value.isEmpty) {
              for (final entry in translations.entries) {
                if (entry.key.startsWith('value(') && entry.value != null) {
                  value = entry.value.toString();
                  break;
                }
              }
            }
          }
        }
        
        if (value != null && value.isNotEmpty) {
          final sanitizedValue = _sanitizeString(value);
          final sanitizedEnumKey = _sanitizeEnumName(enumKey);
          buffer.writeln("  $sanitizedEnumKey('$key', defaultFallbackKey: '$sanitizedValue'),");
        }
      }
      
      _generateEnumFooter(buffer, enumName);
      
      // Write to file
      final outputFile = File('$_generatedDir/$_enumFileName');
      await outputFile.writeAsString(buffer.toString());
      
      _logger.i('✅ Runtime enum generated at $_generatedDir/$_enumFileName');
      _logger.i('Total keys: ${allItems.length}');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to generate runtime enum', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Generate enum header
  static void _generateEnumHeader(StringBuffer buffer, String enumName) {
    buffer.writeln('/// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('/// Generated by RuntimeEnumGenerator at ${DateTime.now().toIso8601String()}');
    buffer.writeln('/// This file is generated at runtime and stored in codebase');
    buffer.writeln('///');
    buffer.writeln('/// To regenerate, call:');
    buffer.writeln('/// RuntimeEnumGenerator.generateAndStore()');
    buffer.writeln();
    buffer.writeln("import 'package:directus_i18n/directus_i18n.dart';");
    buffer.writeln();
    buffer.writeln('enum $enumName implements I18nKey {');
    buffer.writeln("  empty('0', defaultFallbackKey: ''),");
  }
  
  /// Generate enum footer
  static void _generateEnumFooter(StringBuffer buffer, String enumName) {
    buffer.writeln('''
  ;

  const $enumName(this.key, {this.defaultFallbackKey});

  @override
  final String key;

  @override
  final String? defaultFallbackKey;

  /// Get enum by key ID
  static $enumName getEnum({required String forId}) {
    return $enumName.values.byName("key\$forId");
  }

  /// Try to get enum by key ID, returns null if not found
  static $enumName? tryGetEnum({required String forId, String prefix = "key"}) {
    try {
      return $enumName.values.byName("\$prefix\$forId");
    } catch (e) {
      return null;
    }
  }

  /// Check if key exists in current enum
  static bool hasKey(String key) {
    return $enumName.values.any((e) => e.key == key);
  }

  /// Get all available keys
  static List<String> getAllKeys() {
    return $enumName.values.map((e) => e.key).toList();
  }
}
''');
  }
  
  /// Sanitize string for Dart code generation
  static String _sanitizeString(String input) {
    return input
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t')
        .replaceAll("'", "\\'")
        .replaceAll('\\"', '"')
        .replaceAll('\$', '\\\$');
  }
  
  /// Sanitize enum name for Dart code generation
  /// Converts to valid Dart identifier: uppercase, replace dots/underscores with underscores
  static String _sanitizeEnumName(String input) {
    // Convert to uppercase and replace dots/dashes with underscores
    String sanitized = input
        .toUpperCase()
        .replaceAll('.', '_')
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    
    // Remove leading numbers if any (Dart identifiers can't start with numbers)
    while (sanitized.isNotEmpty && sanitized[0].contains(RegExp(r'[0-9]'))) {
      sanitized = sanitized.substring(1);
    }
    
    // Ensure it starts with a letter or underscore
    if (sanitized.isEmpty || !sanitized[0].contains(RegExp(r'[A-Z_]'))) {
      sanitized = 'KEY_$sanitized';
    }
    
    // Remove any invalid characters (keep only letters, numbers, underscores)
    sanitized = sanitized.replaceAll(RegExp(r'[^A-Z0-9_]'), '_');
    
    // Remove consecutive underscores
    sanitized = sanitized.replaceAll(RegExp(r'_+'), '_');
    
    // Remove trailing underscores
    sanitized = sanitized.replaceAll(RegExp(r'_+$'), '');
    
    return sanitized.isEmpty ? 'KEY' : sanitized;
  }
  
  /// Check if generated enum exists
  static bool hasGeneratedEnum() {
    return File('$_generatedDir/$_enumFileName').existsSync();
  }
  
  /// Get generated enum file path
  static String getGeneratedEnumPath() {
    return '$_generatedDir/$_enumFileName';
  }
  
  /// Delete generated enum file
  static Future<void> deleteGeneratedEnum() async {
    final file = File('$_generatedDir/$_enumFileName');
    if (await file.exists()) {
      await file.delete();
      _logger.i('Deleted generated enum file');
    }
  }
  
  /// Get enum file modification time
  static DateTime? getGeneratedEnumModificationTime() {
    final file = File('$_generatedDir/$_enumFileName');
    if (file.existsSync()) {
      return file.lastModifiedSync();
    }
    return null;
  }

  static List<DirectusCollectionConfig> _normalizeCollections(
    List<DirectusCollectionConfig>? collections,
    String fallbackCollectionName,
  ) {
    if (collections != null && collections.isNotEmpty) return collections;
    return [DirectusCollectionConfig(name: fallbackCollectionName)];
  }
}
