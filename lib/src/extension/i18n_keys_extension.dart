part of directus_i18n;

/// Additional extensions for I18nKey
/// (Main translation extension is in i18n_keys.dart)

extension I18nKeyHelpers on I18nKey {
  /// Check if this key has a translation in the current locale
  bool hasTranslation(BuildContext context) {
    try {
      final translation = FlutterI18n.translate(context, key);
      return translation != key && translation.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get the raw translation without parameter substitution
  String? getRawTranslation(BuildContext context) {
    try {
      return FlutterI18n.translate(context, key);
    } catch (e) {
      return null;
    }
  }

  /// Translate with plural support
  String plural(
    BuildContext context,
    int count, {
    String? zero,
    String? one,
    String? other,
  }) {
    if (count == 0 && zero != null) return zero;
    if (count == 1 && one != null) return one;
    return other ?? translate(context: context);
  }
}

