import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

/// Example showing how to use Error Code Management
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Error Code Service
  await ErrorCodeService.init(
    baseUrl: 'https://your-directus-instance.com',
    accessToken: 'your-access-token',
    collectionName: 'error_codes',
    autoLoad: true,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error Code Example',
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

  void _loadErrorCodes() {
    setState(() {
      _errorCodes = ErrorCodeService.getAllErrorCodes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error Code Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshErrorCodes,
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
                    Text('Error Codes Count: ${_status['errorCodesCount']}'),
                    Text('Translations Count: ${_status['translationsCount']}'),
                    Text('Collection: ${_status['collectionName']}'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Search Section
            TextField(
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
            Text('AUTH_FAILED'.getErrorTitle()),
            Text('VALIDATION_ERROR'.getErrorMessage(parameters: {'field': 'email'})),
            
            SizedBox(height: 16),
            
            // Method 2: Context Extension
            Text('Method 2 - Context Extension:'),
            SizedBox(height: 4),
            Text(context.getErrorMessage('NETWORK_ERROR')),
            Text(context.getErrorTitle('AUTH_FAILED')),
            Text(context.getErrorDescription('VALIDATION_ERROR')),
            
            SizedBox(height: 16),
            
            // Method 3: ErrorCodeWidget
            Text('Method 3 - ErrorCodeWidget:'),
            SizedBox(height: 4),
            ErrorCodeWidget(
              'NETWORK_ERROR',
              showCode: true,
              showTitle: true,
              showDescription: true,
            ),
            
            SizedBox(height: 8),
            
            ErrorMessageWidget(
              'AUTH_FAILED',
              showSeverityIcon: true,
              showSeverityColor: true,
            ),
            
            SizedBox(height: 8),
            
            ErrorCardWidget(
              'VALIDATION_ERROR',
              parameters: {'field': 'email'},
              showCode: true,
              showTitle: true,
              showDescription: true,
              showAction: true,
            ),
            
            SizedBox(height: 16),
            
            // Error List
            Text(
              'Available Error Codes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            
            Expanded(
              child: ListView.builder(
                itemCount: _errorCodes.length,
                itemBuilder: (context, index) {
                  final errorCode = _errorCodes[index];
                  final isVisible = _searchTerm.isEmpty ||
                      errorCode.code.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                      (errorCode.message?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false);
                  
                  if (!isVisible) return SizedBox.shrink();
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        _getSeverityIcon(errorCode.severity),
                        color: _getSeverityColor(errorCode.severity),
                      ),
                      title: Text(errorCode.code),
                      subtitle: Text(errorCode.message ?? 'No message'),
                      trailing: Chip(
                        label: Text(errorCode.severity.displayName),
                        backgroundColor: _getSeverityColor(errorCode.severity).withOpacity(0.2),
                      ),
                      onTap: () => _showErrorDetails(errorCode),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshErrorCodes() async {
    try {
      await ErrorCodeService.refresh();
      _updateStatus();
      _loadErrorCodes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error codes refreshed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to refresh error codes: $e')),
      );
    }
  }

  void _showErrorDetails(ErrorCode errorCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error Code Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${errorCode.code}'),
            SizedBox(height: 8),
            Text('Severity: ${errorCode.severity.displayName}'),
            Text('Category: ${errorCode.category.displayName}'),
            if (errorCode.message != null) ...[
              SizedBox(height: 8),
              Text('Message: ${errorCode.message}'),
            ],
            if (errorCode.title != null) ...[
              SizedBox(height: 8),
              Text('Title: ${errorCode.title}'),
            ],
            if (errorCode.description != null) ...[
              SizedBox(height: 8),
              Text('Description: ${errorCode.description}'),
            ],
            if (errorCode.actionText != null) ...[
              SizedBox(height: 8),
              Text('Action: ${errorCode.actionText}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _getSeverityIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info_outline;
      case ErrorSeverity.warning:
        return Icons.warning_outlined;
      case ErrorSeverity.error:
        return Icons.error_outline;
      case ErrorSeverity.critical:
        return Icons.dangerous_outlined;
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
}
