import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

/// Example showing how to use Runtime Enum Generation
/// This generates enum files in the codebase without needing to release new app versions
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hybrid I18n Service (auto-generates enum)
  await HybridI18nService.init(
    baseUrl: 'https://your-directus-instance.com',
    accessToken: 'your-access-token',
    collectionName: 'app_contents',
    enumName: 'AutoI18nKeys',
    autoGenerateEnum: true,
    enableDynamicFallback: true,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Runtime Enum Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> _status = {};

  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  void _updateStatus() {
    setState(() {
      _status = HybridI18nService.getStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Runtime Enum Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshI18n,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Section
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Initialized: ${_status['initialized']}'),
                    Text('Has Generated Enum: ${_status['hasGeneratedEnum']}'),
                    Text('Dynamic Keys Count: ${_status['dynamicKeysCount']}'),
                    if (_status['enumInfo'] != null) ...[
                      Text('Enum Path: ${_status['enumInfo']['path']}'),
                      Text('Enum Exists: ${_status['enumInfo']['exists']}'),
                      if (_status['enumInfo']['lastModified'] != null)
                        Text('Last Modified: ${_status['enumInfo']['lastModified']}'),
                    ],
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Translation Examples
            Text(
              'Translation Examples',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            
            // Method 1: Using Hybrid Service
            Text('Method 1 - Hybrid Service:'),
            SizedBox(height: 4),
            Text(HybridI18nService.translate('welcome')),
            Text(HybridI18nService.translate('welcome_user', params: {'name': 'John'})),
            Text(HybridI18nService.translate('nonexistent_key', fallback: 'Fallback text')),
            
            SizedBox(height: 16),
            
            // Method 2: Using Dynamic Extension
            Text('Method 2 - Dynamic Extension:'),
            SizedBox(height: 4),
            Text('welcome'.tr()),
            Text('welcome_user'.tr(params: {'name': 'Jane'})),
            Text('nonexistent_key'.tr(fallback: 'Fallback text')),
            
            SizedBox(height: 16),
            
            // Method 3: Using DynamicI18nText
            Text('Method 3 - DynamicI18nText Widget:'),
            SizedBox(height: 4),
            DynamicI18nText('welcome'),
            DynamicI18nText(
              'welcome_user',
              params: {'name': 'Bob'},
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            
            SizedBox(height: 16),
            
            // Key Validation
            Text('Key Validation:'),
            SizedBox(height: 4),
            Text('Key "welcome" exists: ${HybridI18nService.hasKey('welcome')}'),
            Text('Key "nonexistent" exists: ${HybridI18nService.hasKey('nonexistent')}'),
            
            SizedBox(height: 16),
            
            // Available Keys
            Text('Available Keys (first 10):'),
            SizedBox(height: 4),
            ...HybridI18nService.getAllKeys().take(10).map((key) => 
              Text('  - $key', style: TextStyle(fontSize: 12))
            ),
            
            if (HybridI18nService.getAllKeys().length > 10)
              Text('  ... and ${HybridI18nService.getAllKeys().length - 10} more keys',
                   style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            
            SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: _refreshI18n,
                  child: Text('Refresh I18n'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _forceRegenerate,
                  child: Text('Force Regenerate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshI18n() async {
    try {
      await HybridI18nService.refresh();
      _updateStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('I18n refreshed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh I18n: $e')),
      );
    }
  }

  Future<void> _forceRegenerate() async {
    try {
      await AutoEnumService.forceRegenerate(
        baseUrl: 'https://your-directus-instance.com',
        accessToken: 'your-access-token',
        collectionName: 'app_contents',
        enumName: 'AutoI18nKeys',
      );
      _updateStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enum regenerated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to regenerate enum: $e')),
      );
    }
  }
}
