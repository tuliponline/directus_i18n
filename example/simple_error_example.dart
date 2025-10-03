import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

/// Simple example showing basic Error Code usage with your Directus structure
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Error Code Service with your Directus structure
  await ErrorCodeService.init(
    baseUrl: 'https://your-directus-instance.com',
    accessToken: 'your-access-token',
    collectionName: 'error', // Your error collection name
    autoLoad: true,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Error Code Example',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error Code Demo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Example 1: Basic error message
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Example 1: Basic Error Message', 
                         style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('LOGIN_FAILED'.getErrorMessage()),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Example 2: Error with parameters
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Example 2: Error with Parameters', 
                         style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('PASSWORD_TOO_SHORT'.getErrorMessage(
                      parameters: {'minLength': '6'}
                    )),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Example 3: Error dialog
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Example 3: Error Dialog', 
                         style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showErrorDialog(context),
                      child: Text('Show Error Dialog'),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Example 4: Form validation
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Example 4: Form Validation', 
                         style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _showForm(context),
                      child: Text('Show Form Validation'),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Example 5: Status information
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Example 5: Service Status', 
                         style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final status = ErrorCodeService.getStatus();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Initialized: ${status['initialized']}'),
                            Text('Total Error Codes: ${status['totalCount']}'),
                            Text('Current Language: ${status['currentLanguage']}'),
                            Text('Available Languages: ${(status['availableLanguages'] as List?)?.join(', ') ?? 'None'}'),
                          ],
                        );
                      },
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

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('LOGIN_FAILED'.getErrorTitle() ?? 'Login Failed'),
        content: Text('LOGIN_FAILED'.getErrorDescription() ?? 'Please check your credentials and try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormPage()),
    );
  }
}

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Validation'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('FORM_VALID'.getErrorMessage()),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
