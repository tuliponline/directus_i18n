part of directus_i18n;

/// Main service class for DirectusI18n
class DirectusI18nService {
  static DirectusI18nConfig? _config;
  static final Logger _logger = Logger();

  /// Get current configuration
  static DirectusI18nConfig get config {
    if (_config == null) {
      throw StateError(
        'DirectusI18nService not initialized. Call DirectusI18nService.init() first.',
      );
    }
    return _config!;
  }

  /// Initialize the DirectusI18n service
  /// 
  /// This will register the repository with GetIt for dependency injection.
  /// 
  /// Example:
  /// ```dart
  /// DirectusI18nService.init(
  ///   baseUrl: 'https://your-directus.com',
  ///   accessToken: 'your-token',
  ///   collectionName: 'app_contents',
  /// );
  /// ```
  static void init({
    required String baseUrl,
    required String accessToken,
    String collectionName = 'app_contents',
    bool isProduction = true,
    bool cacheEnabled = true,
    void Function(Object error, StackTrace? stackTrace)? onError,
    Dio? httpClient,
    Future<Map<String, String>> Function()? platformChannelGetter,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    _config = DirectusI18nConfig(
      baseUrl: baseUrl,
      accessToken: accessToken,
      collectionName: collectionName,
      isProduction: isProduction,
      cacheEnabled: cacheEnabled,
      onError: onError,
      httpClient: httpClient,
      platformChannelGetter: platformChannelGetter,
      navigatorKey: navigatorKey,
    );

    // Register repository with GetIt
    if (!GetIt.I.isRegistered<DirectusI18nRepository>()) {
      GetIt.I.registerLazySingleton<DirectusI18nRepository>(
        () => DirectusI18nRepository(config: _config!),
      );
    }

    _logger.i('DirectusI18nService initialized with baseUrl: $baseUrl');
  }

  /// Update configuration after initialization
  static void updateConfig(DirectusI18nConfig newConfig) {
    _config = newConfig;
    
    // Re-register repository with new config
    if (GetIt.I.isRegistered<DirectusI18nRepository>()) {
      GetIt.I.unregister<DirectusI18nRepository>();
    }
    
    GetIt.I.registerLazySingleton<DirectusI18nRepository>(
      () => DirectusI18nRepository(config: newConfig),
    );
    
    _logger.i('DirectusI18nService configuration updated');
  }

  /// Reset the service (useful for testing)
  static void reset() {
    if (GetIt.I.isRegistered<DirectusI18nRepository>()) {
      GetIt.I.unregister<DirectusI18nRepository>();
    }
    _config = null;
    _logger.i('DirectusI18nService reset');
  }
}

