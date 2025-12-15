# Combined I18n & Error Codes Usage Guide

## 🎯 Overview

This guide shows how to use both I18n content and Error codes together in your Flutter application. You can manage regular content translations and error messages separately while using them seamlessly in your app.

## ✨ Benefits

- 🌍 **Separate Collections** - I18n content and error codes in different Directus collections
- 🔄 **Independent Management** - Update content and errors separately
- 📝 **Unified API** - Use both with similar syntax
- 🎯 **Type Safe** - Compile-time checking for both
- 🚀 **Shorebird Compatible** - Patch both content and errors

## 🚀 Quick Start

### 1. Setup Both Collections in Directus

#### I18n Content Collection (`contents`)
```json
{
  "key": "string",            // Content key (e.g., "welcome")
  "translations": "relation"  // Translations relation
}
```

#### Error Codes Collection (`error`)
```json
{
  "code": "string",           // Error code (e.g., "NETWORK_ERROR")
  "translations": "relation"  // Translations relation
}
```

### 2. Initialize Both Services

```dart
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize both services
  await _initializeServices();
  
  runApp(MyApp());
}

Future<void> _initializeServices() async {
  // Initialize I18n Service (for content)
  await HybridI18nService.init(
    baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
    accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
    collectionName: 'contents', // I18n content collection
    enumName: 'AppI18nKeys',
    autoGenerateEnum: true,
    enableDynamicFallback: true,
  );
  
  // Initialize Error Code Service (for error messages)
  await ErrorCodeService.init(
    baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
    accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
    collectionName: 'error', // Error codes collection
    autoLoad: true,
  );
}
```

### 2.1 Single Collection (แบบเดิม)
```dart
await HybridI18nService.init(
  baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
  accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
  collectionName: 'contents', // ใช้คอลเล็กชันเดียว
  autoGenerateEnum: true,
);
```

### 2.2 Multiple Collections (แบบใหม่)
รองรับหลายคอลเล็กชันและ prefix กัน key ชนกัน
```dart
await HybridI18nService.init(
  baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
  accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
  collections: const [
    DirectusCollectionConfig(name: 'contents', prefix: ''),
    DirectusCollectionConfig(name: 'homepage', prefix: 'homepage.'), // key = homepage.hero_title
  ],
  autoGenerateEnum: true, // รวมคีย์ทุกคอลเล็กชันก่อน generate enum
  enableDynamicFallback: true,
);
```

### 3. Use Both in Your App

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // I18n content
        Text('welcome'.tr()),
        Text('login_button'.tr()),
        
        // Error codes
        Text('NETWORK_ERROR'.getErrorMessage()),
        Text(context.getErrorMessage('AUTH_FAILED')),
        
        // Combined usage
        ElevatedButton(
          onPressed: () => _handleLogin(),
          child: Text('login_button'.tr()),
        ),
      ],
    );
  }
  
  void _handleLogin() {
    try {
      // Login logic
    } catch (e) {
      // Show error message
      final errorMessage = 'LOGIN_FAILED'.getErrorMessage();
      // Show error to user
    }
  }
}
```

## 🔧 Configuration

### Environment Variables

```bash
# .env
DIRECTUS_BASE_URL=https://your-directus.com
DIRECTUS_ACCESS_TOKEN=your-token
DIRECTUS_COLLECTION_NAME=contents
ERROR_CODES_COLLECTION_NAME=error
I18N_ENUM_NAME=AppI18nKeys
```

### Service Configuration

```dart
// I18n Service Configuration
await HybridI18nService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'contents',
  enumName: 'AppI18nKeys',
  autoGenerateEnum: true,
  enableDynamicFallback: true,
);

