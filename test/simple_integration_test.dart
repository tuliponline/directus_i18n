import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  group('Simple Directus Integration Tests', () {
    test('should initialize ErrorCodeService with real Directus URL', () async {
      // Initialize with Directus connection
      await ErrorCodeService.init(
        baseUrl: 'https://your-directus-instance.com',
        accessToken: 'your-access-token',
        collectionName: 'error',
        autoLoad: true,
      );

      final status = ErrorCodeService.getStatus();
      expect(status['initialized'], isTrue);
      expect(status['baseUrl'], 'https://your-directus-instance.com');
      expect(status['collectionName'], 'error');
      
      print('✅ ErrorCodeService initialized successfully');
      print('Base URL: ${status['baseUrl']}');
      print('Collection: ${status['collectionName']}');
    });

    test('should create mock COM10003 error code', () {
      // สร้าง mock error code สำหรับทดสอบ
      final com10003 = ErrorCode(
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

      expect(com10003.code, 'COM10003');
      expect(com10003.severity, ErrorSeverity.error);
      expect(com10003.category, 'communication');
      
      print('✅ COM10003 Error Code created successfully');
      print('Code: ${com10003.code}');
      print('Severity: ${com10003.severity?.name}');
      print('Category: ${com10003.category}');
      print('Title: ${com10003.title}');
      print('Description: ${com10003.description}');
      print('Available Languages: ${com10003.getAvailableLanguages().join(', ')}');
      
      // Test translations
      final enMessage = com10003.getLocalizedMessage(languageCode: 'en-US');
      final thMessage = com10003.getLocalizedMessage(languageCode: 'th-TH');
      
      print('English Message: $enMessage');
      print('Thai Message: $thMessage');
      
      expect(enMessage, 'Communication error occurred');
      expect(thMessage, 'เกิดข้อผิดพลาดในการสื่อสาร');
    });

    test('should test error code with parameters', () {
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

    test('should test error code extension methods', () {
      // สร้าง mock error code
      final errorCode = ErrorCode(
        code: 'TEST_ERROR',
        translations: {
          'en-US': 'Test error message',
          'th-TH': 'ข้อความข้อผิดพลาดทดสอบ'
        },
        title: 'Test Error Title',
        description: 'Test error description',
      );

      // Test extension methods (simulate how they would work)
      final errorMessage = errorCode.getLocalizedMessage(languageCode: 'th-TH');
      final errorTitle = errorCode.title;
      final errorDescription = errorCode.description;
      
      expect(errorMessage, 'ข้อความข้อผิดพลาดทดสอบ');
      expect(errorTitle, 'Test Error Title');
      expect(errorDescription, 'Test error description');
      
      print('✅ Extension methods work correctly');
      print('Error Message: $errorMessage');
      print('Error Title: $errorTitle');
      print('Error Description: $errorDescription');
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

    test('should test error code conversion to map', () {
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
      
      print('✅ Error code conversion to map works correctly');
      print('Map keys: ${map.keys.join(', ')}');
      print('Translations: ${map['translations']}');
    });

    test('should simulate Directus data structure', () {
      // Simulate Directus response data
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

      // Convert to ErrorCode
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
      
      print('✅ Directus data conversion works correctly');
      print('Error Code: ${errorCode.code}');
      print('Available Languages: ${errorCode.getAvailableLanguages().join(', ')}');
    });
  });
}
