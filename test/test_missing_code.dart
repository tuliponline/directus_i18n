import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  group('Test Missing Error Code (COM10004)', () {
    test('should handle missing COM10004 error code gracefully', () async {
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

      // Test searching for COM10004 (which doesn't exist)
      print('${'='*60}');
      print('🔍 Testing Missing Error Code: COM10004');
      print('${'='*60}');

      // 1. Try to get COM10004 directly
      final com10004 = ErrorCodeService.getErrorCode('COM10004');
      print('📋 Direct get COM10004: ${com10004?.code ?? 'null'}');
      
      if (com10004 == null) {
        print('✅ COM10004 not found (as expected)');
      } else {
        print('⚠️ COM10004 found unexpectedly');
      }

      // 2. Try extension methods on non-existent code
      print('\n🧪 Testing Extension Methods on Missing Code:');
      print('getErrorMessage(): ${'COM10004'.getErrorMessage()}');
      print('getErrorTitle(): ${'COM10004'.getErrorTitle()}');
      print('getErrorDescription(): ${'COM10004'.getErrorDescription()}');
      
      // 3. Test with language codes
      print('\n🌐 With Language Codes:');
      print('getErrorMessage(th-TH): ${'COM10004'.getErrorMessage(languageCode: 'th-TH')}');
      print('getErrorMessage(en-US): ${'COM10004'.getErrorMessage(languageCode: 'en-US')}');

      // 4. Search for COM10004
      final searchResults = ErrorCodeService.searchErrorCodes('COM10004');
      print('\n🔎 Search for "COM10004": Found ${searchResults.length} results');
      
      for (final errorCode in searchResults) {
        print('  - ${errorCode.code}: ${errorCode.getLocalizedMessage(languageCode: 'en-US')}');
      }

      // 5. Search for partial match
      final partialResults = ErrorCodeService.searchErrorCodes('COM100');
      print('\n🔎 Search for "COM100": Found ${partialResults.length} results');
      
      for (final errorCode in partialResults) {
        print('  - ${errorCode.code}: ${errorCode.getLocalizedMessage(languageCode: 'en-US')}');
      }

      // 6. Show what codes actually exist
      final allCodes = await ErrorCodeService.getAllErrorCodes();
      print('\n📊 All Available Error Codes:');
      for (final errorCode in allCodes) {
        print('  - ${errorCode.code}: ${errorCode.getLocalizedMessage(languageCode: 'en-US')}');
      }

      // 7. Test error handling workflow with missing code
      print('\n${'='*60}');
      print('🔄 Error Handling Workflow with Missing Code');
      print('${'='*60}');

      void handleError(String errorCode, String languageCode) {
        final error = ErrorCodeService.getErrorCode(errorCode);
        
        if (error != null) {
          final message = error.getLocalizedMessage(languageCode: languageCode);
          print('✅ Found error: $errorCode');
          print('   Message ($languageCode): $message');
        } else {
          print('❌ Error code not found: $errorCode');
          print('   Fallback message: $errorCode (using code as message)');
          
          // In real app, you might want to:
          // - Log the missing error code
          // - Use a default error message
          // - Show a generic error dialog
          // - Report to analytics
        }
      }

      print('\n🧪 Testing Error Handling:');
      handleError('COM10004', 'th-TH'); // Missing code
      handleError('COM10003', 'th-TH'); // Existing code

      // 8. Test fallback behavior
      print('\n${'='*60}');
      print('🛡️ Fallback Behavior Testing');
      print('${'='*60}');

      // Create a mock ErrorCode for missing code (simulating fallback)
      final fallbackErrorCode = ErrorCode(
        code: 'COM10004',
        message: 'Unknown error occurred',
        translations: {
          'en-US': 'Unknown error occurred',
          'th-TH': 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ'
        },
        severity: ErrorSeverity.error,
        category: 'unknown',
        title: 'Unknown Error',
        description: 'An unknown error has occurred',
        actionText: 'Try Again',
      );

      print('📋 Fallback Error Code:');
      print('  Code: ${fallbackErrorCode.code}');
      print('  Message (EN): ${fallbackErrorCode.getLocalizedMessage(languageCode: 'en-US')}');
      print('  Message (TH): ${fallbackErrorCode.getLocalizedMessage(languageCode: 'th-TH')}');
      print('  Severity: ${fallbackErrorCode.severity?.name}');
      print('  Category: ${fallbackErrorCode.category}');

      // 9. Test error code validation
      print('\n${'='*60}');
      print('✅ Error Code Validation');
      print('${'='*60}');

      bool isValidErrorCode(String errorCode) {
        final error = ErrorCodeService.getErrorCode(errorCode);
        return error != null;
      }

      final testCodes = ['COM10003', 'COM10004', 'LOGIN_FAILED', 'INVALID_CODE'];
      
      for (final code in testCodes) {
        final isValid = isValidErrorCode(code);
        print('  $code: ${isValid ? '✅ Valid' : '❌ Invalid'}');
      }

      // Expectations
      expect(com10004, isNull);
      expect(searchResults, isEmpty);
      expect(allCodes, isNotEmpty);
      expect(allCodes.first.code, 'COM10003'); // Should have COM10003
    });

    test('should demonstrate real-world error handling patterns', () async {
      await ErrorCodeService.init(
        baseUrl: 'https://your-directus-instance.com',
        accessToken: 'your-access-token',
        collectionName: 'error',
        autoLoad: true,
      );

      print('\n${'='*60}');
      print('🏗️ Real-World Error Handling Patterns');
      print('${'='*60}');

      // Pattern 1: Safe error message retrieval
      String getErrorMessage(String errorCode, {String languageCode = 'th-TH'}) {
        final error = ErrorCodeService.getErrorCode(errorCode);
        
        if (error != null) {
          return error.getLocalizedMessage(languageCode: languageCode);
        } else {
          // Fallback for missing error codes
          return 'เกิดข้อผิดพลาด: $errorCode';
        }
      }

      // Pattern 2: Error dialog with fallback
      void showErrorDialog(String errorCode, String languageCode) {
        final error = ErrorCodeService.getErrorCode(errorCode);
        
        String title;
        String message;
        String actionText;
        
        if (error != null) {
          title = error.title ?? error.code;
          message = error.getLocalizedMessage(languageCode: languageCode);
          actionText = error.actionText ?? 'ตกลง';
        } else {
          // Fallback for missing error codes
          title = 'ข้อผิดพลาด';
          message = 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ ($errorCode)';
          actionText = 'ตกลง';
        }
        
        print('📱 Error Dialog:');
        print('  Title: $title');
        print('  Message: $message');
        print('  Action: $actionText');
      }

      // Pattern 3: Error logging
      void logError(String errorCode, String context) {
        final error = ErrorCodeService.getErrorCode(errorCode);
        
        if (error == null) {
          print('🚨 Missing Error Code Logged:');
          print('  Code: $errorCode');
          print('  Context: $context');
          print('  Timestamp: ${DateTime.now()}');
          // In real app: send to analytics/crash reporting
        }
      }

      // Test patterns
      print('\n🧪 Testing Error Handling Patterns:');
      
      // Test with existing code
      print('\n1️⃣ Existing Code (COM10003):');
      print('   Message: ${getErrorMessage('COM10003')}');
      showErrorDialog('COM10003', 'th-TH');
      
      // Test with missing code
      print('\n2️⃣ Missing Code (COM10004):');
      print('   Message: ${getErrorMessage('COM10004')}');
      showErrorDialog('COM10004', 'th-TH');
      logError('COM10004', 'User login attempt');
      
      // Test with completely invalid code
      print('\n3️⃣ Invalid Code (INVALID_CODE):');
      print('   Message: ${getErrorMessage('INVALID_CODE')}');
      showErrorDialog('INVALID_CODE', 'th-TH');
      logError('INVALID_CODE', 'Unknown context');

      expect(true, isTrue); // Test passes if no exceptions thrown
    });
  });
}
