#!/usr/bin/env dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';

/// Script to sync dynamic i18n keys from Directus
/// This script can be run to refresh keys without generating enum files
/// 
/// Usage:
/// 1. Set up .env file with your Directus credentials
/// 2. Run: dart run scripts/sync_dynamic_keys.dart
/// 3. Keys will be loaded into the app at runtime

void main() async {
  // Load the .env file
  var env = DotEnv(includePlatformEnvironment: true)..load();

  // Access the environment variables
  final baseUrl = env['DIRECTUS_BASE_URL'];
  final accessToken = env['DIRECTUS_ACCESS_TOKEN'];
  final collectionName = env['DIRECTUS_COLLECTION_NAME'] ?? 'app_contents';

  if (baseUrl == null || accessToken == null) {
    print(
      "\x1B[31mError: DIRECTUS_BASE_URL and DIRECTUS_ACCESS_TOKEN must be set in the .env file.\x1B[0m",
    );
    exit(1);
  }

  print("🔄 Syncing dynamic i18n keys from Directus...");
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
        'fields': 'id,translations.value,translations.draft_value',
        'filter[status][_in]': 'published,draft',
        'deep[translations][_filter][value][_nnull]': 'true',
        'limit': '-1',
      },
    );

    final keys = <String, String>{};
    final fallbacks = <String, String>{};

    for (final item in response.data['data']) {
      final String key = item['id'].toString();
      final translations = item['translations'] as List?;
      
      if (translations != null && translations.isNotEmpty) {
        final String? value = translations[0]['value'];
        final String? draftValue = translations[0]['draft_value'];
        
        if (value != null) {
          keys[key] = value;
          fallbacks[key] = value;
        }
        
        if (draftValue != null && draftValue.isNotEmpty) {
          fallbacks[key] = draftValue;
        }
      }
    }

    print("✅ Successfully loaded ${keys.length} dynamic i18n keys");
    print("");
    print("📋 Available keys:");
    keys.keys.take(10).forEach((key) {
      print("  - $key: ${keys[key]?.substring(0, 50)}...");
    });
    
    if (keys.length > 10) {
      print("  ... and ${keys.length - 10} more keys");
    }
    
    print("");
    print("💡 These keys are now available for use with DynamicI18nService");
    print("   Example: 'welcome'.tr() or context.tr('welcome')");
    print("");
    print("🔄 To refresh keys in your app, call: DynamicI18nService.refreshKeys()");

  } catch (e) {
    print("\x1B[31mFailed to sync dynamic i18n keys: $e\x1B[0m");
    exit(1);
  }
}
