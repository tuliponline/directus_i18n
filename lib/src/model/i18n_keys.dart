part of directus_i18n;

/// Base class for translation keys
/// 
/// This will be extended by generated keys or you can create your own enum.
/// See the example or run the key generator script.
/// 
/// Example generated enum:
/// ```dart
/// enum I18nKeys {
///   key1('1', defaultFallbackKey: 'Hello'),
///   key2('2', defaultFallbackKey: 'World'),
///   ;
///   
///   const I18nKeys(this.key, {this.defaultFallbackKey});
///   final String key;
///   final String? defaultFallbackKey;
/// }
/// ```
abstract class I18nKey {
  /// The key identifier (usually the ID from Directus)
  String get key;

  /// Default fallback text when translation is not found
  String? get defaultFallbackKey;

  /// Whether to display the key instead of translated text (for debugging)
  static bool isDisplayContentKey = false;
}

/// Extension to add translate functionality to any I18nKey implementation
extension I18nKeyTranslation on I18nKey {
  /// Translate this key to the current locale
  /// 
  /// [context] - BuildContext for getting locale. If not provided, will use global navigator key
  /// [fallbackKey] - Custom fallback text (overrides defaultFallbackKey)
  /// [translationParams] - Parameters to substitute in the translation (e.g., {"name": "John"})
  /// 
  /// Example:
  /// ```dart
  /// Text(I18nKeys.welcome.translate(
  ///   context: context,
  ///   translationParams: {'name': userName},
  /// ))
  /// ```
  String translate({
    BuildContext? context,
    String? fallbackKey,
    Map<String, String>? translationParams,
  }) {
    // Debug mode: show key instead of translation
    if (I18nKey.isDisplayContentKey) {
      return key;
    }

    // Get context from parameter or global navigator key
    BuildContext? translationContext = context;
    if (translationContext == null) {
      final navigatorKey = DirectusI18nService.config.navigatorKey;
      if (navigatorKey?.currentContext != null) {
        translationContext = navigatorKey!.currentContext!;
      } else {
        Logger().e(
          'No BuildContext available for translation. '
          'Either pass context parameter or configure global navigatorKey.',
        );
        return fallbackKey ?? defaultFallbackKey ?? key;
      }
    }

    // Get translation from FlutterI18n
    var translation = FlutterI18n.translate(
      translationContext,
      key,
      fallbackKey: fallbackKey ?? defaultFallbackKey,
    );

    // Substitute parameters
    if (translationParams != null) {
      for (final paramKey in translationParams.keys) {
        translation = translation.replaceAll(
          '{$paramKey}',
          translationParams[paramKey]!,
        );
      }
    }

    return translation;
  }

  /// Translate without context (requires global navigator key to be configured)
  String tr([Map<String, String>? params]) {
    return translate(translationParams: params);
  }
}

/// Example I18nKeys enum
/// Replace this with your generated enum or create your own
enum I18nKeys implements I18nKey {
  empty('0', defaultFallbackKey: ''),
  example('example', defaultFallbackKey: 'Example text'),
  ;

  const I18nKeys(this.key, {this.defaultFallbackKey});

  @override
  final String key;

  @override
  final String? defaultFallbackKey;

  /// Get enum by key ID
  static I18nKeys? tryGetEnum({required String forId, String prefix = 'key'}) {
    try {
      return I18nKeys.values.byName('$prefix$forId');
    } catch (e) {
      return null;
    }
  }
}

