#!/usr/bin/env dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';

/// Script to sync error codes from Directus
/// This script can be run to refresh error codes without generating enum files
/// 
/// Usage:
/// 1. Set up .env file with your Directus credentials
/// 2. Run: dart run scripts/sync_error_codes.dart
/// 3. Error codes will be loaded into the app at runtime

void main() async {
  // Load the .env file
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // Access the environment variables
  final baseUrl = env['DIRECTUS_BASE_URL'];
  final accessToken = env['DIRECTUS_ACCESS_TOKEN'];
  final collectionName = env['ERROR_CODES_COLLECTION_NAME'] ?? 'error_codes';

  if (baseUrl == null || accessToken == null) {
    print(
      "\x1B[31mError: DIRECTUS_BASE_URL and DIRECTUS_ACCESS_TOKEN must be set in the .env file.\x1B[0m",
    );
    exit(1);
  }

  print("🔄 Syncing error codes from Directus...");
  print("Base URL: $baseUrl");
  print("Collection: $collectionName");
  print("");

  try {
    final dio = Dio();
    dio.options.baseUrl = baseUrl;
    
    final response = await dio.get(
      '/items/$collectionName',
      queryParameters: {
        'access_token': accessToken,
        'fields': 'code,message,title,description,severity,category,parameters,action_text,action_url,translations.value,translations.draft_value',
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
          'title': item['title'],
          'description': item['description'],
          'severity': item['severity'] ?? 'error',
          'category': item['category'] ?? 'general',
          'parameters': item['parameters'],
          'actionText': item['action_text'],
          'actionUrl': item['action_url'],
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
          translations[code] = translationMap;
        }
      }
    }

    print("✅ Successfully loaded ${errorCodes.length} error codes");
    print("");
    print("📋 Available error codes:");
    errorCodes.keys.take(10).forEach((code) {
      final errorCode = errorCodes[code]!;
      print("  - $code: ${errorCode['message']?.substring(0, 50)}...");
    });
    
    if (errorCodes.length > 10) {
      print("  ... and ${errorCodes.length - 10} more error codes");
    }
    
    print("");
    print("📊 Error codes by severity:");
    final severityCount = <String, int>{};
    errorCodes.values.forEach((errorCode) {
      final severity = errorCode['severity'] ?? 'error';
      severityCount[severity] = (severityCount[severity] ?? 0) + 1;
    });
    severityCount.forEach((severity, count) {
      print("  - $severity: $count");
    });
    
    print("");
    print("📊 Error codes by category:");
    final categoryCount = <String, int>{};
    errorCodes.values.forEach((errorCode) {
      final category = errorCode['category'] ?? 'general';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    });
    categoryCount.forEach((category, count) {
      print("  - $category: $count");
    });
    
    print("");
    print("💡 These error codes are now available for use with ErrorCodeService");
    print("   Example: 'NETWORK_ERROR'.getErrorMessage() or ErrorCodeService.getErrorCode('NETWORK_ERROR')");
    print("");
    print("🔄 To refresh error codes in your app, call: ErrorCodeService.refresh()");

  } catch (e) {
    print("\x1B[31mFailed to sync error codes: $e\x1B[0m");
    exit(1);
  }
}
