#!/usr/bin/env dart

/// Example script for generating I18n enum in your project
/// 
/// This script demonstrates how to generate enum with page prefix support
/// for the new Directus structure (app_page + app_content)
/// 
/// Usage:
/// 1. Copy this file to your project: scripts/generate_i18n_keys.dart
/// 2. Update the configuration below
/// 3. Run: dart run scripts/generate_i18n_keys.dart

import 'dart:io';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');
  
  // Get configuration from environment variables
  final baseUrl = dotenv.get('DIRECTUS_BASE_URL');
  final accessToken = dotenv.get('DIRECTUS_ACCESS_TOKEN');
  final collectionName = dotenv.get('DIRECTUS_COLLECTION_NAME', fallback: 'app_content');
  final enumName = dotenv.get('I18N_ENUM_NAME', fallback: 'AppI18nKeys');
  
  // Validate required configuration
  if (baseUrl.isEmpty || accessToken.isEmpty) {
    print('\x1B[31m❌ Error: DIRECTUS_BASE_URL and DIRECTUS_ACCESS_TOKEN must be set in .env file\x1B[0m');
    exit(1);
  }
  
  print('🚀 Generating I18n keys from Directus...');
  print('Base URL: $baseUrl');
  print('Collection: $collectionName');
  print('Enum Name: $enumName');
  print('');
  
  try {
    // Create generated directory if it doesn't exist
    final generatedDir = Directory('lib/generated');
    if (!await generatedDir.exists()) {
      await generatedDir.create(recursive: true);
      print('📁 Created lib/generated directory');
    }
    
    // Generate enum with page prefix support
    await DirectusI18nKeyGenerator.generate(
      baseUrl: baseUrl,
      accessToken: accessToken,
      outputPath: 'lib/generated/$enumName.dart',
      collectionName: collectionName,
      collections: [
        // Configure your pages here
        // Each DirectusCollectionConfig represents one page
        DirectusCollectionConfig(
          name: collectionName,
          pagePrefix: 'login', // Page prefix from app_page collection
        ),
        DirectusCollectionConfig(
          name: collectionName,
          pagePrefix: 'home',
        ),
        DirectusCollectionConfig(
          name: collectionName,
          pagePrefix: 'profile',
        ),
        // Add more pages as needed
        // DirectusCollectionConfig(
        //   name: collectionName,
        //   pagePrefix: 'settings',
        // ),
      ],
      enumName: enumName,
    );
    
    print('✅ Successfully generated $enumName at lib/generated/$enumName.dart');
    print('');
    print('📝 Next steps:');
    print('   1. Import the generated enum: import \'../generated/$enumName.dart\';');
    print('   2. Use in your widgets: ${enumName}.LOGIN_TITLE.translate(context: context)');
    print('   3. Run this script again when you add new keys in Directus');
    print('');
    print('💡 Tip: You can add this script to your Makefile or CI/CD pipeline');
    
  } catch (e, stackTrace) {
    print('\x1B[31m❌ Error generating enum: $e\x1B[0m');
    if (e.toString().contains('Page prefix')) {
      print('\x1B[33m⚠️  Make sure the page prefix exists in app_page collection with status=published\x1B[0m');
    }
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
