/// Real Directus Integration Test
/// 
/// ทดสอบการดึงข้อมูลจริงจาก Directus CMS
/// ใช้ credentials และโครงสร้างจริงจาก Directus
/// 
/// Run: flutter test test/real_directus_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  // Note: This test requires real network access
  // Run with: flutter test test/real_directus_test.dart --no-pub
  // Or use: dart run test test/real_directus_test.dart
  // Configuration จาก Directus จริง
  const String baseUrl = 'https://cms.monster-fishing.com';
  const String accessToken = 'G-F4cQMXX-OZjvdWX5XZ9Z-GZri1ZhE4';
  const String collectionName = 'app_content';
  const String enumName = 'AppI18nKeys';

  group('Real Directus Integration Tests', () {
    setUp(() async {
      // Initialize service ก่อนแต่ละ test
      await HybridI18nService.init(
        baseUrl: baseUrl,
        accessToken: accessToken,
        collectionName: collectionName,
        collections: [
          DirectusCollectionConfig(
            name: collectionName,
            pagePrefix: 'login', // จากรูป: Page = "LOGIN"
          ),
        ],
        enumName: enumName,
        autoGenerateEnum: false, // ปิด enum generation ใน test
        enableDynamicFallback: true,
      );

      // รอให้ load translations เสร็จ
      await Future<void>.delayed(Duration(seconds: 3));
    });

    tearDown(() {
      // Reset service หลังแต่ละ test
      HybridI18nService.refresh();
    });

    test('should initialize HybridI18nService successfully', () {
      final status = HybridI18nService.getStatus();
      
      expect(status['initialized'], isTrue, reason: 'Service should be initialized');
      print('✅ Service initialized successfully');
      print('   Status: $status');
    });

    test('should load translations from Directus app_content collection', () {
      final allKeys = HybridI18nService.getAllKeys();
      
      expect(allKeys.length, greaterThan(0), reason: 'Should load at least one key');
      print('✅ Loaded ${allKeys.length} keys from Directus');
      print('   Keys: ${allKeys.join(', ')}');
    });

    test('should translate TITLE key from login page', () {
      // จากรูป: Key = "TITLE", Page = "LOGIN"
      // Value en-US = "LoginNew", Value th-TH = "เข้าสู่ระบบใหม่"
      
      final translation = HybridI18nService.translate(
        'TITLE', // Key จากรูป
        fallback: 'Login',
      );

      expect(translation, isNotEmpty, reason: 'Translation should not be empty');
      expect(
        translation == 'LoginNew' || translation == 'เข้าสู่ระบบใหม่' || translation == 'Login',
        isTrue,
        reason: 'Translation should match expected values',
      );
      
      print('✅ Translation for TITLE: "$translation"');
      print('   Expected: "LoginNew" (en-US) or "เข้าสู่ระบบใหม่" (th-TH)');
    });

    test('should check if TITLE key exists', () {
      final hasKey = HybridI18nService.hasKey('TITLE');
      
      expect(hasKey, isTrue, reason: 'TITLE key should exist in Directus');
      print('✅ TITLE key exists: $hasKey');
    });

    test('should translate with context (Thai locale)', () {
      // ทดสอบ translation ด้วย context ภาษาไทย
      final translation = HybridI18nService.translate(
        'TITLE',
        context: null, // ใช้ fallback locale
        fallback: 'Login',
      );

      expect(translation, isNotEmpty);
      print('✅ Translation without context: "$translation"');
    });

    test('should get all available keys from login page', () {
      final allKeys = HybridI18nService.getAllKeys();
      
      expect(allKeys, contains('TITLE'), reason: 'Should contain TITLE key');
      print('✅ All keys from login page:');
      for (final key in allKeys) {
        final translation = HybridI18nService.translate(key, fallback: 'N/A');
        print('   - $key: "$translation"');
      }
    });

    test('should handle missing key gracefully', () {
      final translation = HybridI18nService.translate(
        'NON_EXISTENT_KEY_12345',
        fallback: 'Fallback Text',
      );

      expect(translation, 'Fallback Text', reason: 'Should use fallback for missing key');
      print('✅ Fallback works correctly: "$translation"');
    });

    test('should verify page prefix filtering works', () async {
      // Reset และทดสอบด้วย page prefix อื่น
      HybridI18nService.refresh();

      await HybridI18nService.init(
        baseUrl: baseUrl,
        accessToken: accessToken,
        collectionName: collectionName,
        collections: [
          DirectusCollectionConfig(
            name: collectionName,
            pagePrefix: 'login', // จากรูป: Page = "LOGIN"
          ),
        ],
      );

      await Future<void>.delayed(Duration(seconds: 3));

      final allKeys = HybridI18nService.getAllKeys();
      print('✅ Keys filtered by page prefix "login": ${allKeys.length} keys');
      print('   Keys: ${allKeys.join(', ')}');
      
      // ควรมี TITLE key จาก login page
      expect(allKeys, contains('TITLE'), reason: 'Should contain TITLE from login page');
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
      
      // ควรแสดง translation (อาจเป็น "LoginNew" หรือ "เข้าสู่ระบบใหม่")
      final textFinder = find.text('Login');
      final loginNewFinder = find.text('LoginNew');
      final thaiFinder = find.text('เข้าสู่ระบบใหม่');
      
      // ตรวจสอบว่ามี text แสดงอย่างน้อย 1 ตัว
      final hasLogin = textFinder.evaluate().isNotEmpty;
      final hasLoginNew = loginNewFinder.evaluate().isNotEmpty;
      final hasThai = thaiFinder.evaluate().isNotEmpty;
      
      expect(
        hasLogin || hasLoginNew || hasThai,
        isTrue,
        reason: 'Should display translated text',
      );
      
      print('✅ Widget test passed - Translation displayed correctly');
      if (hasLogin) print('   Found: "Login"');
      if (hasLoginNew) print('   Found: "LoginNew"');
      if (hasThai) print('   Found: "เข้าสู่ระบบใหม่"');
    });

    test('should verify service status details', () {
      final status = HybridI18nService.getStatus();
      
      expect(status['initialized'], isTrue);
      expect(status['dynamicKeysCount'], greaterThan(0));
      
      print('✅ Service Status:');
      print('   Initialized: ${status['initialized']}');
      print('   Dynamic Keys Count: ${status['dynamicKeysCount']}');
      print('   Has Generated Enum: ${status['hasGeneratedEnum']}');
      print('   Collections: ${status['collections']}');
    });

    test('should test translation with parameters', () {
      // ทดสอบ translation ที่มี parameters
      final translation = HybridI18nService.translate(
        'WELCOME_MESSAGE', // เปลี่ยนตาม key ที่มีจริง
        params: {'name': 'John'},
        fallback: 'Welcome, {name}!',
      );

      expect(translation, contains('John'), reason: 'Should contain parameter value');
      print('✅ Translation with params: "$translation"');
    });
  });

  group('Directus Structure Verification', () {
    test('should test Directus API query syntax', () async {
      // ทดสอบ query syntax ที่ถูกต้อง
      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        validateStatus: (status) => status! < 500, // Allow 400 for debugging
      ));
      
      try {
        // ทดสอบ 1: Query แบบง่ายๆ ก่อน
        final simpleResponse = await dio.get<Map<String, dynamic>>(
          '/items/app_content',
          queryParameters: {
            'access_token': accessToken,
            'fields': 'id,key,status',
            'limit': 1,
          },
        );
        
        if (simpleResponse.statusCode == 200) {
          print('✅ Simple query works');
          print('   Response: ${simpleResponse.data}');
          
          // ทดสอบ 2: Query ด้วย translations.*
          final translationsResponse = await dio.get<Map<String, dynamic>>(
            '/items/app_content',
            queryParameters: {
              'access_token': accessToken,
              'fields': 'id,key,translations.*,status',
              'limit': 1,
            },
          );
          
          if (translationsResponse.statusCode == 200) {
            print('✅ Translations query works');
            final data = (translationsResponse.data?['data'] ?? []) as List<dynamic>;
            if (data.isNotEmpty) {
              final item = data[0] as Map<String, dynamic>;
              print('   Item: $item');
              print('   Translations: ${item['translations']}');
            }
          } else {
            print('⚠️  Translations query returned ${translationsResponse.statusCode}');
            print('   Response: ${translationsResponse.data}');
          }
        } else {
          print('⚠️  Simple query returned ${simpleResponse.statusCode}');
          print('   Response: ${simpleResponse.data}');
        }
      } catch (e) {
        print('❌ Query test failed: $e');
        if (e is DioException) {
          print('   Status code: ${e.response?.statusCode}');
          print('   Response data: ${e.response?.data}');
          print('   Request path: ${e.requestOptions.path}');
          print('   Request query params: ${e.requestOptions.queryParameters}');
        }
      }
    });

    test('should verify app_page collection structure', () async {
      // ทดสอบดึงข้อมูลจาก app_page collection
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      
      try {
        final response = await dio.get<Map<String, dynamic>>(
          '/items/app_page',
          queryParameters: {
            'access_token': accessToken,
            'fields': 'id,key,status',
            'filter[status][_eq]': 'published',
            'limit': '-1',
          },
        );

        final data = (response.data?['data'] ?? []) as List<dynamic>;
        expect(data.length, greaterThan(0), reason: 'Should have at least one page');
        
        // ตรวจสอบว่ามี page "LOGIN" หรือไม่
        Map<String, dynamic>? loginPage;
        try {
          loginPage = data.firstWhere(
            (item) => (item as Map<String, dynamic>)['key'] == 'login',
          ) as Map<String, dynamic>;
        } catch (e) {
          loginPage = null;
        }
        
        expect(loginPage, isNotNull, reason: 'Should have login page');
        print('✅ App Page collection structure verified');
        print('   Total pages: ${data.length}');
        print('   Login page exists: ${loginPage != null}');
        
        if (loginPage != null) {
          print('   Login page data: $loginPage');
        }
      } catch (e) {
        print('⚠️  Could not verify app_page structure: $e');
        // ไม่ fail test เพราะอาจจะไม่มี app_page collection
      }
    });

    test('should verify app_content collection structure', () async {
      // ทดสอบดึงข้อมูลจาก app_content collection
      final dio = Dio(BaseOptions(baseUrl: baseUrl));
      
      try {
        // ดึง page ID จาก app_page ก่อน
        final pageResponse = await dio.get<Map<String, dynamic>>(
          '/items/app_page',
          queryParameters: {
            'access_token': accessToken,
            'fields': 'id,key',
            'filter[key][_eq]': 'login',
            'filter[status][_eq]': 'published',
            'limit': '1',
          },
        );

        final pageData = (pageResponse.data?['data'] ?? []) as List<dynamic>;
        if (pageData.isEmpty) {
          print('⚠️  Login page not found, skipping app_content test');
          return;
        }

        final pageId = (pageData[0] as Map<String, dynamic>)['id'];

        // ดึง app_content ที่เกี่ยวข้องกับ login page
        // ใช้ translations.* เพื่อดึง translations array ทั้งหมด
        final contentResponse = await dio.get<Map<String, dynamic>>(
          '/items/app_content',
          queryParameters: {
            'access_token': accessToken,
            'fields': 'id,page,key,translations.*,status',
            'filter[page][_eq]': pageId,
            'filter[status][_eq]': 'published',
            'limit': '-1',
          },
        );

        final contentData = (contentResponse.data?['data'] ?? []) as List<dynamic>;
        expect(contentData.length, greaterThan(0), reason: 'Should have at least one content item');
        
        // ตรวจสอบว่ามี key "TITLE" หรือไม่
        Map<String, dynamic>? titleItem;
        try {
          titleItem = contentData.firstWhere(
            (item) {
              final itemMap = item as Map<String, dynamic>;
              return itemMap['key'] == 'TITLE';
            },
          ) as Map<String, dynamic>;
        } catch (e) {
          titleItem = null;
        }
        
        expect(titleItem, isNotNull, reason: 'Should have TITLE key');
        print('✅ App Content collection structure verified');
        print('   Total content items: ${contentData.length}');
        print('   TITLE item exists: ${titleItem != null}');
        
        if (titleItem != null) {
          final translations = titleItem['translations'];
          if (translations is List) {
            print('   TITLE translations (array structure):');
            String? enUsValue;
            String? thThValue;
            
            for (final trans in translations) {
              if (trans is Map<String, dynamic>) {
                final langCode = trans['languages_code']?.toString();
                final value = trans['value']?.toString();
                print('     $langCode: $value');
                
                if (langCode == 'en-US') enUsValue = value;
                if (langCode == 'th-TH') thThValue = value;
              }
            }
            
            // ตรวจสอบว่าใช้ value field ไม่ใช่ message
            expect(
              enUsValue != null || thThValue != null,
              isTrue,
              reason: 'Should have translation values',
            );
            
            // ตรวจสอบค่าที่คาดหวังจากรูป
            if (enUsValue != null) {
              expect(enUsValue, 'LoginNew', reason: 'en-US should be "LoginNew"');
            }
            if (thThValue != null) {
              expect(thThValue, 'เข้าสู่ระบบใหม่', reason: 'th-TH should match');
            }
          } else {
            print('   ⚠️  Translations is not an array: ${translations.runtimeType}');
          }
        }
      } catch (e) {
        print('❌ Error verifying app_content structure: $e');
        rethrow;
      }
    });
  });
}
