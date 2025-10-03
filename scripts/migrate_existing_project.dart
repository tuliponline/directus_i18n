#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Script to migrate existing Flutter project to use directus_i18n
/// This script helps migrate from existing i18n solutions
/// 
/// Usage:
/// 1. Run: dart run scripts/migrate_existing_project.dart
/// 2. Follow the prompts to migrate your project

void main() async {
  print('🔄 Directus I18n Migration Tool');
  print('===============================');
  print('');

  // Check if we're in a Flutter project
  if (!File('pubspec.yaml').existsSync()) {
    print('❌ Error: Not in a Flutter project directory');
    print('Please run this script from your Flutter project root');
    exit(1);
  }

  // Detect existing i18n solution
  final existingSolution = await _detectExistingI18n();
  print('Detected i18n solution: $existingSolution');
  print('');

  // Get migration preferences
  final migrationType = await _getMigrationType();
  final directusUrl = await _getDirectusUrl();
  final accessToken = await _getAccessToken();
  final collectionName = await _getCollectionName();
  final enumName = await _getEnumName();

  print('');
  print('📋 Migration Summary:');
  print('From: $existingSolution');
  print('To: Directus I18n ($migrationType)');
  print('Directus URL: $directusUrl');
  print('Collection: $collectionName');
  print('Enum Name: $enumName');
  print('');

  // Confirm migration
  final confirm = await _confirmMigration();
  if (!confirm) {
    print('Migration cancelled.');
    exit(0);
  }

  // Start migration process
  await _migrateProject(
    existingSolution: existingSolution,
    migrationType: migrationType,
    directusUrl: directusUrl,
    accessToken: accessToken,
    collectionName: collectionName,
    enumName: enumName,
  );

  print('');
  print('✅ Migration completed successfully!');
  print('');
  print('Next steps:');
  print('1. Review the migration changes');
  print('2. Run: flutter pub get');
  print('3. Test your app');
  print('4. Update any remaining hardcoded strings');
}

Future<String> _detectExistingI18n() async {
  final pubspecFile = File('pubspec.yaml');
  final content = await pubspecFile.readAsString();
  
  if (content.contains('flutter_i18n:')) {
    return 'flutter_i18n';
  } else if (content.contains('intl:')) {
    return 'intl';
  } else if (content.contains('easy_localization:')) {
    return 'easy_localization';
  } else if (content.contains('i18n:')) {
    return 'custom_i18n';
  } else {
    return 'none';
  }
}

