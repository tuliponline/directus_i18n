import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDirectusI18nRepository extends Mock implements DirectusI18nRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DirectusI18nLoader', () {
    late MockDirectusI18nRepository mockRepository;

    setUp(() {
      mockRepository = MockDirectusI18nRepository();
      registerFallbackValue(const Locale('en'));
    });

    test('should load translation from repository', () async {
      final mockResult = {'key1': 'value1', 'key2': 'value2'};

      when(() => mockRepository.load(any()))
          .thenAnswer((_) async => mockResult);

      final loader = DirectusI18nLoader(mockRepository);
      final result = await loader.load();

      verify(() => mockRepository.load(any())).called(1);
      expect(result, mockResult);
    });

    test('should use forced translation when provided', () async {
      final forcedTranslation = {'key1': 'forced_value'};

      when(() => mockRepository.load(any()))
          .thenAnswer((_) async => {'key1': 'original_value'});

      final loader = DirectusI18nLoader(
        mockRepository,
        forcedTranslation: forcedTranslation,
      );
      final result = await loader.load();

      expect(result, forcedTranslation);
    });
  });

  group('DirectusI18nService', () {
    tearDown(() {
      DirectusI18nService.reset();
    });

    test('should initialize with config', () {
      DirectusI18nService.init(
        baseUrl: 'https://test.com',
        accessToken: 'test-token',
      );

      final config = DirectusI18nService.config;
      expect(config.baseUrl, 'https://test.com');
      expect(config.accessToken, 'test-token');
    });

    test('should throw error when not initialized', () {
      expect(
        () => DirectusI18nService.config,
        throwsStateError,
      );
    });

    test('should update config', () {
      DirectusI18nService.init(
        baseUrl: 'https://test.com',
        accessToken: 'test-token',
      );

      DirectusI18nService.updateConfig(
        DirectusI18nConfig(
          baseUrl: 'https://new-test.com',
          accessToken: 'new-token',
        ),
      );

      final config = DirectusI18nService.config;
      expect(config.baseUrl, 'https://new-test.com');
      expect(config.accessToken, 'new-token');
    });
  });

  group('I18nKey', () {
    test('should have correct properties', () {
      final key = I18nKeys.example;
      expect(key.key, 'example');
      expect(key.defaultFallbackKey, 'Example text');
    });

    test('should return key when isDisplayContentKey is true', () {
      I18nKey.isDisplayContentKey = true;
      final result = I18nKeys.example.translate();
      expect(result, 'example');
      I18nKey.isDisplayContentKey = false;
    });
  });

  group('DirectusI18nConfig', () {
    test('should create config with required parameters', () {
      final config = DirectusI18nConfig(
        baseUrl: 'https://test.com',
        accessToken: 'test-token',
      );

      expect(config.baseUrl, 'https://test.com');
      expect(config.accessToken, 'test-token');
      expect(config.collectionName, 'app_contents');
      expect(config.isProduction, true);
      expect(config.cacheEnabled, true);
    });

    test('should create config with custom parameters', () {
      final config = DirectusI18nConfig(
        baseUrl: 'https://test.com',
        accessToken: 'test-token',
        collectionName: 'custom_collection',
        isProduction: false,
        cacheEnabled: false,
      );

      expect(config.collectionName, 'custom_collection');
      expect(config.isProduction, false);
      expect(config.cacheEnabled, false);
    });

    test('should copy with new values', () {
      final original = DirectusI18nConfig(
        baseUrl: 'https://test.com',
        accessToken: 'test-token',
      );

      final copied = original.copyWith(
        baseUrl: 'https://new-test.com',
      );

      expect(copied.baseUrl, 'https://new-test.com');
      expect(copied.accessToken, 'test-token');
    });
  });
}

