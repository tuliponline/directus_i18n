import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

void main() {
  // Initialize DirectusI18n
  DirectusI18nService.init(
    baseUrl: 'https://your-directus-instance.com',
    accessToken: 'your-access-token',
    collectionName: 'app_contents',
    isProduction: false, // Use draft values for testing
    navigatorKey: GlobalKey<NavigatorState>(), // Optional: for global context
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final i18nRepository = GetIt.I<DirectusI18nRepository>();

    return MaterialApp(
      title: 'Directus I18n Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: DirectusI18nLoader(i18nRepository),
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('th', 'TH'),
      ],
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Locale _currentLocale = const Locale('en', 'US');

  void _changeLanguage(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });
    // Trigger reload of translations
    FlutterI18n.refresh(context, locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(I18nKeys.example.translate(context: context)),
        actions: [
          PopupMenuButton<Locale>(
            onSelected: _changeLanguage,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: Locale('en', 'US'),
                child: Text('English'),
              ),
              const PopupMenuItem(
                value: Locale('th', 'TH'),
                child: Text('ไทย'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Translation:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(I18nKeys.example.translate(context: context)),
            const SizedBox(height: 24),
            
            const Text(
              'Translation with Parameters:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              I18nKeys.example.translate(
                context: context,
                translationParams: {
                  'name': 'John',
                  'count': '5',
                },
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Translation with Custom Fallback:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              I18nKeys.empty.translate(
                context: context,
                fallbackKey: 'Custom fallback text',
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Debug Mode (Show Keys):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Display Content Keys'),
              value: I18nKey.isDisplayContentKey,
              onChanged: (value) {
                setState(() {
                  I18nKey.isDisplayContentKey = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Text(I18nKeys.example.translate(context: context)),
          ],
        ),
      ),
    );
  }
}

