#!/usr/bin/env dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';

/// Script to sync both I18n content and Error codes from Directus
/// This script can be run to refresh both services without generating enum files
/// 
/// Usage:
/// 1. Set up .env file with your Directus credentials
/// 2. Run: dart run scripts/sync_both_services.dart
/// 3. Both services will be loaded into the app at runtime

void main() async {
  // Load the .env file
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // Access the environment variables
  final baseUrl = env['DIRECTUS_BASE_URL'];
  final accessToken = env['DIRECTUS_ACCESS_TOKEN'];
  final i18nCollection = env['DIRECTUS_COLLECTION_NAME'] ?? 'app_contents';
  final errorCollection = env['ERROR_CODES_COLLECTION_NAME'] ?? 'error_codes';

  if (baseUrl == null || accessToken == null) {
    print(
      "\x1B[31mError: DIRECTUS_BASE_URL and DIRECTUS_ACCESS_TOKEN must be set in the .env file.\x1B[0m",
    );
    exit(1);
  }

  print("🔄 Syncing both I18n content and Error codes from Directus...");
  print("Base URL: $baseUrl");
  print("I18n Collection: $i18nCollection");
  print("Error Codes Collection: $errorCollection");
  print("");

  try {
    final dio = Dio();
    dio.options.baseUrl = baseUrl;
    
    // Sync I18n content
    await _syncI18nContent(dio, baseUrl, accessToken, i18nCollection);
    
    print("");
    
    // Sync Error codes
    await _syncErrorCodes(dio, baseUrl, accessToken, errorCollection);
    
    print("");
    print("✅ Both services synced successfully!");
    print("");
    print("💡 You can now use both I18n content and Error codes in your app");
    print("   I18n: 'welcome'.tr() or HybridI18nService.translate('welcome')");
    print("   Error: 'NETWORK_ERROR'.getErrorMessage() or ErrorCodeService.getErrorCode('NETWORK_ERROR')");

  } catch (e) {
    print("\x1B[31mFailed to sync services: $e\x1B[0m");
    exit(1);
  }
}

Future<void> _syncI18nContent(Dio dio, String baseUrl, String accessToken, String collectionName) async {
  print("🌍 Syncing I18n content...");
  
  try {
    final response = await dio.get(
      '/items/$collectionName',
      queryParameters: {
        'access_token': accessToken,
        'fields': 'id,translations.value,translations.draft_value',
        'filter[status][_eq]': 'published',
        'deep[translations][_filter][value][_nnull]': 'true',
        'limit': '-1',
      },
    );

    final i18nKeys = <String, String>{};
    final translations = <String, Map<String, String>>{};

    for (final item in response.data['data']) {
      final String key = item['id'].toString();
      final translationList = item['translations'] as List?;
      
      if (translationList != null && translationList.isNotEmpty) {
        final value = translationList[0]['value'];
        if (value != null) {
          i18nKeys[key] = value;
        }
        
        // Load translations
        final translationMap = <String, String>{};
        for (final translation in translationList) {
          final languageCode = translation['languages_code']['code'];
          final translationValue = translation['value'];
          if (translationValue != null) {
            translationMap[languageCode] = translationValue;
          }
        }
        if (translationMap.isNotEmpty) {
          translations[key] = translationMap;
        }
      }
    }

    print("✅ Successfully loaded ${i18nKeys.length} I18n content items");
    print("📋 Available I18n keys:");
    i18nKeys.keys.take(10).forEach((key) {
      print("  - $key: ${i18nKeys[key]?.substring(0, 50)}...");
    });
    
    if (i18nKeys.length > 10) {
      print("  ... and ${i18nKeys.length - 10} more keys");
    }
    
    print("🌍 Available languages:");
    final allLanguages = <String>{};
    translations.values.forEach((langMap) => allLanguages.addAll(langMap.keys));
    allLanguages.forEach((lang) => print("  - $lang"));

  } catch (e) {
    print("\x1B[31mFailed to sync I18n content: $e\x1B[0m");
    rethrow;
  }
}

Future<void> _syncErrorCodes(Dio dio, String baseUrl, String accessToken, String collectionName) async {
  print("🚨 Syncing Error codes...");
  
  try {
    final response = await dio.get(
      '/items/$collectionName',
      queryParameters: {
        'access_token': accessToken,
        'fields': 'code,message,translations.value,translations.draft_value',
        'filter[status][_eq]': 'published',
        'deep[translations][_filter][value][_nnull]': 'true',
        'limit': '-1',
      },
    );

    final errorCodes = <String, Map<String, dynamic>>{};
    final translations = <String, Map<String, String>>{};

    for (final item in response.data['data']) {
      final code = item['code']?.toString() ?? '';
      if (code.isNotEmpty) {
        errorCodes[code] = {
          'code': code,
          'message': item['message'],
        };

        // Load translations
        final translationList = item['translations'] as List?;
        if (translationList != null && translationList.isNotEmpty) {
          final translationMap = <String, String>{};
          for (final translation in translationList) {
            final languageCode = translation['languages_code']['code'];
            final value = translation['value'];
            if (value != null) {
              translationMap[languageCode] = value;
            }
          }
          if (translationMap.isNotEmpty) {
            translations[code] = translationMap;
          }
        }
      }
    }

    print("✅ Successfully loaded ${errorCodes.length} error codes");
    print("📋 Available error codes:");
    errorCodes.keys.take(10).forEach((code) {
      final errorCode = errorCodes[code]!;
      print("  - $code: ${errorCode['message']?.substring(0, 50)}...");
    });
    
    if (errorCodes.length > 10) {
      print("  ... and ${errorCodes.length - 10} more error codes");
    }
    
    print("🌍 Available languages:");
    final allLanguages = <String>{};
    translations.values.forEach((langMap) => allLanguages.addAll(langMap.keys));
    allLanguages.forEach((lang) => print("  - $lang"));

  } catch (e) {
    print("\x1B[31mFailed to sync Error codes: $e\x1B[0m");
    rethrow;
  }
}
