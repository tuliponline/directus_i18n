import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  group('Directus Tests Without Access Token', () {
    test('should test ErrorCode model without Directus connection', () {
      // ทดสอบ ErrorCode model โดยไม่ต้องเชื่อมต่อ Directus
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
      expect(errorCode.severity, ErrorSeverity.error);
      expect(errorCode.category, 'communication');
      expect(errorCode.title, 'Communication Error');
      expect(errorCode.description, 'A communication error has occurred');
      expect(errorCode.actionText, 'Retry');
      
      // Test translations
      expect(errorCode.getLocalizedMessage(languageCode: 'en-US'), 'Communication error occurred');
      expect(errorCode.getLocalizedMessage(languageCode: 'th-TH'), 'เกิดข้อผิดพลาดในการสื่อสาร');
      
      print('✅ ErrorCode model works without Directus connection');
      print('Code: ${errorCode.code}');
      print('English: ${errorCode.getLocalizedMessage(languageCode: 'en-US')}');
      print('Thai: ${errorCode.getLocalizedMessage(languageCode: 'th-TH')}');
    });

    test('should test ErrorCode from mock Directus data', () {
      // ทดสอบการสร้าง ErrorCode จาก mock Directus data
      final mockDirectusData = {
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

      final errorCode = ErrorCode.fromDirectus(mockDirectusData);

      expect(errorCode.code, 'COM10003');
      expect(errorCode.severity, ErrorSeverity.error);
      expect(errorCode.category, 'communication');
      expect(errorCode.title, 'Communication Error');
      expect(errorCode.description, 'A communication error has occurred');
      expect(errorCode.actionText, 'Retry');
      expect(errorCode.translations, isNotNull);
      expect(errorCode.translations!['en-US'], 'Communication error occurred');
      expect(errorCode.translations!['th-TH'], 'เกิดข้อผิดพลาดในการสื่อสาร');
      
      print('✅ ErrorCode from Directus data works correctly');
      print('Available Languages: ${errorCode.getAvailableLanguages().join(', ')}');
    });

    test('should test parameter substitution', () {
      final errorCode = ErrorCode(
        code: 'COM10003',
        translations: {
          'en-US': 'Communication error occurred at {timestamp}',
          'th-TH': 'เกิดข้อผิดพลาดในการสื่อสารเมื่อ {timestamp}'
        },
      );

      final parameters = {'timestamp': '2024-01-15 10:30:00'};
      
      final enMessage = errorCode.getLocalizedMessage(
        languageCode: 'en-US',
        parameters: parameters
      );
      
      final thMessage = errorCode.getLocalizedMessage(
        languageCode: 'th-TH',
        parameters: parameters
      );
      
      expect(enMessage, 'Communication error occurred at 2024-01-15 10:30:00');
      expect(thMessage, 'เกิดข้อผิดพลาดในการสื่อสารเมื่อ 2024-01-15 10:30:00');
      
      print('✅ Parameter substitution works correctly');
      print('English: $enMessage');
      print('Thai: $thMessage');
    });

    test('should test multiple error codes', () {
      final errorCodes = [
        ErrorCode(
          code: 'COM10003',
          severity: ErrorSeverity.error,
          category: 'communication',
          translations: {
            'en-US': 'Communication error occurred',
            'th-TH': 'เกิดข้อผิดพลาดในการสื่อสาร'
          },
        ),
        ErrorCode(
          code: 'LOGIN_FAILED',
          severity: ErrorSeverity.warning,
          category: 'authentication',
          translations: {
            'en-US': 'Login failed',
            'th-TH': 'การเข้าสู่ระบบล้มเหลว'
          },
        ),
        ErrorCode(
          code: 'VALIDATION_ERROR',
          severity: ErrorSeverity.info,
          category: 'validation',
          translations: {
            'en-US': 'Validation error',
            'th-TH': 'ข้อผิดพลาดในการตรวจสอบ'
          },
        ),
      ];

      expect(errorCodes.length, 3);
      
      for (final errorCode in errorCodes) {
        expect(errorCode.code, isNotEmpty);
        expect(errorCode.severity, isNotNull);
        expect(errorCode.category, isNotEmpty);
        expect(errorCode.translations, isNotNull);
        
        print('✅ Error Code: ${errorCode.code}');
        print('  Severity: ${errorCode.severity?.name}');
        print('  Category: ${errorCode.category}');
        print('  Thai Message: ${errorCode.getLocalizedMessage(languageCode: 'th-TH')}');
      }
    });

    test('should test ErrorSeverity enum', () {
      expect(ErrorSeverity.info.name, 'info');
      expect(ErrorSeverity.warning.name, 'warning');
      expect(ErrorSeverity.error.name, 'error');
      expect(ErrorSeverity.critical.name, 'critical');
      
      final severities = ErrorSeverity.values;
      expect(severities.length, 4);
      
      print('✅ ErrorSeverity enum works correctly');
      for (final severity in severities) {
        print('  - ${severity.name}');
      }
    });

    test('should test map conversion', () {
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
      expect(map['severity'], 'error');
      expect(map['category'], 'communication');
      expect(map['title'], 'Communication Error');
      expect(map['description'], 'A communication error has occurred');
      expect(map['actionText'], 'Retry');
      expect(map['translations'], isA<Map<String, String>>());
      
      print('✅ Map conversion works correctly');
      print('Map keys: ${map.keys.join(', ')}');
    });

    test('should simulate real-world usage', () {
      // Simulate how the package would be used in a real app
      
      // 1. Create error codes (normally loaded from Directus)
      final errorCodes = {
        'COM10003': ErrorCode(
          code: 'COM10003',
          severity: ErrorSeverity.error,
          category: 'communication',
          translations: {
            'en-US': 'Communication error occurred',
            'th-TH': 'เกิดข้อผิดพลาดในการสื่อสาร'
          },
        ),
        'LOGIN_FAILED': ErrorCode(
          code: 'LOGIN_FAILED',
          severity: ErrorSeverity.warning,
          category: 'authentication',
          translations: {
            'en-US': 'Login failed',
            'th-TH': 'การเข้าสู่ระบบล้มเหลว'
          },
        ),
      };

      // 2. Simulate error handling
      void handleError(String errorCode, String languageCode) {
        final error = errorCodes[errorCode];
        if (error != null) {
          final message = error.getLocalizedMessage(languageCode: languageCode);
          print('Error: $message');
          expect(message, isNotEmpty);
        }
      }

      // 3. Test error handling
      handleError('COM10003', 'th-TH');
      handleError('LOGIN_FAILED', 'en-US');
      
      print('✅ Real-world usage simulation works correctly');
    });
  });
}
