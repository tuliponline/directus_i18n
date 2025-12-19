part of directus_i18n;

/// Configuration for DirectusI18n package
class DirectusI18nConfig {
  /// Base URL of your Directus instance
  final String baseUrl;

  /// Access token for Directus API
  final String accessToken;

  /// Collection name in Directus (default: 'app_content')
  /// For new structure, this should be 'app_content'
  final String collectionName;
  
  /// Page prefix for filtering app_content by page relation
  /// This corresponds to the 'key' field in app_page collection
  final String? pagePrefix;

  /// Whether the app is in production mode
  /// In non-production, draft values will be used if available
  final bool isProduction;

  /// Whether to enable caching
  final bool cacheEnabled;

  /// Optional error handler
  final void Function(Object error, StackTrace? stackTrace)? onError;

  /// Optional custom Dio client
  final Dio? httpClient;

  /// Optional platform channel getter for native integration
  /// Returns Map<String, String> of translations
  final Future<Map<String, String>> Function()? platformChannelGetter;

  /// Global navigator key for accessing context without passing it
  /// If not provided, context must be passed explicitly to translate()
  final GlobalKey<NavigatorState>? navigatorKey;

  const DirectusI18nConfig({
    required this.baseUrl,
    required this.accessToken,
    this.collectionName = 'app_content',
    this.pagePrefix,
    this.isProduction = true,
    this.cacheEnabled = true,
    this.onError,
    this.httpClient,
    this.platformChannelGetter,
    this.navigatorKey,
  });

  DirectusI18nConfig copyWith({
    String? baseUrl,
    String? accessToken,
    String? collectionName,
    String? pagePrefix,
    bool? isProduction,
    bool? cacheEnabled,
    void Function(Object error, StackTrace? stackTrace)? onError,
    Dio? httpClient,
    Future<Map<String, String>> Function()? platformChannelGetter,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    return DirectusI18nConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      accessToken: accessToken ?? this.accessToken,
      collectionName: collectionName ?? this.collectionName,
      pagePrefix: pagePrefix ?? this.pagePrefix,
      isProduction: isProduction ?? this.isProduction,
      cacheEnabled: cacheEnabled ?? this.cacheEnabled,
      onError: onError ?? this.onError,
      httpClient: httpClient ?? this.httpClient,
      platformChannelGetter: platformChannelGetter ?? this.platformChannelGetter,
      navigatorKey: navigatorKey ?? this.navigatorKey,
    );
  }
}

/// Configuration for fetching translations from multiple Directus collections.
/// Use prefix to prevent key collisions across collections.
class DirectusCollectionConfig {
  final String name;
  final String prefix;
  /// Page prefix for filtering app_content by page relation
  /// This corresponds to the 'key' field in app_page collection
  final String? pagePrefix;

  const DirectusCollectionConfig({
    required this.name,
    this.prefix = '',
    this.pagePrefix,
  });

  /// Apply prefix to an incoming key (no-op if prefix is empty).
  String applyPrefix(String key) => prefix.isEmpty ? key : '$prefix$key';
}

