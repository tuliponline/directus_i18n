#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Script to setup directus_i18n in a new Flutter project
/// This script automates the integration process
/// 
/// Usage:
/// 1. Run: dart run scripts/setup_new_project.dart
/// 2. Follow the prompts to configure your project

void main() async {
  print('🚀 Directus I18n Project Setup');
  print('==============================');
  print('');

  // Check if we're in a Flutter project
  if (!File('pubspec.yaml').existsSync()) {
    print('❌ Error: Not in a Flutter project directory');
    print('Please run this script from your Flutter project root');
    exit(1);
  }

  // Get project information
  final projectName = await _getProjectName();
  final directusUrl = await _getDirectusUrl();
  final accessToken = await _getAccessToken();
  final collectionName = await _getCollectionName();
  final enumName = await _getEnumName(projectName);

  print('');
  print('📋 Configuration Summary:');
  print('Project Name: $projectName');
  print('Directus URL: $directusUrl');
  print('Collection: $collectionName');
  print('Enum Name: $enumName');
  print('');

  // Confirm setup
  final confirm = await _confirmSetup();
  if (!confirm) {
    print('Setup cancelled.');
    exit(0);
  }

  // Start setup process
  await _setupProject(
    projectName: projectName,
    directusUrl: directusUrl,
    accessToken: accessToken,
    collectionName: collectionName,
    enumName: enumName,
  );

  print('');
  print('✅ Setup completed successfully!');
  print('');
  print('Next steps:');
  print('1. Run: flutter pub get');
  print('2. Update your main.dart file');
  print('3. Run: dart run scripts/auto_generate_enum.dart');
  print('4. Start using i18n in your app!');
}

Future<String> _getProjectName() async {
  stdout.write('Enter your project name (e.g., MyApp): ');
  final input = stdin.readLineSync()?.trim();
  if (input == null || input.isEmpty) {
    print('❌ Project name is required');
    exit(1);
  }
  return input;
}

Future<String> _getDirectusUrl() async {
  stdout.write('Enter your Directus URL (e.g., https://your-directus.com): ');
  final input = stdin.readLineSync()?.trim();
  if (input == null || input.isEmpty) {
    print('❌ Directus URL is required');
    exit(1);
  }
  return input;
}

Future<String> _getAccessToken() async {
  stdout.write('Enter your Directus access token: ');
  final input = stdin.readLineSync()?.trim();
  if (input == null || input.isEmpty) {
    print('❌ Access token is required');
    exit(1);
  }
  return input;
}

Future<String> _getCollectionName() async {
  stdout.write('Enter collection name (default: app_contents): ');
  final input = stdin.readLineSync()?.trim();
  return (input?.isEmpty ?? true) ? 'app_contents' : input!;
}

Future<String> _getEnumName(String projectName) async {
  final defaultName = '${projectName}I18nKeys';
  stdout.write('Enter enum name (default: $defaultName): ');
  final input = stdin.readLineSync()?.trim();
  return (input?.isEmpty ?? true) ? defaultName : input!;
}

Future<bool> _confirmSetup() async {
  stdout.write('Do you want to proceed with the setup? (y/N): ');
  final input = stdin.readLineSync()?.trim().toLowerCase();
  return input == 'y' || input == 'yes';
}

Future<void> _setupProject({
  required String projectName,
  required String directusUrl,
  required String accessToken,
  required String collectionName,
  required String enumName,
}) async {
  print('🔄 Setting up project...');

  // 1. Create .env file
  await _createEnvFile(
    directusUrl: directusUrl,
    accessToken: accessToken,
    collectionName: collectionName,
    enumName: enumName,
  );

  // 2. Update pubspec.yaml
  await _updatePubspecYaml();

  // 3. Create generated directory
  await _createGeneratedDirectory();

  // 4. Create main.dart template
  await _createMainDartTemplate(enumName);

  // 5. Create i18n config file
  await _createI18nConfigFile(enumName);

  // 6. Create example usage file
  await _createExampleUsageFile(enumName);

  // 7. Create Makefile
  await _createMakefile();

  // 8. Create .gitignore entries
  await _updateGitignore();

  print('✅ Project setup completed!');
}

Future<void> _createEnvFile({
  required String directusUrl,
  required String accessToken,
  required String collectionName,
  required String enumName,
}) async {
  print('📝 Creating .env file...');
  
  final envContent = '''
# Directus I18n Configuration
DIRECTUS_BASE_URL=$directusUrl
DIRECTUS_ACCESS_TOKEN=$accessToken
DIRECTUS_COLLECTION_NAME=$collectionName
I18N_ENUM_NAME=$enumName
''';

  await File('.env').writeAsString(envContent);
  print('✅ .env file created');
}

Future<void> _updatePubspecYaml() async {
  print('📝 Updating pubspec.yaml...');
  
  final pubspecFile = File('pubspec.yaml');
  final content = await pubspecFile.readAsString();
  
  // Check if directus_i18n is already added
  if (content.contains('directus_i18n:')) {
    print('⚠️  directus_i18n already exists in pubspec.yaml');
    return;
  }
  
  // Add dependencies
  final updatedContent = content.replaceAll(
    'dependencies:',
    '''dependencies:
  directus_i18n:
    path: packages/directus_i18n  # Update path as needed
  flutter_dotenv: ^5.1.0''',
  );
  
  await pubspecFile.writeAsString(updatedContent);
  print('✅ pubspec.yaml updated');
}

Future<void> _createGeneratedDirectory() async {
  print('📁 Creating generated directory...');
  
  final dir = Directory('lib/generated');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  
  // Create .gitkeep file
  await File('lib/generated/.gitkeep').writeAsString('');
  print('✅ Generated directory created');
}

