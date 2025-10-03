// ตัวอย่างการใช้งาน Directus I18n กับโครงสร้างใหม่
// language (code: th-TH, en-US, name)
// error_translations (id, error_code, language_code, message)
// error (code, translations)

import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter/material.dart';

void main() async {
  // เริ่มต้น ErrorCodeService
  await ErrorCodeService.init(
    baseUrl: 'https://your-directus-url.com',
    accessToken: 'your-access-token',
    collectionName: 'error', // ใช้ collection 'error' แทน 'error_codes'
  );

  // โหลดข้อมูลภาษา
  final availableLanguages = await ErrorCodeService.loadAvailableLanguages();
  print('Available languages: $availableLanguages');
  // Output: Available languages: {th-TH, en-US}

  // ตัวอย่างการใช้งาน Error Code
  final errorCode = 'INVALID_EMAIL';
  
  // ใช้ภาษาไทย
  final thaiMessage = errorCode.getErrorMessage(languageCode: 'th-TH');
  print('Thai message: $thaiMessage');
  // Output: Thai message: กรุณาใส่อีเมลที่ถูกต้อง

  // ใช้ภาษาอังกฤษ
  final englishMessage = errorCode.getErrorMessage(languageCode: 'en-US');
  print('English message: $englishMessage');
  // Output: English message: Please enter a valid email address

  // ใช้ภาษาเริ่มต้น (จะใช้ภาษาแรกที่พบ)
  final defaultMessage = errorCode.getErrorMessage();
  print('Default message: $defaultMessage');

  // ใช้กับ parameters
  final messageWithParams = 'USER_NOT_FOUND'.getErrorMessage(
    languageCode: 'th-TH',
    parameters: {'username': 'john_doe'},
  );
  print('Message with params: $messageWithParams');
  // Output: Message with params: ไม่พบผู้ใช้ john_doe

  // ตรวจสอบว่า error code มีอยู่หรือไม่
  final isValidError = 'INVALID_EMAIL'.isErrorCode;
  print('Is valid error code: $isValidError');
  // Output: Is valid error code: true

  // ใช้กับ ErrorCode object โดยตรง
  final errorCodeObj = 'INVALID_EMAIL'.errorCode;
  if (errorCodeObj != null) {
    print('Error code: ${errorCodeObj.code}');
    print('Available languages: ${errorCodeObj.getAvailableLanguages()}');
    
    // ตรวจสอบว่ามีการแปลสำหรับภาษาไทยหรือไม่
    final hasThaiTranslation = errorCodeObj.hasTranslationFor('th-TH');
    print('Has Thai translation: $hasThaiTranslation');
  }

  // ใช้กับ CombinedI18nService
  await CombinedI18nService.init(
    baseUrl: 'https://your-directus-url.com',
    accessToken: 'your-access-token',
    i18nCollectionName: 'app_contents',
    errorCollectionName: 'error',
  );

  // ใช้ error message ผ่าน CombinedI18nService
  final combinedErrorMessage = CombinedI18nService.getErrorMessage(
    'INVALID_EMAIL',
    languageCode: 'th-TH',
  );
  print('Combined error message: $combinedErrorMessage');

  // โหลดข้อมูลภาษาทั้งหมด
  final allLanguages = await CombinedI18nService.loadAvailableLanguages();
  print('All available languages: $allLanguages');
}

// ตัวอย่างการใช้งานใน Flutter Widget
class ErrorMessageWidget extends StatelessWidget {
  final String errorCode;
  final String? languageCode;

  const ErrorMessageWidget({
    Key? key,
    required this.errorCode,
    this.languageCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      errorCode.getErrorMessage(
        languageCode: languageCode ?? context.currentLanguageCode,
      ),
      style: const TextStyle(color: Colors.red),
    );
  }
}

// ตัวอย่างการใช้งานใน Exception Handler
class ErrorHandler {
  static String handleException(Exception exception) {
    // ลองดึง error code จาก exception
    final errorCode = exception.errorCode;
    
    if (errorCode != null) {
      // ใช้ localized error message
      return errorCode.getLocalizedErrorMessage(
        languageCode: 'th-TH', // หรือใช้ context.currentLanguageCode
      );
    }
    
    // fallback ไปใช้ exception message ปกติ
    return exception.toString();
  }
}
