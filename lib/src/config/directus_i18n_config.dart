part of directus_i18n;

/// Configuration for DirectusI18n package
class DirectusI18nConfig {
  /// Base URL of your Directus instance
  final String baseUrl;

  /// Access token for Directus API
  final String accessToken;

  /// Collection name in Directus (default: 'contents')
  final String collectionName;

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
    this.collectionName = 'contents',
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
      isProduction: isProduction ?? this.isProduction,
      cacheEnabled: cacheEnabled ?? this.cacheEnabled,
      onError: onError ?? this.onError,
      httpClient: httpClient ?? this.httpClient,
      platformChannelGetter: platformChannelGetter ?? this.platformChannelGetter,
      navigatorKey: navigatorKey ?? this.navigatorKey,
    );
  }
}