Future<String> _getMigrationType() async {
  print('Select migration type:');
  print('1. Full migration (replace existing i18n)');
  print('2. Hybrid migration (keep existing + add directus_i18n)');
  print('3. Gradual migration (migrate step by step)');
  
  stdout.write('Enter choice (1-3): ');
  final input = stdin.readLineSync()?.trim();
  
  switch (input) {
    case '1':
      return 'full';
    case '2':
      return 'hybrid';
    case '3':
      return 'gradual';
    default:
      print('Invalid choice, defaulting to gradual migration');
      return 'gradual';
  }
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

Future<String> _getEnumName() async {
  stdout.write('Enter enum name (default: ProjectI18nKeys): ');
  final input = stdin.readLineSync()?.trim();
  return (input?.isEmpty ?? true) ? 'ProjectI18nKeys' : input!;
}

Future<bool> _confirmMigration() async {
  stdout.write('Do you want to proceed with the migration? (y/N): ');
  final input = stdin.readLineSync()?.trim().toLowerCase();
  return input == 'y' || input == 'yes';
}

Future<void> _migrateProject({
  required String existingSolution,
  required String migrationType,
  required String directusUrl,
  required String accessToken,
  required String collectionName,
  required String enumName,
}) async {
  print('🔄 Starting migration...');

  // 1. Create .env file
  await _createEnvFile(
    directusUrl: directusUrl,
    accessToken: accessToken,
    collectionName: collectionName,
    enumName: enumName,
  );

  // 2. Update pubspec.yaml
  await _updatePubspecYaml(existingSolution);

  // 3. Create generated directory
  await _createGeneratedDirectory();

  // 4. Create migration guide
  await _createMigrationGuide(existingSolution, migrationType);

  // 5. Create example migration
  await _createExampleMigration(existingSolution);

  // 6. Update .gitignore
  await _updateGitignore();

  print('✅ Migration setup completed!');
}

Future<void> _createEnvFile({
  required String directusUrl,
  required String accessToken,
  required String collectionName,
  required String enumName,
}) async {
  print('📝 Creating .env file...');
  
  final envContent = '''# Directus I18n Configuration
DIRECTUS_BASE_URL=$directusUrl
DIRECTUS_ACCESS_TOKEN=$accessToken
DIRECTUS_COLLECTION_NAME=$collectionName
I18N_ENUM_NAME=$enumName
''';

  await File('.env').writeAsString(envContent);
  print('✅ .env file created');
}

Future<void> _updatePubspecYaml(String existingSolution) async {
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
  
  await File('lib/generated/.gitkeep').writeAsString('');
  print('✅ Generated directory created');
}

Future<void> _createMigrationGuide(String existingSolution, String migrationType) async {
  print('📝 Creating migration guide...');
  
  final guideContent = _generateMigrationGuide(existingSolution, migrationType);
  await File('MIGRATION_GUIDE.md').writeAsString(guideContent);
  print('✅ Migration guide created');
}

String _generateMigrationGuide(String existingSolution, String migrationType) {
  return '''# Migration Guide

## Migration Summary

- **From**: $existingSolution
- **To**: Directus I18n
- **Type**: $migrationType migration

## Migration Steps

### 1. Update main.dart

Add Directus I18n initialization:

\`\`\`dart
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Directus I18n
  await CombinedI18nService.init(
    baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
    accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
    collectionName: dotenv.env['DIRECTUS_COLLECTION_NAME'] ?? 'app_contents',
    enumName: dotenv.env['I18N_ENUM_NAME'] ?? 'ProjectI18nKeys',
    autoGenerateEnum: true,
    enableDynamicFallback: true,
  );
  
  runApp(MyApp());
}
\`\`\`

### 2. Update Translation Usage

${_getMigrationExamples(existingSolution)}

### 3. Generate I18n Enum

\`\`\`bash
# Generate enum from Directus
dart run packages/directus_i18n/scripts/auto_generate_enum.dart

# Or use Makefile
make i18n-generate
\`\`\`

### 4. Test Migration

\`\`\`bash
flutter test
flutter run
\`\`\`

## Migration Types

### Full Migration
- Replace all existing i18n code
- Use Directus I18n exclusively
- Recommended for new projects

### Hybrid Migration
- Keep existing i18n for critical parts
- Add Directus I18n for new content
- Gradual transition approach

### Gradual Migration
- Migrate one feature at a time
- Keep both systems running
- Lowest risk approach

## Troubleshooting

### Common Issues

1. **Translation not found**
   - Check Directus connection
   - Verify access token
   - Run enum generation

2. **Build errors**
   - Run \`flutter pub get\`
   - Check import statements
   - Verify environment variables

3. **Performance issues**
   - Enable caching
   - Limit enum generation frequency
   - Use dynamic fallback

### Debug Commands

\`\`\`bash
# Check status
make i18n-status

# Generate enum
make i18n-generate

# Clean and regenerate
make i18n-refresh
\`\`\`

## Next Steps

1. Review the migration changes
2. Test your app thoroughly
3. Update any remaining hardcoded strings
4. Consider using Shorebird for updates
''';
}

String _getMigrationExamples(String existingSolution) {
  switch (existingSolution) {
    case 'flutter_i18n':
      return '''
**From flutter_i18n:**
\`\`\`dart
// Before
Text(FlutterI18n.translate(context, 'welcome'))

// After
Text('welcome'.tr())
Text(CombinedI18nService.translate('welcome'))
\`\`\`
''';
    case 'intl':
      return '''
**From intl:**
\`\`\`dart
// Before
Text(AppLocalizations.of(context)!.welcome)

// After
Text('welcome'.tr())
Text(CombinedI18nService.translate('welcome'))
\`\`\`
''';
    case 'easy_localization':
      return '''
**From easy_localization:**
\`\`\`dart
// Before
Text('welcome'.tr())

// After (same syntax!)
Text('welcome'.tr())
Text(CombinedI18nService.translate('welcome'))
\`\`\`
''';
    default:
      return '''
**From custom i18n:**
\`\`\`dart
// Before
Text(I18n.of(context).translate('welcome'))

// After
Text('welcome'.tr())
Text(CombinedI18nService.translate('welcome'))
\`\`\`
''';
  }
}

Future<void> _createExampleMigration(String existingSolution) async {
  print('📝 Creating example migration...');
  
  final exampleContent = _generateExampleMigration(existingSolution);
  await File('lib/examples/migration_example.dart').writeAsString(exampleContent);
  print('✅ Example migration created');
}

String _generateExampleMigration(String existingSolution) {
  return '''// Migration Example for $existingSolution
import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

class MigrationExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Migration Example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Migration Examples', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            
            // Before and After examples
            Text('Before ($existingSolution):', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('// Old code here'),
            SizedBox(height: 8),
            
            Text('After (Directus I18n):', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('// New code here'),
            SizedBox(height: 16),
            
            // New usage examples
            Text('New Usage Examples:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            
            // Method 1: String extension
            Text('Method 1 - String Extension:'),
            Text('welcome'.tr()),
            Text('welcome_user'.tr(params: {'name': 'John'})),
            SizedBox(height: 8),
            
            // Method 2: Hybrid service
            Text('Method 2 - Hybrid Service:'),
            Text(CombinedI18nService.translate('welcome')),
            Text(CombinedI18nService.translate('welcome_user', params: {'name': 'Jane'})),
            SizedBox(height: 8),
            
            // Method 3: DynamicI18nText widget
            Text('Method 3 - DynamicI18nText Widget:'),
            DynamicI18nText('welcome'),
            DynamicI18nText('welcome_user', params: {'name': 'Bob'}),
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
}

Future<void> _updateGitignore() async {
  print('📝 Updating .gitignore...');
  
  final gitignoreFile = File('.gitignore');
  String content = '';
  
  if (await gitignoreFile.exists()) {
    content = await gitignoreFile.readAsString();
  }
  
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
