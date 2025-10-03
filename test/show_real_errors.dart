import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  group('Show Real Error Messages from Directus', () {
    test('should load and display real error codes from Directus', () async {
  // Initialize with Directus connection
  await ErrorCodeService.init(
    baseUrl: 'https://your-directus-instance.com',
    accessToken: 'your-access-token',
    collectionName: 'error',
    autoLoad: true,
  );

      print('\n🔗 Connected to Directus successfully!');
      print('Base URL: https://your-directus-instance.com');
      print('Collection: error\n');

      // Get all error codes from Directus
      final errorCodes = await ErrorCodeService.getAllErrorCodes();
      
      print('📊 Total Error Codes Loaded: ${errorCodes.length}\n');
      
      if (errorCodes.isEmpty) {
        print('⚠️ No error codes found in Directus collection "error"');
        return;
      }

      // Display each error code with details
      for (int i = 0; i < errorCodes.length; i++) {
        final errorCode = errorCodes[i];
        
        print('${'='*60}');
        print('📋 Error Code #${i + 1}');
        print('${'='*60}');
        print('🔑 Code: ${errorCode.code}');
        print('⚡ Severity: ${errorCode.severity?.name ?? 'Not set'}');
        print('📂 Category: ${errorCode.category ?? 'Not set'}');
        print('📝 Title: ${errorCode.title ?? 'Not set'}');
        print('📄 Description: ${errorCode.description ?? 'Not set'}');
        print('🎯 Action Text: ${errorCode.actionText ?? 'Not set'}');
        
        // Show available languages
        final languages = errorCode.getAvailableLanguages();
        print('🌐 Available Languages: ${languages.join(', ')}');
        
        // Show translations for each language
        if (languages.isNotEmpty) {
          print('\n📝 Translations:');
          for (final lang in languages) {
            final message = errorCode.getLocalizedMessage(languageCode: lang);
            print('  🇺🇸 $lang: $message');
          }
        } else {
          print('⚠️ No translations available');
        }
        
        print('\n🔍 Raw Data:');
        final map = errorCode.toMap();
        map.forEach((key, value) {
          if (value != null) {
            print('  $key: $value');
          }
        });
        
        print('\n');
      }

      // Test specific error code if COM10003 exists
      final com10003 = ErrorCodeService.getErrorCode('COM10003');
      if (com10003 != null) {
        print('${'='*60}');
        print('🎯 Testing COM10003 Specifically');
        print('${'='*60}');
        print('English: ${com10003.getLocalizedMessage(languageCode: 'en-US')}');
        print('Thai: ${com10003.getLocalizedMessage(languageCode: 'th-TH')}');
        print('Japanese: ${com10003.getLocalizedMessage(languageCode: 'ja-JP')}');
        print('Fallback (no lang): ${com10003.getLocalizedMessage()}');
      } else {
        print('⚠️ COM10003 not found in Directus');
      }

      // Show service status
      print('\n${'='*60}');
      print('📊 Service Status');
      print('${'='*60}');
      final status = ErrorCodeService.getStatus();
      status.forEach((key, value) {
        print('$key: $value');
      });

      expect(errorCodes, isNotEmpty);
    });

    test('should test error code extension methods with real data', () async {
      await ErrorCodeService.init(
        baseUrl: 'https://your-directus-instance.com',
        accessToken: 'your-access-token',
        collectionName: 'error',
        autoLoad: true,
      );

      final errorCodes = await ErrorCodeService.getAllErrorCodes();
      
      if (errorCodes.isNotEmpty) {
        final firstErrorCode = errorCodes.first;
        final errorCodeString = firstErrorCode.code;
        
        print('\n${'='*60}');
        print('🧪 Testing Extension Methods with Real Data');
        print('${'='*60}');
        print('Testing with error code: $errorCodeString');
        
        // Test extension methods (these would work in real app)
        print('\n📝 Extension Method Results:');
        print('getErrorMessage(): ${errorCodeString.getErrorMessage()}');
        print('getErrorTitle(): ${errorCodeString.getErrorTitle()}');
        print('getErrorDescription(): ${errorCodeString.getErrorDescription()}');
        
        print('\n🌐 With Language Codes:');
        print('getErrorMessage(th-TH): ${errorCodeString.getErrorMessage(languageCode: 'th-TH')}');
        print('getErrorMessage(en-US): ${errorCodeString.getErrorMessage(languageCode: 'en-US')}');
        
        expect(errorCodeString.getErrorMessage(), isNotNull);
      }
    });

    test('should search error codes from Directus', () async {
      await ErrorCodeService.init(
        baseUrl: 'https://your-directus-instance.com',
        accessToken: 'your-access-token',
        collectionName: 'error',
        autoLoad: true,
      );

      print('\n${'='*60}');
      print('🔍 Testing Search Functionality');
      print('${'='*60}');

      // Search for different terms
      final searchTerms = ['COM', 'LOGIN', 'ERROR', 'VALIDATION'];
      
      for (final term in searchTerms) {
        final results = ErrorCodeService.searchErrorCodes(term);
        print('\n🔎 Search for "$term": Found ${results.length} results');
        
        for (final errorCode in results) {
          print('  - ${errorCode.code}: ${errorCode.getLocalizedMessage(languageCode: 'en-US')}');
        }
      }
    });

    test('should test error handling workflow with real data', () async {
      await ErrorCodeService.init(
        baseUrl: 'https://your-directus-instance.com',
        accessToken: 'your-access-token',
        collectionName: 'error',
        autoLoad: true,
      );

      final errorCodes = await ErrorCodeService.getAllErrorCodes();
      
      if (errorCodes.isNotEmpty) {
        print('\n${'='*60}');
        print('🔄 Real-World Error Handling Workflow');
        print('${'='*60}');

        // Simulate error handling scenarios
        for (final errorCode in errorCodes.take(3)) { // Test first 3 error codes
          print('\n📋 Handling Error: ${errorCode.code}');
          
          // Scenario 1: Display error message
          final thMessage = errorCode.getLocalizedMessage(languageCode: 'th-TH');
          final enMessage = errorCode.getLocalizedMessage(languageCode: 'en-US');
          
          print('  🇹🇭 Thai Message: $thMessage');
          print('  🇺🇸 English Message: $enMessage');
          
          // Scenario 2: Show error details
          if (errorCode.severity != null) {
            print('  ⚡ Severity: ${errorCode.severity!.name}');
          }
          
          if (errorCode.category != null) {
            print('  📂 Category: ${errorCode.category}');
          }
          
          // Scenario 3: Error dialog simulation
          print('  🎯 Would show dialog:');
          print('    Title: ${errorCode.title ?? errorCode.code}');
          print('    Message: $thMessage');
          if (errorCode.actionText != null) {
            print('    Action Button: ${errorCode.actionText}');
          }
        }
      }
    });
  });
}
