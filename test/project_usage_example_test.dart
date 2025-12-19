/// Example test file for projects using directus_i18n
/// 
/// Copy this file to your project's test directory and modify as needed
/// 
/// Usage:
/// 1. Update DIRECTUS_BASE_URL and DIRECTUS_ACCESS_TOKEN
/// 2. Update pagePrefix and keys according to your Directus structure
/// 3. Run: flutter test test/project_usage_example_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  group('Directus I18n Integration Tests', () {
    setUpAll(() async {
      // Load environment variables
      await dotenv.load(fileName: '.env');
    });

    setUp(() async {
      // Initialize service before each test
      await HybridI18nService.init(
        baseUrl: dotenv.get('DIRECTUS_BASE_URL'),
        accessToken: dotenv.get('DIRECTUS_ACCESS_TOKEN'),
        collectionName: 'app_content',
        collections: [
          DirectusCollectionConfig(
            name: 'app_content',
            pagePrefix: 'login', // เปลี่ยนตาม project ของคุณ
          ),
        ],
        autoGenerateEnum: false,
        enableDynamicFallback: true,
      );

      // Wait for initialization to complete
      await Future.delayed(Duration(seconds: 2));
    });

    tearDown(() {
      // Reset service after each test
      HybridI18nService.refresh();
    });

    test('should initialize successfully', () {
      final status = HybridI18nService.getStatus();
      expect(status['initialized'], isTrue);
      print('✅ Service initialized');
      print('   Dynamic keys count: ${status['dynamicKeysCount']}');
    });

    test('should load translations from Directus', () {
      final allKeys = HybridI18nService.getAllKeys();
      expect(allKeys.length, greaterThan(0));
      print('✅ Loaded ${allKeys.length} keys from Directus');
      print('   Keys: ${allKeys.take(5).join(', ')}...');
    });

    test('should translate existing key', () {
      // เปลี่ยน key ตามที่คุณมีใน Directus
      final translation = HybridI18nService.translate(
        'TITLE', // Key จาก Directus
        fallback: 'Login',
      );

      expect(translation, isNotEmpty);
      print('✅ Translation for TITLE: $translation');
    });

    test('should use fallback for missing key', () {
      final translation = HybridI18nService.translate(
        'NON_EXISTENT_KEY_12345',
        fallback: 'Fallback Text',
      );

      expect(translation, 'Fallback Text');
      print('✅ Fallback works correctly');
    });

    test('should translate with parameters', () {
      final translation = HybridI18nService.translate(
        'WELCOME_MESSAGE', // เปลี่ยนตาม key ที่คุณมี
        params: {'name': 'John'},
        fallback: 'Welcome, {name}!',
      );

      expect(translation, contains('John'));
      print('✅ Translation with params: $translation');
    });

    testWidgets('should display translated text in widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('th', 'TH'),
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('th', 'TH'),
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final translation = HybridI18nService.translate(
                  'TITLE',
                  context: context,
                  fallback: 'Login',
                );
                return Text(translation);
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);
      print('✅ Widget test passed');
    });

    test('should check if key exists', () {
      final hasKey = HybridI18nService.hasKey('TITLE');
      expect(hasKey, isA<bool>());
      print('✅ Has TITLE key: $hasKey');
    });

    test('should handle multiple page prefixes', () async {
      // Reset และ initialize ใหม่ด้วยหลาย pages
      HybridI18nService.refresh();

      await HybridI18nService.init(
        baseUrl: dotenv.get('DIRECTUS_BASE_URL'),
        accessToken: dotenv.get('DIRECTUS_ACCESS_TOKEN'),
        collectionName: 'app_content',
        collections: [
          DirectusCollectionConfig(
            name: 'app_content',
            pagePrefix: 'login',
          ),
          DirectusCollectionConfig(
            name: 'app_content',
            pagePrefix: 'home',
          ),
        ],
      );

      await Future.delayed(Duration(seconds: 2));

      final allKeys = HybridI18nService.getAllKeys();
      expect(allKeys.length, greaterThan(0));
      print('✅ Loaded ${allKeys.length} keys from multiple pages');
    });
  });
}
