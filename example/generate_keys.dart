#!/usr/bin/env dart

import 'dart:io';
import 'package:directus_i18n/directus_i18n.dart';

/// Example script to generate I18nKeys from Directus
/// 
/// Usage:
/// 1. Update the configuration below with your Directus details
/// 2. Run: dart run example/generate_keys.dart

Future<void> main() async {
  // Configuration
  const baseUrl = 'https://your-directus-instance.com';
  const accessToken = 'your-access-token';
  const outputPath = 'lib/generated/i18n_keys.dart';

  print('🚀 Starting key generation...');
  print('Base URL: $baseUrl');
  print('Output: $outputPath');
  print('');

  try {
    await DirectusI18nKeyGenerator.generate(
      baseUrl: baseUrl,
      accessToken: accessToken,
      outputPath: outputPath,
      collectionName: 'app_contents',
      enumName: 'I18nKeys',
    );
    
    print('');
    print('✅ Key generation completed successfully!');
    print('Generated file: $outputPath');
    exit(0);
  } catch (e, stackTrace) {
    print('');
    print('❌ Key generation failed!');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