// Error Code Service Configuration
await ErrorCodeService.init(
  baseUrl: 'https://your-directus.com',
  accessToken: 'your-token',
  collectionName: 'error',
  autoLoad: true,
);
```

## 📱 Usage Examples

### 1. Basic Usage

```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('login_title'.tr()), // I18n content
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'email_field'.tr(), // I18n content
                hintText: 'email_hint'.tr(), // I18n content
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _handleLogin(),
              child: Text('login_button'.tr()), // I18n content
            ),
          ],
        ),
      ),
    );
  }
  
  void _handleLogin() {
    try {
      // Login logic
      _showSuccess('login_success'.tr()); // I18n content
    } catch (e) {
      // Show error message
      _showError('LOGIN_FAILED'.getErrorMessage()); // Error code
    }
  }
  
  void _showSuccess(String message) {
    // Show success message
  }
  
  void _showError(String message) {
    // Show error message
  }
}
```

### 2. Form Validation

```dart
class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'email_field'.tr(), // I18n content
              hintText: 'email_hint'.tr(), // I18n content
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'EMAIL_REQUIRED'.getErrorMessage(); // Error code
              }
              if (!value.contains('@')) {
                return 'EMAIL_INVALID'.getErrorMessage(); // Error code
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'password_field'.tr(), // I18n content
              hintText: 'password_hint'.tr(), // I18n content
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'PASSWORD_REQUIRED'.getErrorMessage(); // Error code
              }
              if (value.length < 8) {
                return 'PASSWORD_TOO_SHORT'.getErrorMessage( // Error code
                  parameters: {'minLength': '8'},
                );
              }
              return null;
            },
            obscureText: true,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('register_button'.tr()), // I18n content
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with registration
      _showSuccess('registration_success'.tr()); // I18n content
    }
  }
}
```

### 3. Error Handling

```dart
class ErrorHandler {
  static void handleError(String errorCode, {Map<String, String>? params}) {
    final errorMessage = errorCode.getErrorMessage(parameters: params);
    _showErrorDialog(errorMessage);
  }
  
  static void _showErrorDialog(String message) {
    // Show error dialog
  }
}

class ApiService {
  static Future<void> login(String email, String password) async {
    try {
      // API call
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {'email': email, 'password': password},
      );
      
      if (response.statusCode == 200) {
        // Success
        return;
      } else if (response.statusCode == 401) {
        throw Exception('AUTH_FAILED'); // Error code
      } else if (response.statusCode == 422) {
        throw Exception('VALIDATION_ERROR'); // Error code
      } else {
        throw Exception('NETWORK_ERROR'); // Error code
      }
    } catch (e) {
      if (e is Exception) {
        final errorCode = e.toString().replaceAll('Exception: ', '');
        ErrorHandler.handleError(errorCode);
      } else {
        ErrorHandler.handleError('UNKNOWN_ERROR');
      }
    }
  }
}
```

### 4. Dynamic Content Loading

```dart
class ContentPage extends StatefulWidget {
  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      // Load content from API
      await _fetchContent();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'CONTENT_LOAD_FAILED'.getErrorMessage(); // Error code
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('loading_content'.tr()), // I18n content
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContent,
              child: Text('retry_button'.tr()), // I18n content
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('content_title'.tr()), // I18n content
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'welcome_message'.tr(), // I18n content
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('content_description'.tr()), // I18n content
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showMoreInfo(),
              child: Text('more_info_button'.tr()), // I18n content
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchContent() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 2));
  }

  void _showMoreInfo() {
    // Show more info
  }
}
```

## 🔄 Advanced Usage

### 1. Custom Error Handler

```dart
class AppErrorHandler {
  static void handleError(String errorCode, {Map<String, String>? params}) {
    final errorMessage = errorCode.getErrorMessage(parameters: params);
    
    // Log error
    Logger().e('Error: $errorCode - $errorMessage');
    
    // Show appropriate UI based on error type
    if (errorCode.startsWith('NETWORK_')) {
      _showNetworkError(errorMessage);
    } else if (errorCode.startsWith('AUTH_')) {
      _showAuthError(errorMessage);
    } else if (errorCode.startsWith('VALIDATION_')) {
      _showValidationError(errorMessage);
    } else {
      _showGenericError(errorMessage);
    }
  }
  
  static void _showNetworkError(String message) {
    // Show network error UI
  }
  
  static void _showAuthError(String message) {
    // Show auth error UI
  }
  
  static void _showValidationError(String message) {
    // Show validation error UI
  }
  
