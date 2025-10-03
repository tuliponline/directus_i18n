import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

/// Example showing how to use Dynamic I18n without enum generation
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Dynamic I18n Service
  await DynamicI18nService.init(
    baseUrl: 'https://your-directus-instance.com',
    accessToken: 'your-access-token',
    collectionName: 'app_contents',
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic I18n Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic I18n Example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Method 1: Using extension on String
            Text('Method 1 - String Extension:'),
            SizedBox(height: 8),
            Text('welcome'.tr()), // Uses key 'welcome'
            Text('welcome_user'.tr(params: {'name': 'John'})), // With parameters
            Text('nonexistent_key'.tr(fallback: 'Fallback text')), // With fallback
            SizedBox(height: 16),
            
            // Method 2: Using context extension
            Text('Method 2 - Context Extension:'),
            SizedBox(height: 8),
            Text(context.tr('welcome')),
            Text(context.tr('welcome_user', params: {'name': 'Jane'})),
            SizedBox(height: 16),
            
            // Method 3: Using DynamicI18nText widget
            Text('Method 3 - DynamicI18nText Widget:'),
            SizedBox(height: 8),
            DynamicI18nText('welcome'),
            DynamicI18nText(
              'welcome_user',
              params: {'name': 'Bob'},
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            
            // Method 4: Using DynamicI18nButton
            Text('Method 4 - DynamicI18nButton:'),
            SizedBox(height: 8),
            DynamicI18nButton(
              'login',
              onPressed: () => print('Login pressed'),
            ),
            SizedBox(height: 8),
            DynamicI18nButton(
              'register',
              onPressed: () => print('Register pressed'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
              ),
            ),
            SizedBox(height: 16),
            
            // Method 5: Check if key exists
            Text('Method 5 - Key Validation:'),
            SizedBox(height: 8),
            Text('Key "welcome" exists: ${'welcome'.hasTranslation}'),
            Text('Key "nonexistent" exists: ${'nonexistent'.hasTranslation}'),
            SizedBox(height: 16),
            
            // Method 6: Refresh keys button
            ElevatedButton(
              onPressed: () async {
                await DynamicI18nService.refreshKeys();
                print('Keys refreshed!');
              },
              child: Text('Refresh Keys from Directus'),
            ),
          ],
        ),
      ),
    );
  }
}
