part of directus_i18n;

/// Error severity levels
enum ErrorSeverity {
  info,
  warning,
  error,
  critical,
}

/// Simple Error Code model with code and multilingual message
class ErrorCode {
  final String code;
  final String? message;
  final Map<String, String>? translations;
  final ErrorSeverity? severity;
  final String? category;
  final String? title;
  final String? description;
  final String? actionText;

  const ErrorCode({
    required this.code,
    this.message,
    this.translations,
    this.severity,
    this.category,
    this.title,
    this.description,
    this.actionText,
  });

  /// Create ErrorCode from Directus data
  /// Supports structure: error(code, translations) -> error_translations(id, error_code, language_code, message) -> language(code, name)
  factory ErrorCode.fromDirectus(Map<String, dynamic> data) {
    // Extract translations from error_translations collection
    final translations = <String, String>{};
    final translationList = data['translations'] as List?;
    
    if (translationList != null) {
      for (final translation in translationList) {
        // Get language code from the relationship with language collection
        // Structure: error_translations.language_code -> language.code
        String? languageCode;
        final message = translation['message']?.toString();
        
        // Handle different possible structures
        if (translation['language_code'] != null) {
          final langCodeData = translation['language_code'];
          if (langCodeData is Map<String, dynamic>) {
            languageCode = langCodeData['code']?.toString();
          } else if (langCodeData is String) {
            languageCode = langCodeData;
          }
        }
        
        if (languageCode != null && message != null && message.isNotEmpty) {
          translations[languageCode] = message;
        }
      }
    }

    // Parse severity from string
    ErrorSeverity? severity;
    final severityString = data['severity']?.toString();
    if (severityString != null) {
      switch (severityString.toLowerCase()) {
        case 'info':
          severity = ErrorSeverity.info;
          break;
        case 'warning':
          severity = ErrorSeverity.warning;
          break;
        case 'error':
          severity = ErrorSeverity.error;
          break;
        case 'critical':
          severity = ErrorSeverity.critical;
          break;
      }
    }

    return ErrorCode(
      code: data['code']?.toString() ?? '',
      message: null, // No default message in error collection - use translations
      translations: translations.isNotEmpty ? translations : null,
      severity: severity,
      category: data['category']?.toString(),
      title: data['title']?.toString(),
      description: data['description']?.toString(),
      actionText: data['action_text']?.toString(),
    );
  }

  /// Convert to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'message': message,
      'translations': translations,
      'severity': severity?.name,
      'category': category,
      'title': title,
      'description': description,
      'actionText': actionText,
    };
  }

  /// Get localized message for specific language
  String getLocalizedMessage({
    String? languageCode,
    Map<String, String>? parameters,
    String? fallback,
  }) {
    String messageText = message ?? fallback ?? _getDefaultFallbackMessage(languageCode);
    
    // Try to get translation for specific language
    if (languageCode != null && translations != null && translations!.containsKey(languageCode)) {
      messageText = translations![languageCode]!;
    }
    
    // Apply parameter substitution
    if (parameters != null) {
      for (final paramKey in parameters.keys) {
        messageText = messageText.replaceAll(
          '{$paramKey}',
          parameters[paramKey]!,
        );
      }
    }
    
    return messageText;
  }

  /// Get default fallback message based on language
  String _getDefaultFallbackMessage(String? languageCode) {
    switch (languageCode) {
      case 'th-TH':
        return 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ ($code)';
      case 'en-US':
      case 'en':
        return 'An unknown error occurred. ($code)';
      default:
        return 'An unknown error occurred. ($code)';
    }
  }

  /// Get all available languages for this error code
  List<String> getAvailableLanguages() {
    return translations?.keys.toList() ?? [];
  }

  /// Check if translation exists for specific language
  bool hasTranslationFor(String languageCode) {
    return translations?.containsKey(languageCode) ?? false;
  }

  @override
  String toString() => 'ErrorCode(code: $code, message: $message, severity: $severity, category: $category)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorCode &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}
