part of directus_i18n;

/// Simple widget for displaying error codes with localized messages
class ErrorCodeWidget extends StatelessWidget {
  final String errorCode;
  final Map<String, String>? parameters;
  final String? languageCode;
  final String? fallback;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool showCode;

  const ErrorCodeWidget(
    this.errorCode, {
    Key? key,
    this.parameters,
    this.languageCode,
    this.fallback,
    this.textStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.showCode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorCodeObj = ErrorCodeService.getErrorCode(errorCode);
    final currentLanguage = languageCode ?? context.currentLanguageCode;

    if (errorCodeObj == null) {
      return Text(
        fallback ?? errorCode,
        style: textStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCode)
          Text(
            'Code: $errorCode',
            style: textStyle?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: (textStyle?.fontSize ?? 14) * 0.9,
            ),
            textAlign: textAlign,
          ),
        
        if (showCode) const SizedBox(height: 4),
        
        Text(
          errorCodeObj.displayMessage(
            languageCode: currentLanguage,
            parameters: parameters,
          ),
          style: textStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        ),
      ],
    );
  }
}

/// Widget for displaying error messages
class ErrorMessageWidget extends StatelessWidget {
  final String errorCode;
  final Map<String, String>? parameters;
  final String? languageCode;
  final String? fallback;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ErrorMessageWidget(
    this.errorCode, {
    Key? key,
    this.parameters,
    this.languageCode,
    this.fallback,
    this.textStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentLanguage = languageCode ?? context.currentLanguageCode;
    final message = ErrorCodeService.getLocalizedMessage(
      errorCode,
      languageCode: currentLanguage,
      parameters: parameters,
      fallback: fallback,
    );

    return Text(
      message,
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Widget for displaying error cards
class ErrorCardWidget extends StatelessWidget {
  final String errorCode;
  final Map<String, String>? parameters;
  final String? languageCode;
  final String? fallback;
  final bool showCode;

  const ErrorCardWidget(
    this.errorCode, {
    Key? key,
    this.parameters,
    this.languageCode,
    this.fallback,
    this.showCode = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorCodeObj = ErrorCodeService.getErrorCode(errorCode);
    final currentLanguage = languageCode ?? context.currentLanguageCode;

    if (errorCodeObj == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(fallback ?? errorCode),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  errorCode,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            
            if (showCode) const SizedBox(height: 8),
            
            Text(
              errorCodeObj.displayMessage(
                languageCode: currentLanguage,
                parameters: parameters,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying error list
class ErrorListWidget extends StatelessWidget {
  final List<String> errorCodes;
  final Map<String, Map<String, String>>? parameters;
  final String? languageCode;
  final bool showCode;
  final Widget Function(String errorCode, ErrorCode? errorCodeObj)? itemBuilder;

  const ErrorListWidget(
    this.errorCodes, {
    Key? key,
    this.parameters,
    this.languageCode,
    this.showCode = true,
    this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: errorCodes.map((errorCode) {
        final errorCodeObj = ErrorCodeService.getErrorCode(errorCode);
        final errorParameters = parameters?[errorCode];

        if (itemBuilder != null) {
          return itemBuilder!(errorCode, errorCodeObj);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ErrorCodeWidget(
            errorCode,
            parameters: errorParameters,
            languageCode: languageCode,
            showCode: showCode,
          ),
        );
      }).toList(),
    );
  }
}