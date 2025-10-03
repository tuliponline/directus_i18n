import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Directus Integration Tests', () {
    setUpAll(() async {
      // Load environment variables
      await dotenv.load(fileName: ".env");
    });

    test('should initialize ErrorCodeService with real Directus', () async {
      final baseUrl = dotenv.env['DIRECTUS_BASE_URL'];
      final accessToken = dotenv.env['DIRECTUS_ACCESS_TOKEN'];

      if (baseUrl == null || accessToken == null) {
        fail('DIRECTUS_BASE_URL or DIRECTUS_ACCESS_TOKEN not found in .env file');
      }

      await ErrorCodeService.init(
        baseUrl: baseUrl,
        accessToken: accessToken,
        collectionName: 'error',
        autoLoad: true, // Load data from Directus
      );

      final status = ErrorCodeService.getStatus();
      expect(status['initialized'], isTrue);
      expect(status['baseUrl'], baseUrl);
      expect(status['collectionName'], 'error');
      
      print('✅ ErrorCodeService initialized successfully');
      print('Base URL: ${status['baseUrl']}');
      print('Collection: ${status['collectionName']}');
    });

    test('should load error codes from real Directus', () async {
      final baseUrl = dotenv.env['DIRECTUS_BASE_URL'];
      final accessToken = dotenv.env['DIRECTUS_ACCESS_TOKEN'];

      if (baseUrl == null || accessToken == null) {
        fail('DIRECTUS_BASE_URL or DIRECTUS_ACCESS_TOKEN not found in .env file');
      }

      await ErrorCodeService.init(
        baseUrl: baseUrl,
        accessToken: accessToken,
        collectionName: 'error',
        autoLoad: true,
      );

      // Get all error codes
      final errorCodes = await ErrorCodeService.getAllErrorCodes();
      
      expect(errorCodes, isA<List<ErrorCode>>());
      print('✅ Loaded ${errorCodes.length} error codes from Directus');
      
      // Print first few error codes
      for (int i = 0; i < errorCodes.length && i < 5; i++) {
        final errorCode = errorCodes[i];
        print('Error Code ${i + 1}: ${errorCode.code}');
        print('  Severity: ${errorCode.severity?.name ?? 'null'}');
        print('  Category: ${errorCode.category ?? 'null'}');
        print('  Available Languages: ${errorCode.getAvailableLanguages().join(', ')}');
        if (errorCode.translations != null) {
          print('  Sample Translation (EN): ${errorCode.getLocalizedMessage(languageCode: 'en-US')}');
          print('  Sample Translation (TH): ${errorCode.getLocalizedMessage(languageCode: 'th-TH')}');
        }
        print('');
      }
    });

    test('should find COM10003 error code from Directus', () async {
      final baseUrl = dotenv.env['DIRECTUS_BASE_URL'];
      final accessToken = dotenv.env['DIRECTUS_ACCESS_TOKEN'];

      if (baseUrl == null || accessToken == null) {
        fail('DIRECTUS_BASE_URL or DIRECTUS_ACCESS_TOKEN not found in .env file');
      }

      await ErrorCodeService.init(
        baseUrl: baseUrl,
        accessToken: accessToken,
        collectionName: 'error',
        autoLoad: true,
      );

      // Try to find COM10003
      final com10003 = ErrorCodeService.getErrorCode('COM10003');
      
      if (com10003 != null) {
        expect(com10003.code, 'COM10003');
        print('✅ Found COM10003 in Directus');
        print('Code: ${com10003.code}');
        print('Severity: ${com10003.severity?.name ?? 'null'}');
        print('Category: ${com10003.category ?? 'null'}');
        print('Title: ${com10003.title ?? 'null'}');
        print('Description: ${com10003.description ?? 'null'}');
        print('Action Text: ${com10003.actionText ?? 'null'}');
        print('Available Languages: ${com10003.getAvailableLanguages().join(', ')}');
        
        // Test translations
        final enMessage = com10003.getLocalizedMessage(languageCode: 'en-US');
        final thMessage = com10003.getLocalizedMessage(languageCode: 'th-TH');
        
        if (enMessage != null) {
          print('English Message: $enMessage');
        }
        if (thMessage != null) {
          print('Thai Message: $thMessage');
        }
      } else {
        print('⚠️ COM10003 not found in Directus');
        print('Available error codes:');
        final allCodes = await ErrorCodeService.getAllErrorCodes();
        for (final code in allCodes.take(10)) {
          print('  - ${code.code}');
        }
      }
    });

    test('should search error codes from Directus', () async {
      final baseUrl = dotenv.env['DIRECTUS_BASE_URL'];
      final accessToken = dotenv.env['DIRECTUS_ACCESS_TOKEN'];

      if (baseUrl == null || accessToken == null) {
        fail('DIRECTUS_BASE_URL or DIRECTUS_ACCESS_TOKEN not found in .env file');
      }

      await ErrorCodeService.init(
        baseUrl: baseUrl,
        accessToken: accessToken,
        collectionName: 'error',
        autoLoad: true,
      );

      // Search for communication errors
      final communicationErrors = ErrorCodeService.searchErrorCodes('COM');
      print('✅ Found ${communicationErrors.length} error codes matching "COM"');
      
      for (final errorCode in communicationErrors) {
        print('  - ${errorCode.code}: ${errorCode.getLocalizedMessage(languageCode: 'en-US')}');
      }

      // Search for login errors
      final loginErrors = ErrorCodeService.searchErrorCodes('LOGIN');
      print('✅ Found ${loginErrors.length} error codes matching "LOGIN"');
      
      for (final errorCode in loginErrors) {
        print('  - ${errorCode.code}: ${errorCode.getLocalizedMessage(languageCode: 'en-US')}');
      }
    });

    test('should test error code extension methods with real data', () async {
      final baseUrl = dotenv.env['DIRECTUS_BASE_URL'];
      final accessToken = dotenv.env['DIRECTUS_ACCESS_TOKEN'];

      if (baseUrl == null || accessToken == null) {
        fail('DIRECTUS_BASE_URL or DIRECTUS_ACCESS_TOKEN not found in .env file');
      }

      await ErrorCodeService.init(
        baseUrl: baseUrl,
        accessToken: accessToken,
        collectionName: 'error',
        autoLoad: true,
      );

      // Get all error codes
      final errorCodes = await ErrorCodeService.getAllErrorCodes();
      
      if (errorCodes.isNotEmpty) {
        final firstErrorCode = errorCodes.first;
        final errorCodeString = firstErrorCode.code;
        
        print('✅ Testing extension methods with: $errorCodeString');
        
        // Test extension methods
        final errorMessage = errorCodeString.getErrorMessage();
        final errorTitle = errorCodeString.getErrorTitle();
        final errorDescription = errorCodeString.getErrorDescription();
        
        print('Error Message: $errorMessage');
        print('Error Title: $errorTitle');
        print('Error Description: $errorDescription');
        
        // Test with specific language
        final thMessage = errorCodeString.getErrorMessage(languageCode: 'th-TH');
        print('Thai Message: $thMessage');
        
        expect(errorMessage, isNotNull);
      } else {
        print('⚠️ No error codes found in Directus');
      }
    });

    test('should verify Directus data structure', () async {
      final baseUrl = dotenv.env['DIRECTUS_BASE_URL'];
      final accessToken = dotenv.env['DIRECTUS_ACCESS_TOKEN'];

      if (baseUrl == null || accessToken == null) {
        fail('DIRECTUS_BASE_URL or DIRECTUS_ACCESS_TOKEN not found in .env file');
      }

      await ErrorCodeService.init(
        baseUrl: baseUrl,
        accessToken: accessToken,
        collectionName: 'error',
        autoLoad: true,
      );

      final errorCodes = await ErrorCodeService.getAllErrorCodes();
      
      if (errorCodes.isNotEmpty) {
        final sampleErrorCode = errorCodes.first;
        
        print('✅ Directus Data Structure Verification');
        print('Sample Error Code: ${sampleErrorCode.code}');
        print('Has Translations: ${sampleErrorCode.translations != null}');
        print('Translation Count: ${sampleErrorCode.translations?.length ?? 0}');
        print('Available Languages: ${sampleErrorCode.getAvailableLanguages().join(', ')}');
        
        // Verify structure
        expect(sampleErrorCode.code, isNotEmpty);
        
        // Check if translations exist
        if (sampleErrorCode.translations != null) {
          expect(sampleErrorCode.translations, isA<Map<String, String>>());
          
          // Check language codes
          for (final langCode in sampleErrorCode.getAvailableLanguages()) {
            expect(langCode, isNotEmpty);
            expect(langCode, contains('-'));
            print('  Language: $langCode -> ${sampleErrorCode.getLocalizedMessage(languageCode: langCode)}');
          }
        }
        
        print('✅ Data structure verification passed');
      } else {
        print('⚠️ No error codes found to verify structure');
      }
    });
  });
}
