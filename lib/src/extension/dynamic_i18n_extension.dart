part of directus_i18n;

/// Extension for easy dynamic i18n usage
extension DynamicI18nExtension on String {
  /// Translate this string as an i18n key
  /// 
  /// Example:
  /// ```dart
  /// Text('welcome'.tr())
  /// Text('welcome'.tr(fallback: 'Welcome!'))
  /// Text('welcome_user'.tr(params: {'name': 'John'}))
  /// ```
  String tr({
    String? fallback,
    Map<String, String>? params,
    BuildContext? context,
  }) {
    return DynamicI18nService.translate(
      this,
      fallback: fallback,
      params: params,
      context: context,
    );
  }

  /// Check if this key exists in i18n
  bool get hasTranslation {
    return DynamicI18nService.hasKey(this);
  }

  /// Get fallback text for this key
  String? get fallbackText {
    return DynamicI18nService.getFallback(this);
  }
}

/// Extension for BuildContext to make i18n usage even easier
extension DynamicI18nContextExtension on BuildContext {
  /// Translate a key with this context
  String tr(String key, {
    String? fallback,
    Map<String, String>? params,
  }) {
    return DynamicI18nService.translate(
      key,
      fallback: fallback,
      params: params,
      context: this,
    );
  }
}
