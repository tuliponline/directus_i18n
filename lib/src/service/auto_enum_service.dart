part of directus_i18n;

/// Auto Enum Service that automatically generates and manages enum files
/// This service runs at app startup and generates enum files in the codebase
class AutoEnumService {
  static final Logger _logger = Logger();
  static bool _isInitialized = false;
  static bool _isGenerating = false;
  
  /// Initialize auto enum service
  static Future<void> init({
    required String baseUrl,
    required String accessToken,
    String collectionName = 'app_contents',
    String enumName = 'AutoI18nKeys',
    bool autoGenerate = true,
    Duration? checkInterval,
  }) async {
    if (_isInitialized) return;
    
    _logger.i('🚀 Initializing AutoEnumService...');
    
    if (autoGenerate) {
      await generateEnumIfNeeded(
        baseUrl: baseUrl,
        accessToken: accessToken,
        collectionName: collectionName,
        enumName: enumName,
      );
    }
    
    _isInitialized = true;
    _logger.i('✅ AutoEnumService initialized');
  }
  
  /// Generate enum if needed (check for updates)
  static Future<void> generateEnumIfNeeded({
    required String baseUrl,
    required String accessToken,
    String collectionName = 'app_contents',
    String enumName = 'AutoI18nKeys',
  }) async {
    if (_isGenerating) return;
    
    try {
      _isGenerating = true;
      
      // Check if we need to generate/update enum
      final shouldGenerate = await _shouldGenerateEnum(baseUrl, accessToken, collectionName);
      
      if (shouldGenerate) {
        _logger.i('🔄 Generating updated enum...');
        await RuntimeEnumGenerator.generateAndStore(
          baseUrl: baseUrl,
          accessToken: accessToken,
          collectionName: collectionName,
          enumName: enumName,
        );
        
        // Reload the generated enum
        await _reloadGeneratedEnum();
      } else {
        _logger.i('✅ Enum is up to date, no generation needed');
      }
      
    } catch (e) {
      _logger.e('❌ Failed to generate enum: $e');
      // Don't rethrow - app should still work with existing enum
    } finally {
      _isGenerating = false;
    }
  }
  
  /// Check if enum should be generated/updated
  static Future<bool> _shouldGenerateEnum(
    String baseUrl,
    String accessToken,
    String collectionName,
  ) async {
    // If no generated enum exists, generate it
    if (!RuntimeEnumGenerator.hasGeneratedEnum()) {
      _logger.i('No generated enum found, will generate');
      return true;
    }
    
    // Check if Directus has newer content
    try {
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      final response = await dio.get(
        '/items/$collectionName',
        queryParameters: {
          'access_token': accessToken,
          'fields': 'id,date_updated',
          'filter[status][_in]': 'published,draft',
          'sort': '-date_updated',
          'limit': '1',
        },
      );
      
      if (response.data['data'].isNotEmpty) {
        final lastUpdate = DateTime.parse(response.data['data'][0]['date_updated']);
        final enumModTime = RuntimeEnumGenerator.getGeneratedEnumModificationTime();
        
        if (enumModTime == null || lastUpdate.isAfter(enumModTime)) {
          _logger.i('Directus has newer content, will regenerate enum');
          return true;
        }
      }
    } catch (e) {
      _logger.w('Could not check for updates: $e');
      // If we can't check, don't regenerate to avoid breaking the app
    }
    
    return false;
  }
  
  /// Reload the generated enum (hot reload)
  static Future<void> _reloadGeneratedEnum() async {
    try {
      // This would trigger a hot reload in development
      // In production, the enum will be available on next app start
      _logger.i('Enum generated, will be available on next app start');
    } catch (e) {
      _logger.e('Failed to reload enum: $e');
    }
  }
  
  /// Force regenerate enum
  static Future<void> forceRegenerate({
    required String baseUrl,
    required String accessToken,
    String collectionName = 'app_contents',
    String enumName = 'AutoI18nKeys',
  }) async {
    _logger.i('🔄 Force regenerating enum...');
    
    await RuntimeEnumGenerator.generateAndStore(
      baseUrl: baseUrl,
      accessToken: accessToken,
      collectionName: collectionName,
      enumName: enumName,
    );
    
    await _reloadGeneratedEnum();
  }
  
  /// Get generated enum file path
  static String getGeneratedEnumPath() {
    return RuntimeEnumGenerator.getGeneratedEnumPath();
  }
  
  /// Check if generated enum exists
  static bool hasGeneratedEnum() {
    return RuntimeEnumGenerator.hasGeneratedEnum();
  }
  
  /// Get enum file info
  static Map<String, dynamic> getEnumInfo() {
    final path = getGeneratedEnumPath();
    final file = File(path);
    
    return {
      'exists': file.existsSync(),
      'path': path,
      'lastModified': file.existsSync() ? file.lastModifiedSync() : null,
      'size': file.existsSync() ? file.lengthSync() : 0,
    };
  }
  
  /// Clean up generated files
  static Future<void> cleanup() async {
    await RuntimeEnumGenerator.deleteGeneratedEnum();
    _isInitialized = false;
    _logger.i('AutoEnumService cleaned up');
  }
}
