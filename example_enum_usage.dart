import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'lib/generated/AppI18nKeys.dart'; // Import generated enum

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize HybridI18nService with autoGenerateEnum: true
  await HybridI18nService.init(
    baseUrl: 'https://cms.monster-fishing.com',
    accessToken: '', // Empty for public access
    collectionName: 'contents',
    enumName: 'AppI18nKeys',
    autoGenerateEnum: true,
    enableDynamicFallback: true,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enum Usage Example',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enum vs String Extension Comparison'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Using Generated Enum (Type Safe):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(AppI18nKeys.keywellcom.translate()), // Type safe!
            SizedBox(height: 16),
            
            Text(
              '2. Using String Extension (Dynamic):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('wellcom'.tr()), // Dynamic, no type safety
            SizedBox(height: 16),
            
            Text(
              '3. Using Hybrid Service:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(HybridI18nService.translate('wellcom')),
            SizedBox(height: 16),
            
            Text(
              '4. Enum Benefits:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Compile-time checking'),
            Text('• IDE autocomplete'),
            Text('• Refactoring support'),
            Text('• No typos in keys'),
            SizedBox(height: 16),
            
            Text(
              '5. Adding New Content:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('When you add new content in Directus:'),
            Text('1. Add new key in Directus'),
            Text('2. Run: dart run scripts/auto_generate_enum.dart'),
            Text('3. Use new enum: AppI18nKeys.newKey.translate()'),
            Text('4. Create Shorebird patch (no app store release needed!)'),
          ],
        ),
      ),
    );
  }
}
