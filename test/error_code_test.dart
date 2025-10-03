import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  group('ErrorCode Model Tests', () {
    test('should create ErrorCode with all properties', () {
      final errorCode = ErrorCode(
        code: 'TEST_ERROR',
        message: 'Test error message',
        translations: {'en-US': 'Test error', 'th-TH': 'ข้อผิดพลาดทดสอบ'},
        severity: ErrorSeverity.error,
        category: 'test',
        title: 'Test Error Title',
        description: 'Test error description',
        actionText: 'Try Again',
      );

      expect(errorCode.code, 'TEST_ERROR');
      expect(errorCode.message, 'Test error message');
      expect(errorCode.severity, ErrorSeverity.error);
      expect(errorCode.category, 'test');
      expect(errorCode.title, 'Test Error Title');
      expect(errorCode.description, 'Test error description');
      expect(errorCode.actionText, 'Try Again');
      expect(errorCode.translations, isNotNull);
      expect(errorCode.translations!['en-US'], 'Test error');
      expect(errorCode.translations!['th-TH'], 'ข้อผิดพลาดทดสอบ');
    });

    test('should create ErrorCode from Directus data with translations', () {
      final directusData = {
        'code': 'LOGIN_FAILED',
        'severity': 'error',
        'category': 'authentication',
        'title': 'Login Failed',
        'description': 'Authentication failed',
        'action_text': 'Try Again',
        'translations': [
          {
            'language_code': {'code': 'en-US'},
            'message': 'Login failed. Please check your credentials.'
          },
          {
            'language_code': {'code': 'th-TH'},
            'message': 'การเข้าสู่ระบบล้มเหลว กรุณาตรวจสอบข้อมูล'
          }
        ]
      };

      final errorCode = ErrorCode.fromDirectus(directusData);

      expect(errorCode.code, 'LOGIN_FAILED');
      expect(errorCode.severity, ErrorSeverity.error);
      expect(errorCode.category, 'authentication');
      expect(errorCode.title, 'Login Failed');
      expect(errorCode.description, 'Authentication failed');
      expect(errorCode.actionText, 'Try Again');
      expect(errorCode.translations, isNotNull);
      expect(errorCode.translations!['en-US'], 'Login failed. Please check your credentials.');
      expect(errorCode.translations!['th-TH'], 'การเข้าสู่ระบบล้มเหลว กรุณาตรวจสอบข้อมูล');
    });

    test('should handle missing translations gracefully', () {
      final directusData = {
        'code': 'SIMPLE_ERROR',
        'translations': []
      };

      final errorCode = ErrorCode.fromDirectus(directusData);

      expect(errorCode.code, 'SIMPLE_ERROR');
      expect(errorCode.translations, isNull);
    });

    test('should parse severity correctly', () {
      final testCases = [
        {'severity': 'info', 'expected': ErrorSeverity.info},
        {'severity': 'warning', 'expected': ErrorSeverity.warning},
        {'severity': 'error', 'expected': ErrorSeverity.error},
        {'severity': 'critical', 'expected': ErrorSeverity.critical},
        {'severity': 'INFO', 'expected': ErrorSeverity.info}, // Test case insensitive
        {'severity': 'ERROR', 'expected': ErrorSeverity.error}, // Test case insensitive
      ];

      for (final testCase in testCases) {
        final data = {'code': 'TEST', 'severity': testCase['severity']};
        final errorCode = ErrorCode.fromDirectus(data);
        expect(errorCode.severity, testCase['expected']);
      }
    });

    test('should return localized message correctly', () {
      final errorCode = ErrorCode(
        code: 'TEST_ERROR',
        translations: {
          'en-US': 'Test error message',
          'th-TH': 'ข้อความข้อผิดพลาดทดสอบ'
        },
      );

      expect(errorCode.getLocalizedMessage(languageCode: 'en-US'), 'Test error message');
      expect(errorCode.getLocalizedMessage(languageCode: 'th-TH'), 'ข้อความข้อผิดพลาดทดสอบ');
      expect(errorCode.getLocalizedMessage(languageCode: 'ja-JP'), 'An unknown error occurred. (TEST_ERROR)'); // Returns fallback message
    });

    test('should return available languages', () {
      final errorCode = ErrorCode(
        code: 'TEST_ERROR',
        translations: {
          'en-US': 'Test error',
          'th-TH': 'ข้อผิดพลาดทดสอบ',
          'ja-JP': 'テストエラー'
        },
      );

      final languages = errorCode.getAvailableLanguages();
      expect(languages.length, 3);
      expect(languages, contains('en-US'));
      expect(languages, contains('th-TH'));
      expect(languages, contains('ja-JP'));
    });

    test('should convert to map correctly', () {
      final errorCode = ErrorCode(
        code: 'TEST_ERROR',
        message: 'Test message',
        translations: {'en-US': 'Test error'},
        severity: ErrorSeverity.warning,
        category: 'test',
        title: 'Test Title',
        description: 'Test Description',
        actionText: 'Test Action',
      );

      final map = errorCode.toMap();

      expect(map['code'], 'TEST_ERROR');
      expect(map['message'], 'Test message');
      expect(map['translations'], {'en-US': 'Test error'});
      expect(map['severity'], 'warning');
      expect(map['category'], 'test');
      expect(map['title'], 'Test Title');
      expect(map['description'], 'Test Description');
      expect(map['actionText'], 'Test Action');
    });
  });

  group('ErrorSeverity Enum Tests', () {
    test('should have correct enum values', () {
      expect(ErrorSeverity.info.name, 'info');
      expect(ErrorSeverity.warning.name, 'warning');
      expect(ErrorSeverity.error.name, 'error');
      expect(ErrorSeverity.critical.name, 'critical');
    });

    test('should have all expected severity levels', () {
      final severities = ErrorSeverity.values;
      expect(severities.length, 4);
      expect(severities, contains(ErrorSeverity.info));
      expect(severities, contains(ErrorSeverity.warning));
      expect(severities, contains(ErrorSeverity.error));
      expect(severities, contains(ErrorSeverity.critical));
    });
  });

  group('Error Code Extension Tests', () {
    test('should get error message from string extension', () {
      // Mock ErrorCodeService for testing
      final mockErrorCode = ErrorCode(
        code: 'TEST_ERROR',
        translations: {'en-US': 'Test error message'},
      );

      // Since we can't easily mock the service in unit tests,
      // we'll test the ErrorCode methods directly
      expect(mockErrorCode.getLocalizedMessage(languageCode: 'en-US'), 'Test error message');
    });

    test('should handle null translations gracefully', () {
      final errorCode = ErrorCode(code: 'NO_TRANSLATIONS');
      
      expect(errorCode.getLocalizedMessage(), 'An unknown error occurred. (NO_TRANSLATIONS)'); // Returns fallback message
      expect(errorCode.getAvailableLanguages(), isEmpty);
    });
  });

  group('ErrorCodeService Tests', () {
    test('should initialize correctly', () async {
      await ErrorCodeService.init(
        baseUrl: 'https://your-directus-instance.com',
        accessToken: 'test-token',
        collectionName: 'error',
        autoLoad: false, // Don't auto load for testing
      );

      final status = ErrorCodeService.getStatus();
      expect(status['initialized'], isTrue);
      expect(status['baseUrl'], 'https://your-directus-instance.com');
      expect(status['collectionName'], 'error');
    });

    test('should return correct status when initialized', () async {
      // Re-initialize to ensure fresh state
      await ErrorCodeService.init(
        baseUrl: 'https://your-directus-instance.com',
        accessToken: 'test-token',
        collectionName: 'error',
        autoLoad: false,
      );

      final status = ErrorCodeService.getStatus();
      expect(status['initialized'], isTrue);
      expect(status['errorCodesCount'], 0);
      expect(status['collectionName'], 'error');
      expect(status['baseUrl'], 'https://your-directus-instance.com');
    });
  });
}
