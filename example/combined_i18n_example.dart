import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Example showing how to use both I18n content and Error codes together
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
    collectionName: 'app_contents', // I18n content collection
    enumName: 'AppI18nKeys',
    autoGenerateEnum: true,
    enableDynamicFallback: true,
  );
  
  // Initialize Error Code Service (for error messages)
  await ErrorCodeService.init(
    baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
    accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
    collectionName: 'error_codes', // Error codes collection
    autoLoad: true,
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Combined I18n & Error Codes Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> _i18nStatus = {};
  Map<String, dynamic> _errorStatus = {};
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  void _updateStatus() {
    setState(() {
      _i18nStatus = HybridI18nService.getStatus();
      _errorStatus = ErrorCodeService.getStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Combined I18n & Error Codes'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshAll,
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
                    Text('I18n Initialized: ${_i18nStatus['initialized']}'),
                    Text('I18n Keys Count: ${_i18nStatus['dynamicKeysCount']}'),
                    Text('Error Codes Initialized: ${_errorStatus['initialized']}'),
                    Text('Error Codes Count: ${_errorStatus['errorCodesCount']}'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Language Selection
            Text('Select Language:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _changeLanguage('en'),
                  child: Text('English'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedLanguage == 'en' ? Colors.blue : null,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _changeLanguage('th'),
                  child: Text('ไทย'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedLanguage == 'th' ? Colors.blue : null,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // I18n Content Examples
            Text(
              'I18n Content Examples',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            
            // Method 1: String Extension
            Text('Method 1 - String Extension:'),
            SizedBox(height: 4),
            Text('welcome'.tr()),
            Text('welcome_user'.tr(params: {'name': 'John'})),
            Text('login_button'.tr()),
            
            SizedBox(height: 16),
            
            // Method 2: Hybrid Service
            Text('Method 2 - Hybrid Service:'),
            SizedBox(height: 4),
            Text(HybridI18nService.translate('welcome')),
            Text(HybridI18nService.translate('welcome_user', params: {'name': 'Jane'})),
            Text(HybridI18nService.translate('login_button')),
            
            SizedBox(height: 16),
            
            // Method 3: DynamicI18nText Widget
            Text('Method 3 - DynamicI18nText Widget:'),
            SizedBox(height: 4),
            DynamicI18nText('welcome'),
            DynamicI18nText('welcome_user', params: {'name': 'Bob'}),
            DynamicI18nText('login_button'),
            
            SizedBox(height: 16),
            
            // Error Code Examples
            Text(
              'Error Code Examples',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            
            // Method 1: String Extension
            Text('Method 1 - String Extension:'),
            SizedBox(height: 4),
            Text('NETWORK_ERROR'.getErrorMessage()),
            Text('AUTH_FAILED'.getErrorMessage()),
            Text('VALIDATION_ERROR'.getErrorMessage(parameters: {'field': 'email'})),
            
            SizedBox(height: 16),
            
            // Method 2: Context Extension
            Text('Method 2 - Context Extension:'),
            SizedBox(height: 4),
            Text(context.getErrorMessage('NETWORK_ERROR')),
            Text(context.getErrorMessage('AUTH_FAILED')),
            Text(context.getErrorMessage('VALIDATION_ERROR')),
            
            SizedBox(height: 16),
            
            // Method 3: ErrorCodeWidget
            Text('Method 3 - ErrorCodeWidget:'),
            SizedBox(height: 4),
            ErrorCodeWidget('NETWORK_ERROR', showCode: true),
            ErrorMessageWidget('AUTH_FAILED'),
            ErrorCardWidget('VALIDATION_ERROR', showCode: true),
            
            SizedBox(height: 16),
            
            // Combined Usage Examples
            Text(
              'Combined Usage Examples',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            
            // Login Form with both I18n and Error handling
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login Form Example',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    
                    // Form fields with I18n labels
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'email_field'.tr(),
                        hintText: 'email_hint'.tr(),
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'password_field'.tr(),
                        hintText: 'password_hint'.tr(),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 16),
                    
                    // Buttons with I18n text
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _simulateLogin(),
                          child: Text('login_button'.tr()),
                        ),
                        SizedBox(width: 8),
                        TextButton(
                          onPressed: () => _simulateForgotPassword(),
                          child: Text('forgot_password'.tr()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Error Handling Example
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Error Handling Example',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    
                    ElevatedButton(
                      onPressed: () => _simulateNetworkError(),
                      child: Text('Simulate Network Error'),
                    ),
                    SizedBox(height: 8),
                    
                    ElevatedButton(
                      onPressed: () => _simulateValidationError(),
                      child: Text('Simulate Validation Error'),
                    ),
                    SizedBox(height: 8),
                    
                    ElevatedButton(
                      onPressed: () => _simulateAuthError(),
                      child: Text('Simulate Auth Error'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    // In a real app, you would change the app's locale here
  }

  Future<void> _refreshAll() async {
    try {
      await HybridI18nService.refresh();
      await ErrorCodeService.refresh();
      _updateStatus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All services refreshed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh services: $e')),
      );
    }
  }

  void _simulateLogin() {
    // Simulate login process
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('login_success'.tr())),
    );
  }

  void _simulateForgotPassword() {
    // Simulate forgot password
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('forgot_password_sent'.tr())),
    );
  }

  void _simulateNetworkError() {
    // Simulate network error
    final errorMessage = 'NETWORK_ERROR'.getErrorMessage();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _simulateValidationError() {
    // Simulate validation error
    final errorMessage = 'VALIDATION_ERROR'.getErrorMessage(
      parameters: {'field': 'email'},
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _simulateAuthError() {
    // Simulate auth error
    final errorMessage = 'AUTH_FAILED'.getErrorMessage();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}
