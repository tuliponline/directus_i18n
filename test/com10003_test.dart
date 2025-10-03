import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  group('COM10003 Error Code Tests', () {
    test('should create COM10003 error code with properties', () {
      final errorCode = ErrorCode(
        code: 'COM10003',
        message: 'Communication error occurred',
        translations: {
          'en-US': 'Communication error occurred',
          'th-TH': 'เกิดข้อผิดพลาดในการสื่อสาร'
        },
        severity: ErrorSeverity.error,
        category: 'communication',
        title: 'Communication Error',
        description: 'A communication error has occurred',
        actionText: 'Retry',
      );

      expect(errorCode.code, 'COM10003');
      expect(errorCode.message, 'Communication error occurred');
      expect(errorCode.severity, ErrorSeverity.error);
      expect(errorCode.category, 'communication');
      expect(errorCode.title, 'Communication Error');
      expect(errorCode.description, 'A communication error has occurred');
      expect(errorCode.actionText, 'Retry');
      expect(errorCode.translations, isNotNull);
      expect(errorCode.translations!['en-US'], 'Communication error occurred');
      expect(errorCode.translations!['th-TH'], 'เกิดข้อผิดพลาดในการสื่อสาร');
    });

    test('should create COM10003 from Directus data', () {
      final directusData = {
        'code': 'COM10003',
        'severity': 'error',
        'category': 'communication',
        'title': 'Communication Error',
        'description': 'A communication error has occurred',
        'action_text': 'Retry',
        'translations': [
          {
            'language_code': {'code': 'en-US'},
            'message': 'Communication error occurred'
          },
          {
            'language_code': {'code': 'th-TH'},
            'message': 'เกิดข้อผิดพลาดในการสื่อสาร'
          }
        ]
      };

      final errorCode = ErrorCode.fromDirectus(directusData);

      expect(errorCode.code, 'COM10003');
      expect(errorCode.severity, ErrorSeverity.error);
      expect(errorCode.category, 'communication');
      expect(errorCode.title, 'Communication Error');
      expect(errorCode.description, 'A communication error has occurred');
      expect(errorCode.actionText, 'Retry');
      expect(errorCode.translations, isNotNull);
      expect(errorCode.translations!['en-US'], 'Communication error occurred');
      expect(errorCode.translations!['th-TH'], 'เกิดข้อผิดพลาดในการสื่อสาร');
    });

    test('should return localized messages for COM10003', () {
      final errorCode = ErrorCode(
        code: 'COM10003',
        translations: {
          'en-US': 'Communication error occurred',
          'th-TH': 'เกิดข้อผิดพลาดในการสื่อสาร',
          'ja-JP': '通信エラーが発生しました'
        },
      );

      // Test English
      expect(errorCode.getLocalizedMessage(languageCode: 'en-US'), 'Communication error occurred');
      
      // Test Thai
      expect(errorCode.getLocalizedMessage(languageCode: 'th-TH'), 'เกิดข้อผิดพลาดในการสื่อสาร');
      
      // Test Japanese
      expect(errorCode.getLocalizedMessage(languageCode: 'ja-JP'), '通信エラーが発生しました');
      
      // Test fallback when language not available
      expect(errorCode.getLocalizedMessage(languageCode: 'zh-CN'), 'COM10003');
      
      // Test without language code (should return code as fallback)
      expect(errorCode.getLocalizedMessage(), 'COM10003');
    });

    test('should return available languages for COM10003', () {
      final errorCode = ErrorCode(
        code: 'COM10003',
        translations: {
          'en-US': 'Communication error occurred',
          'th-TH': 'เกิดข้อผิดพลาดในการสื่อสาร',
          'ja-JP': '通信エラーが発生しました'
        },
      );

      final languages = errorCode.getAvailableLanguages();
      expect(languages.length, 3);
      expect(languages, contains('en-US'));
      expect(languages, contains('th-TH'));
      expect(languages, contains('ja-JP'));
    });

    test('should handle COM10003 with parameters', () {
      final errorCode = ErrorCode(
        code: 'COM10003',
        translations: {
          'en-US': 'Communication error occurred at {timestamp}',
          'th-TH': 'เกิดข้อผิดพลาดในการสื่อสารเมื่อ {timestamp}'
        },
      );

      final parameters = {'timestamp': '2024-01-15 10:30:00'};
      
      expect(
        errorCode.getLocalizedMessage(
          languageCode: 'en-US',
          parameters: parameters
        ),
        'Communication error occurred at 2024-01-15 10:30:00'
      );
      
      expect(
        errorCode.getLocalizedMessage(
          languageCode: 'th-TH',
          parameters: parameters
        ),
        'เกิดข้อผิดพลาดในการสื่อสารเมื่อ 2024-01-15 10:30:00'
      );
    });

    test('should convert COM10003 to map correctly', () {
      final errorCode = ErrorCode(
        code: 'COM10003',
        message: 'Communication error occurred',
        translations: {
          'en-US': 'Communication error occurred',
          'th-TH': 'เกิดข้อผิดพลาดในการสื่อสาร'
        },
        severity: ErrorSeverity.error,
        category: 'communication',
        title: 'Communication Error',
        description: 'A communication error has occurred',
        actionText: 'Retry',
      );

      final map = errorCode.toMap();

      expect(map['code'], 'COM10003');
      expect(map['message'], 'Communication error occurred');
      expect(map['translations'], {
        'en-US': 'Communication error occurred',
        'th-TH': 'เกิดข้อผิดพลาดในการสื่อสาร'
      });
      expect(map['severity'], 'error');
      expect(map['category'], 'communication');
      expect(map['title'], 'Communication Error');
      expect(map['description'], 'A communication error has occurred');
      expect(map['actionText'], 'Retry');
    });

    test('should handle COM10003 error severity correctly', () {
      final errorCode = ErrorCode(
        code: 'COM10003',
        severity: ErrorSeverity.error,
      );

      expect(errorCode.severity, ErrorSeverity.error);
      expect(errorCode.severity?.name, 'error');
    });

    test('should test COM10003 with extension methods', () {
      // Mock ErrorCodeService for testing extension methods
      // In real usage, this would be populated by ErrorCodeService
      
      final errorCode = ErrorCode(
        code: 'COM10003',
        translations: {
          'en-US': 'Communication error occurred',
          'th-TH': 'เกิดข้อผิดพลาดในการสื่อสาร'
        },
        title: 'Communication Error',
        description: 'A communication error has occurred',
      );

      // Test direct method calls (extension methods would work similarly)
      expect(errorCode.getLocalizedMessage(languageCode: 'en-US'), 'Communication error occurred');
      expect(errorCode.getLocalizedMessage(languageCode: 'th-TH'), 'เกิดข้อผิดพลาดในการสื่อสาร');
    });

    test('should test COM10003 error handling workflow', () {
      // Simulate a complete error handling workflow
      
      // 1. Create error code
      final errorCode = ErrorCode(
        code: 'COM10003',
        severity: ErrorSeverity.error,
        category: 'communication',
        title: 'Communication Error',
        description: 'A communication error has occurred',
        actionText: 'Retry',
        translations: {
          'en-US': 'Communication error occurred',
          'th-TH': 'เกิดข้อผิดพลาดในการสื่อสาร'
        },
      );

      // 2. Verify error properties
      expect(errorCode.code, 'COM10003');
      expect(errorCode.severity, ErrorSeverity.error);
      expect(errorCode.category, 'communication');

      // 3. Get localized message
      final message = errorCode.getLocalizedMessage(languageCode: 'th-TH');
      expect(message, 'เกิดข้อผิดพลาดในการสื่อสาร');

      // 4. Get error details
      expect(errorCode.title, 'Communication Error');
      expect(errorCode.description, 'A communication error has occurred');
      expect(errorCode.actionText, 'Retry');

      // 5. Check available languages
      final languages = errorCode.getAvailableLanguages();
      expect(languages, contains('en-US'));
      expect(languages, contains('th-TH'));

      // 6. Convert to map for serialization
      final map = errorCode.toMap();
      expect(map['code'], 'COM10003');
      expect(map['severity'], 'error');
    });
  });
}
