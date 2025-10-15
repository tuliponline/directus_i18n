import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() {
  const baseUrl = 'https://cms.monster-fishing.com';

  group('Full Integration (Public) - Directus schema verification', () {
    late Dio dio;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: baseUrl));
    });

    test('Contents public endpoint structure is valid', () async {
      final response = await dio.get(
        '/items/contents',
        queryParameters: {
          'fields': 'key,translations.message,translations.language_code',
          'deep[translations][_filter][message][_nnull]': 'true',
          'limit': '-1',
        },
      );

      expect(response.statusCode, 200);
      final data = (response.data['data'] as List);
      expect(data.isNotEmpty, true);

      final first = data.first as Map<String, dynamic>;
      expect(first.containsKey('key'), true);
      expect(first.containsKey('translations'), true);
      final translations = (first['translations'] as List);
      expect(translations.isNotEmpty, true);
      final t0 = translations.first as Map<String, dynamic>;
      expect(t0.containsKey('message'), true);
      expect(t0.containsKey('language_code'), true);
    });

    test('Error public endpoint structure is valid and maps to ErrorCode', () async {
      final response = await dio.get(
        '/items/error',
        queryParameters: {
          'fields': 'code,translations.message,translations.language_code',
          'deep[translations][_filter][message][_nnull]': 'true',
          'limit': '-1',
        },
      );

      expect(response.statusCode, 200);
      final data = (response.data['data'] as List);
      expect(data.isNotEmpty, true);

      // Map first item to ErrorCode model
      final first = data.first as Map<String, dynamic>;
      expect(first.containsKey('code'), true);
      expect(first.containsKey('translations'), true);

      final errorCode = ErrorCode.fromDirectus(first);
      expect(errorCode.code.isNotEmpty, true);
      expect(errorCode.translations != null && errorCode.translations!.isNotEmpty, true);

      // Validate a couple of language lookups if present
      final langs = errorCode.getAvailableLanguages();
      for (final lang in langs.take(2)) {
        final msg = errorCode.getLocalizedMessage(languageCode: lang);
        expect(msg.isNotEmpty, true);
      }
    });
  });
}


