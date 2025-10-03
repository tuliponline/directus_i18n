import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  group('Test Custom Fallback Messages', () {
    test('should use custom fallback messages for missing error codes', () async {
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

      print('${'='*60}');
      print('🧪 Testing Custom Fallback Messages');
      print('${'='*60}');

      // Test missing error codes with different languages
      final testCodes = ['COM10004', 'INVALID_CODE', 'MISSING_ERROR'];

      // Test COM10004 specifically for expectations
      final testCode = 'COM10004';
      
      // Test Thai fallback
      final thaiMessage = testCode.getErrorMessage(languageCode: 'th-TH');
      print('  🇹🇭 Thai (th-TH): $thaiMessage');
      
      // Test English fallback
      final englishMessage = testCode.getErrorMessage(languageCode: 'en-US');
      print('  🇺🇸 English (en-US): $englishMessage');
      
      // Test default fallback (no language specified)
      final defaultMessage = testCode.getErrorMessage();
      print('  🌐 Default: $defaultMessage');
      
      // Test with short language code
      final shortEnglishMessage = testCode.getErrorMessage(languageCode: 'en');
      print('  🇺🇸 English (en): $shortEnglishMessage');
      
      // Test with unknown language
      final unknownMessage = testCode.getErrorMessage(languageCode: 'fr-FR');
      print('  🇫🇷 French (fr-FR): $unknownMessage');

      for (final code in testCodes) {
        print('\n📋 Testing Code: $code');
        
        // Test Thai fallback
        final thaiMsg = code.getErrorMessage(languageCode: 'th-TH');
        print('  🇹🇭 Thai (th-TH): $thaiMsg');
        
        // Test English fallback
        final englishMsg = code.getErrorMessage(languageCode: 'en-US');
        print('  🇺🇸 English (en-US): $englishMsg');
        
        // Test default fallback (no language specified)
        final defaultMsg = code.getErrorMessage();
        print('  🌐 Default: $defaultMsg');
        
        // Test with short language code
        final shortEnglishMsg = code.getErrorMessage(languageCode: 'en');
        print('  🇺🇸 English (en): $shortEnglishMsg');
        
        // Test with unknown language
        final unknownMsg = code.getErrorMessage(languageCode: 'fr-FR');
        print('  🇫🇷 French (fr-FR): $unknownMsg');
        
        print('  ─────────────────────────────────────────');
      }

      // Test existing error code (should work normally)
      print('\n📋 Testing Existing Code: COM10003');
      final existingThai = 'COM10003'.getErrorMessage(languageCode: 'th-TH');
      final existingEnglish = 'COM10003'.getErrorMessage(languageCode: 'en-US');
      print('  🇹🇭 Thai (th-TH): $existingThai');
      print('  🇺🇸 English (en-US): $existingEnglish');

      // Test ErrorCodeService.getLocalizedMessage directly
      print('\n${'='*60}');
      print('🔧 Testing ErrorCodeService.getLocalizedMessage');
      print('${'='*60}');

      final serviceThai = ErrorCodeService.getLocalizedMessage('COM10004', languageCode: 'th-TH');
      final serviceEnglish = ErrorCodeService.getLocalizedMessage('COM10004', languageCode: 'en-US');
      final serviceDefault = ErrorCodeService.getLocalizedMessage('COM10004');
      
      print('📋 COM10004 via ErrorCodeService:');
      print('  🇹🇭 Thai: $serviceThai');
      print('  🇺🇸 English: $serviceEnglish');
      print('  🌐 Default: $serviceDefault');

      // Test with custom fallback parameter
      print('\n📋 Testing with Custom Fallback Parameter:');
      final customFallback = ErrorCodeService.getLocalizedMessage(
        'COM10004',
        languageCode: 'th-TH',
        fallback: 'ข้อความ fallback ที่กำหนดเอง',
      );
      print('  🎯 Custom Fallback: $customFallback');

      // Test ErrorCode model directly
      print('\n${'='*60}');
      print('📦 Testing ErrorCode Model Directly');
      print('${'='*60}');

      final errorCode = ErrorCode(
        code: 'TEST_CODE',
        message: null, // No message
        translations: null, // No translations
      );

      final modelThai = errorCode.getLocalizedMessage(languageCode: 'th-TH');
      final modelEnglish = errorCode.getLocalizedMessage(languageCode: 'en-US');
      final modelDefault = errorCode.getLocalizedMessage();
      
      print('📋 ErrorCode Model (no message, no translations):');
      print('  🇹🇭 Thai: $modelThai');
      print('  🇺🇸 English: $modelEnglish');
      print('  🌐 Default: $modelDefault');

      // Test with message but no translations
      final errorCodeWithMessage = ErrorCode(
        code: 'TEST_CODE_2',
        message: 'Default message',
        translations: null,
      );

      final modelWithMessageThai = errorCodeWithMessage.getLocalizedMessage(languageCode: 'th-TH');
      final modelWithMessageEnglish = errorCodeWithMessage.getLocalizedMessage(languageCode: 'en-US');
      
      print('\n📋 ErrorCode Model (with message, no translations):');
      print('  🇹🇭 Thai: $modelWithMessageThai');
      print('  🇺🇸 English: $modelWithMessageEnglish');

      // Expectations
      expect(thaiMessage, 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ (COM10004)');
      expect(englishMessage, 'An unknown error occurred. (COM10004)');
      expect(defaultMessage, 'An unknown error occurred. (COM10004)');
      expect(shortEnglishMessage, 'An unknown error occurred. (COM10004)');
      expect(unknownMessage, 'An unknown error occurred. (COM10004)');
      
      expect(serviceThai, 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ (COM10004)');
      expect(serviceEnglish, 'An unknown error occurred. (COM10004)');
      expect(serviceDefault, 'An unknown error occurred. (COM10004)');
      
      expect(modelThai, 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ (TEST_CODE)');
      expect(modelEnglish, 'An unknown error occurred. (TEST_CODE)');
      expect(modelDefault, 'An unknown error occurred. (TEST_CODE)');
      
      expect(modelWithMessageThai, 'Default message');
      expect(modelWithMessageEnglish, 'Default message');
    });

    test('should demonstrate real-world usage with custom fallbacks', () async {
      await ErrorCodeService.init(
        baseUrl: 'https://your-directus-instance.com',
        accessToken: 'your-access-token',
        collectionName: 'error',
        autoLoad: true,
      );

      print('\n${'='*60}');
      print('🏗️ Real-World Usage with Custom Fallbacks');
      print('${'='*60}');

      // Simulate different error scenarios
      final scenarios = [
        {'code': 'COM10003', 'description': 'Existing error code'},
        {'code': 'COM10004', 'description': 'Missing error code'},
        {'code': 'LOGIN_FAILED', 'description': 'Invalid error code'},
        {'code': 'NETWORK_ERROR', 'description': 'Non-existent error code'},
      ];

      for (final scenario in scenarios) {
        final code = scenario['code']!;
        final description = scenario['description']!;
        
        print('\n🔍 Scenario: $description ($code)');
        
        // Get error message in Thai
        final thaiMessage = code.getErrorMessage(languageCode: 'th-TH');
        
        // Get error message in English
        final englishMessage = code.getErrorMessage(languageCode: 'en-US');
        
        // Determine if this is a known or unknown error
        final isKnownError = ErrorCodeService.hasErrorCode(code);
        
        print('  📊 Status: ${isKnownError ? "✅ Known" : "❌ Unknown"}');
        print('  🇹🇭 Thai Message: $thaiMessage');
        print('  🇺🇸 English Message: $englishMessage');
        
        // Show how you might handle this in a real app
        if (isKnownError) {
          print('  💡 Action: Show specific error dialog');
        } else {
          print('  💡 Action: Show generic error dialog');
          print('  📝 Note: Log missing error code for debugging');
        }
      }

      // Show error handling pattern
      print('\n${'='*60}');
      print('🛠️ Error Handling Pattern');
      print('${'='*60}');

      void handleUserError(String errorCode, String userLanguage) {
        final error = ErrorCodeService.getErrorCode(errorCode);
        final message = errorCode.getErrorMessage(languageCode: userLanguage);
        
        print('🔧 Handling Error: $errorCode');
        print('   User Language: $userLanguage');
        print('   Error Found: ${error != null ? "Yes" : "No"}');
        print('   Message: $message');
        
        if (error == null) {
          print('   📝 Action: Log missing error code');
          print('   🚨 Action: Report to analytics');
          print('   💬 Action: Show generic error dialog');
        } else {
          print('   ✅ Action: Show specific error dialog');
          print('   📱 Action: Use error details (severity, category, etc.)');
        }
      }

      // Test the pattern
      handleUserError('COM10003', 'th-TH'); // Known error
      handleUserError('COM10004', 'th-TH'); // Unknown error
      handleUserError('COM10003', 'en-US'); // Known error in English
      handleUserError('COM10004', 'en-US'); // Unknown error in English

      expect(true, isTrue); // Test passes if no exceptions thrown
    });
  });
}
