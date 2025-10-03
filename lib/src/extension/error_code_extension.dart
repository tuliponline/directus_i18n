part of directus_i18n;

/// Extension for easy error code usage
extension ErrorCodeExtension on String {
  /// Get error code from this string
  ErrorCode? get errorCode {
    return ErrorCodeService.getErrorCode(this);
  }

  /// Get localized error message
  String getErrorMessage({
    String? languageCode,
    Map<String, String>? parameters,
    String? fallback,
  }) {
    return ErrorCodeService.getLocalizedMessage(
      this,
      languageCode: languageCode,
      parameters: parameters,
      fallback: fallback,
    );
  }

  /// Get error title for this error code
  String? getErrorTitle({String? languageCode}) {
    final errorCode = ErrorCodeService.getErrorCode(this);
    return errorCode?.title;
  }

  /// Get error description for this error code
  String? getErrorDescription({String? languageCode}) {
    final errorCode = ErrorCodeService.getErrorCode(this);
    return errorCode?.description;
  }

  /// Check if this string is a valid error code
  bool get isErrorCode {
    return ErrorCodeService.hasErrorCode(this);
  }
}

/// Extension for ErrorCode class
extension ErrorCodeDisplayExtension on ErrorCode {
  /// Get display message with parameters
  String displayMessage({
    String? languageCode,
    Map<String, String>? parameters,
  }) {
    return getLocalizedMessage(
      languageCode: languageCode,
      parameters: parameters,
      fallback: message,
    );
  }

  /// Get formatted error for display
  String getFormattedError({
    String? languageCode,
    Map<String, String>? parameters,
    bool includeCode = true,
  }) {
    final buffer = StringBuffer();
    
    if (includeCode) {
      buffer.writeln('Code: $code');
    }
    
    final message = displayMessage(languageCode: languageCode, parameters: parameters);
    if (message.isNotEmpty) {
      buffer.writeln('Message: $message');
    }
    
    return buffer.toString().trim();
  }
}

/// Extension for BuildContext to make error code usage easier
extension ErrorCodeContextExtension on BuildContext {
  /// Get current language code from context
  String? get currentLanguageCode {
    final locale = Localizations.of(this, Localizations);
    return locale?.languageCode;
  }

  /// Get localized error message with current language
  String getErrorMessage(
    String errorCode, {
    Map<String, String>? parameters,
    String? fallback,
  }) {
    return ErrorCodeService.getLocalizedMessage(
      errorCode,
      languageCode: currentLanguageCode,
      parameters: parameters,
      fallback: fallback,
    );
  }

  /// Get error title with current language
  String? getErrorTitle(String errorCode) {
    final error = ErrorCodeService.getErrorCode(errorCode);
    return error?.title;
  }

  /// Get error description with current language
  String? getErrorDescription(String errorCode) {
    final error = ErrorCodeService.getErrorCode(errorCode);
    return error?.description;
  }
}

/// Extension for Exception to add error code support
extension ExceptionErrorCodeExtension on Exception {
  /// Get error code from exception message
  String? get errorCode {
    final message = toString();
    // Try to extract error code from common patterns
    final patterns = [
      RegExp(r'Error Code: (\w+)'),
      RegExp(r'Code: (\w+)'),
      RegExp(r'ERROR_(\w+)'),
      RegExp(r'(\w+)_ERROR'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        return match.group(1);
      }
    }

    return null;
  }

  /// Get localized error message
  String getLocalizedErrorMessage({
    String? languageCode,
    Map<String, String>? parameters,
    String? fallback,
  }) {
    final code = errorCode;
    if (code != null) {
      return ErrorCodeService.getLocalizedMessage(
        code,
        languageCode: languageCode,
        parameters: parameters,
        fallback: fallback,
      );
    }

    return fallback ?? toString();
  }
}