  static void _showGenericError(String message) {
    // Show generic error UI
  }
}
```

### 2. Language Switching

```dart
class LanguageSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: 'en', // Current language
      items: [
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'th', child: Text('ไทย')),
      ],
      onChanged: (String? newLanguage) {
        if (newLanguage != null) {
          _changeLanguage(newLanguage);
        }
      },
    );
  }
  
  void _changeLanguage(String languageCode) {
    // Change app locale
    // Both I18n and Error codes will automatically use the new language
  }
}
```

### 3. Testing

```dart
void main() {
  group('Combined I18n & Error Codes Tests', () {
    setUp(() {
      // Mock both services
      HybridI18nService.init(
        baseUrl: 'https://mock-directus.com',
        accessToken: 'mock-token',
        autoGenerateEnum: false,
        enableDynamicFallback: true,
      );
      
      ErrorCodeService.init(
        baseUrl: 'https://mock-directus.com',
        accessToken: 'mock-token',
        autoLoad: false,
      );
    });

    test('should get i18n content', () {
      expect('welcome'.tr(), equals('Welcome!'));
    });

    test('should get error message', () {
      expect('NETWORK_ERROR'.getErrorMessage(), equals('Network connection failed'));
    });

    testWidgets('should display combined content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              Text('welcome'.tr()),
              ErrorCodeWidget('NETWORK_ERROR'),
            ],
          ),
        ),
      );
      
      expect(find.text('Welcome!'), findsOneWidget);
      expect(find.text('Network connection failed'), findsOneWidget);
    });
  });
}
```

## 📋 Best Practices

### 1. Collection Organization

```
Directus Collections:
├── contents              # I18n content
│   ├── welcome
│   ├── login_button
│   ├── error_messages
│   └── ...
└── error                 # Error codes
    ├── NETWORK_ERROR
    ├── AUTH_FAILED
    ├── VALIDATION_ERROR
    └── ...
```

### 2. Naming Conventions

```dart
// I18n content - use descriptive names
'welcome_message'.tr()
'login_button'.tr()
'email_field_label'.tr()

// Error codes - use UPPER_SNAKE_CASE
'NETWORK_ERROR'.getErrorMessage()
'AUTH_FAILED'.getErrorMessage()
'VALIDATION_ERROR'.getErrorMessage()
```

### 3. Error Handling Strategy

```dart
class AppErrorHandler {
  static void handleError(String errorCode, {Map<String, String>? params}) {
    // 1. Get localized error message
    final message = errorCode.getErrorMessage(parameters: params);
    
    // 2. Log error for debugging
    Logger().e('Error: $errorCode - $message');
    
    // 3. Show appropriate UI
    _showErrorUI(message);
  }
}
```

### 4. Performance Optimization

```dart
class AppInitializer {
  static Future<void> initialize() async {
    // Initialize both services in parallel
    await Future.wait([
      HybridI18nService.init(/* config */),
      ErrorCodeService.init(/* config */),
    ]);
  }
}
```

## 🚀 Shorebird Integration

### What Can Be Patched

✅ **Can Patch:**
- I18n content translations
- Error code messages
- UI layout changes
- New content and error codes

❌ **Cannot Patch:**
- Core service initialization changes
- API endpoint changes
- Major structural changes

### Patch Workflow

1. **Update content in Directus**
   - Update I18n content in `contents` collection
   - Update error codes in `error` collection

2. **Refresh services**
   ```dart
   await HybridI18nService.refresh();
   await ErrorCodeService.refresh();
   ```

3. **Create Shorebird patch**
   ```bash
   shorebird patch android
   shorebird patch ios
   ```

## 🆘 Troubleshooting

### Common Issues

**Q: I18n content not loading**
A: Check Directus connection and `contents` collection

**Q: Error codes not loading**
A: Check Directus connection and `error` collection

**Q: Translations not working**
A: Ensure translations are published in Directus

**Q: Performance issues**
A: Enable caching and limit refresh frequency

### Debug Commands

```dart
// Check I18n status
print('I18n Status: ${HybridI18nService.getStatus()}');

// Check Error Code status
print('Error Code Status: ${ErrorCodeService.getStatus()}');

// Test translations
print('Welcome: ${'welcome'.tr()}');
print('Network Error: ${'NETWORK_ERROR'.getErrorMessage()}');
```

## 🔗 Related Resources

- [Integration Guide](INTEGRATION_GUIDE.md)
- [Runtime Enum Guide](RUNTIME_ENUM_GUIDE.md)
- [Dynamic I18n Guide](DYNAMIC_I18N_GUIDE.md)
- [Error Code Guide](ERROR_CODE_GUIDE.md)
- [Example App](example/combined_i18n_example.dart)