Future<void> _createMainDartTemplate(String enumName) async {
  print('📝 Creating main.dart template...');
  
  final mainDartContent = '''import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Combined I18n Service
  await CombinedI18nService.init(
    baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
    accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
    collectionName: dotenv.env['DIRECTUS_COLLECTION_NAME'] ?? 'app_contents',
    enumName: dotenv.env['I18N_ENUM_NAME'] ?? '$enumName',
    autoGenerateEnum: true,
    enableDynamicFallback: true,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Example usage
            Text('welcome'.tr()),
            Text(CombinedI18nService.translate('welcome_user', params: {'name': 'John'})),
            DynamicI18nText('welcome'),
          ],
        ),
      ),
    );
  }
}
''';

  // Check if main.dart already exists
  if (File('lib/main.dart').existsSync()) {
    // Create backup
    await File('lib/main.dart.backup').writeAsString(await File('lib/main.dart').readAsString());
    print('⚠️  main.dart already exists, backup created as main.dart.backup');
  }
  
  await File('lib/main.dart').writeAsString(mainDartContent);
  print('✅ main.dart template created');
}

Future<void> _createI18nConfigFile(String enumName) async {
  print('📝 Creating i18n config file...');
  
  final configContent = '''// I18n Configuration
class I18nConfig {
  static const String baseUrl = String.fromEnvironment(
    'DIRECTUS_BASE_URL',
    defaultValue: 'https://your-directus.com',
  );
  
  static const String accessToken = String.fromEnvironment(
    'DIRECTUS_ACCESS_TOKEN',
    defaultValue: 'your-token',
  );
  
  static const String collectionName = String.fromEnvironment(
    'DIRECTUS_COLLECTION_NAME',
    defaultValue: 'app_contents',
  );
  
  static const String enumName = String.fromEnvironment(
    'I18N_ENUM_NAME',
    defaultValue: '$enumName',
  );
}
''';

  await File('lib/config/i18n_config.dart').writeAsString(configContent);
  print('✅ i18n config file created');
}

Future<void> _createExampleUsageFile(String enumName) async {
  print('📝 Creating example usage file...');
  
  final exampleContent = '''// Example usage of Directus I18n
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

class I18nExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('I18n Examples'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('I18n Usage Examples', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            
            // Method 1: String extension
            Text('Method 1 - String Extension:'),
            Text('welcome'.tr()),
            Text('welcome_user'.tr(params: {'name': 'John'})),
            SizedBox(height: 16),
            
            // Method 2: Hybrid service
            Text('Method 2 - Hybrid Service:'),
            Text(CombinedI18nService.translate('welcome')),
            Text(CombinedI18nService.translate('welcome_user', params: {'name': 'Jane'})),
            SizedBox(height: 16),
            
            // Method 3: DynamicI18nText widget
            Text('Method 3 - DynamicI18nText Widget:'),
            DynamicI18nText('welcome'),
            DynamicI18nText('welcome_user', params: {'name': 'Bob'}),
            SizedBox(height: 16),
            
            // Method 4: DynamicI18nButton
            Text('Method 4 - DynamicI18nButton:'),
            DynamicI18nButton('login', onPressed: () {}),
            SizedBox(height: 16),
            
            // Status information
            Text('Status Information:'),
            Text('Has generated enum: ${CombinedI18nService.hasGeneratedEnum()}'),
            Text('Dynamic keys count: ${CombinedI18nService.getAllKeys().length}'),
          ],
        ),
      ),
    );
  }
}
''';

  await File('lib/examples/i18n_example.dart').writeAsString(exampleContent);
  print('✅ example usage file created');
}

Future<void> _createMakefile() async {
  print('📝 Creating Makefile...');
  
  final makefileContent = '''# Makefile for Directus I18n

.PHONY: i18n-generate i18n-clean i18n-refresh i18n-status

# Generate i18n enum
i18n-generate:
	@echo "🔄 Generating i18n enum..."
	@dart run packages/directus_i18n/scripts/auto_generate_enum.dart
	@echo "✅ I18n enum generated successfully!"

# Clean generated i18n files
i18n-clean:
	@echo "🧹 Cleaning generated i18n files..."
	@rm -rf lib/generated/
	@echo "✅ I18n files cleaned!"

# Refresh i18n (clean + generate)
i18n-refresh: i18n-clean i18n-generate
	@echo "🔄 I18n refreshed successfully!"

# Check i18n status
i18n-status:
	@echo "📊 I18n Status:"
	@echo "Generated directory: $$(ls -la lib/generated/ 2>/dev/null || echo 'Not found')"
	@echo "Environment file: $$(ls -la .env 2>/dev/null || echo 'Not found')"

# Help
help:
	@echo "Available commands:"
	@echo "  i18n-generate  - Generate i18n enum from Directus"
	@echo "  i18n-clean     - Clean generated i18n files"
	@echo "  i18n-refresh   - Clean and regenerate i18n files"
	@echo "  i18n-status    - Check i18n status"
	@echo "  help           - Show this help message"
''';

  await File('Makefile').writeAsString(makefileContent);
  print('✅ Makefile created');
}

Future<void> _updateGitignore() async {
  print('📝 Updating .gitignore...');
  
  final gitignoreFile = File('.gitignore');
  String content = '';
  
  if (await gitignoreFile.exists()) {
    content = await gitignoreFile.readAsString();
  }
  
  // Add i18n related entries if not already present
  final i18nEntries = '''
# Directus I18n
.env
lib/generated/
*.backup
''';

  if (!content.contains('# Directus I18n')) {
    content += i18nEntries;
    await gitignoreFile.writeAsString(content);
    print('✅ .gitignore updated');
  } else {
    print('⚠️  .gitignore already contains i18n entries');
  }
}
