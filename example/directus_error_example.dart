import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Example showing how to use Error Code Management with your Directus structure
/// 
/// Directus Structure:
/// - language(code: 'th-TH', 'en-US', name)
/// - error_translations(id, error_code, language_code->language.code, message)
/// - error(code, translations->error_translations)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Error Code Service
  await ErrorCodeService.init(
    baseUrl: dotenv.env['DIRECTUS_BASE_URL']!,
    accessToken: dotenv.env['DIRECTUS_ACCESS_TOKEN']!,
    collectionName: 'error', // Collection name for error codes
    autoLoad: true,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Directus Error Code Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
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
  List<ErrorCode> _errorCodes = [];
  String _searchTerm = '';
  String _currentLanguage = 'th-TH';

  @override
  void initState() {
    super.initState();
    _updateStatus();
    _loadErrorCodes();
  }

  void _updateStatus() {
    setState(() {
      _status = ErrorCodeService.getStatus();
    });
  }

  Future<void> _loadErrorCodes() async {
    try {
      final errorCodes = await ErrorCodeService.getAllErrorCodes();
      setState(() {
        _errorCodes = errorCodes;
      });
    } catch (e) {
      print('Error loading error codes: $e');
    }
  }

  void _changeLanguage(String languageCode) {
    setState(() {
      _currentLanguage = languageCode;
    });
    // Note: ErrorCodeService doesn't have changeLanguage method
    // Language is handled per request using languageCode parameter
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Directus Error Codes'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _changeLanguage,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'th-TH', child: Text('ไทย')),
              PopupMenuItem(value: 'en-US', child: Text('English')),
            ],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_currentLanguage),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Information
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status Information:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Initialized: ${_status['initialized'] ?? false}'),
                Text('Total Error Codes: ${_status['totalCount'] ?? 0}'),
                Text('Current Language: ${_status['currentLanguage'] ?? 'Unknown'}'),
                Text('Available Languages: ${(_status['availableLanguages'] as List?)?.join(', ') ?? 'None'}'),
              ],
            ),
          ),
          
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Error Codes',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
            ),
          ),
          
          // Error Codes List
          Expanded(
            child: _buildErrorCodesList(),
          ),
          
          // Action Buttons
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showErrorDialog,
                    child: Text('Test Error Dialog'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showFormValidation,
                    child: Text('Form Validation'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCodesList() {
    if (_errorCodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading error codes...'),
          ],
        ),
      );
    }

    final filteredCodes = _errorCodes.where((errorCode) {
      return errorCode.code.toLowerCase().contains(_searchTerm.toLowerCase()) ||
             (errorCode.getLocalizedMessage(languageCode: _currentLanguage)?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false);
    }).toList();

    return ListView.builder(
      itemCount: filteredCodes.length,
      itemBuilder: (context, index) {
        final errorCode = filteredCodes[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: _getSeverityIcon(errorCode.severity),
            title: Text(
              errorCode.code,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorCode.getLocalizedMessage(languageCode: _currentLanguage) ?? 'No translation available'),
                if (errorCode.severity != null)
                  Chip(
                    label: Text(errorCode.severity!.name.toUpperCase()),
                    backgroundColor: _getSeverityColor(errorCode.severity!),
                    labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                  ),
              ],
            ),
            onTap: () => _showErrorDetails(errorCode),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }

  Widget _getSeverityIcon(ErrorSeverity? severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icon(Icons.info, color: Colors.blue);
      case ErrorSeverity.warning:
        return Icon(Icons.warning, color: Colors.orange);
      case ErrorSeverity.error:
        return Icon(Icons.error, color: Colors.red);
      case ErrorSeverity.critical:
        return Icon(Icons.dangerous, color: Colors.purple);
      default:
        return Icon(Icons.help, color: Colors.grey);
    }
  }

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.purple;
    }
  }

  void _showErrorDialog() {
    final errorCode = 'LOGIN_FAILED';
    
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(errorCode.getErrorTitle(languageCode: _currentLanguage) ?? 'Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorCode.getErrorDescription(languageCode: _currentLanguage) ?? 'An error occurred'),
            SizedBox(height: 16),
            Text('Error Code: $errorCode', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDetails(ErrorCode errorCode) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(errorCode.code),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Code: ${errorCode.code}'),
              SizedBox(height: 8),
              if (errorCode.severity != null)
                Text('Severity: ${errorCode.severity!.name}'),
              SizedBox(height: 8),
              if (errorCode.category != null)
                Text('Category: ${errorCode.category}'),
              SizedBox(height: 16),
              Text('Translations:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...errorCode.getAvailableLanguages().map((lang) => 
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text('$lang: ${errorCode.getLocalizedMessage(languageCode: lang)}'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFormValidation() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => FormValidationPage()),
    );
  }
}

class FormValidationPage extends StatefulWidget {
  @override
  _FormValidationPageState createState() => _FormValidationPageState();
}

class _FormValidationPageState extends State<FormValidationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Validation Example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'EMAIL_REQUIRED'.getErrorMessage();
                  }
                  if (!value!.contains('@')) {
                    return 'EMAIL_INVALID'.getErrorMessage();
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'PASSWORD_REQUIRED'.getErrorMessage();
                  }
                  if (value!.length < 6) {
                    return 'PASSWORD_TOO_SHORT'.getErrorMessage(
                      parameters: {'minLength': '6'}
                    );
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Simulate API call
      _simulateApiCall();
    }
  }

  void _simulateApiCall() async {
    // Simulate loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Processing...'),
          ],
        ),
      ),
    );

    // Simulate API delay
    await Future<void>.delayed(Duration(seconds: 2));
    
    Navigator.pop(context); // Close loading dialog

    // Simulate random success/failure
    final success = DateTime.now().millisecond % 2 == 0;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('LOGIN_SUCCESS'.getErrorMessage()),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Show error using error code
      _showApiError();
    }
  }

  void _showApiError() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('LOGIN_FAILED'.getErrorTitle() ?? 'Login Failed'),
        content: Text('LOGIN_FAILED'.getErrorDescription() ?? 'Please check your credentials and try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showForgotPassword();
            },
            child: Text('Forgot Password?'),
          ),
        ],
      ),
    );
  }

  void _showForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('FORGOT_PASSWORD'.getErrorTitle() ?? 'Forgot Password'),
        content: Text('FORGOT_PASSWORD'.getErrorDescription() ?? 'Please contact support for password reset.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
