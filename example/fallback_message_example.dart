import 'package:flutter/material.dart';
import 'package:directus_i18n/directus_i18n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize ErrorCodeService with your Directus instance
  await ErrorCodeService.init(
    baseUrl: 'https://your-directus-instance.com',
    accessToken: 'your-access-token',
    collectionName: 'error',
    autoLoad: true,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Fallback Messages Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FallbackMessageDemo(),
    );
  }
}

class FallbackMessageDemo extends StatefulWidget {
  @override
  _FallbackMessageDemoState createState() => _FallbackMessageDemoState();
}

class _FallbackMessageDemoState extends State<FallbackMessageDemo> {
  String _currentLanguage = 'th-TH';
  
  final List<String> _languages = [
    'th-TH',
    'en-US',
  ];
  
  final List<String> _testErrorCodes = [
    'COM10003', // Existing error code
    'COM10004', // Missing error code
    'LOGIN_FAILED', // Invalid error code
    'NETWORK_ERROR', // Non-existent error code
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Fallback Messages Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🌐 Select Language',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButton<String>(
                      value: _currentLanguage,
                      isExpanded: true,
                      items: _languages.map((String language) {
                        return DropdownMenuItem<String>(
                          value: language,
                          child: Text(_getLanguageName(language)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _currentLanguage = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Error Codes Test
            Expanded(
              child: ListView.builder(
                itemCount: _testErrorCodes.length,
                itemBuilder: (context, index) {
                  final errorCode = _testErrorCodes[index];
                  final isExisting = ErrorCodeService.hasErrorCode(errorCode);
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Error Code Header
                          Row(
                            children: [
                              Text(
                                '📋 Error Code: $errorCode',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isExisting ? Colors.green : Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isExisting ? '✅ Found' : '❌ Missing',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 12),
                          
                          // Error Message
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              errorCode.getErrorMessage(languageCode: _currentLanguage),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: _currentLanguage == 'th-TH' ? 'Thonburi' : null,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 8),
                          
                          // Error Details (if exists)
                          if (isExisting) ...[
                            Text(
                              '📊 Error Details:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            _buildErrorDetails(errorCode),
                          ] else ...[
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange[700], size: 16),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This error code is not found in Directus. Using custom fallback message.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Service Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 Service Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildServiceStatus(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'th-TH':
        return '🇹🇭 ไทย (Thai)';
      case 'en-US':
        return '🇺🇸 English';
      default:
        return languageCode;
    }
  }
  
  Widget _buildErrorDetails(String errorCode) {
    final error = ErrorCodeService.getErrorCode(errorCode);
    if (error == null) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error.severity != null)
          Text('   🔴 Severity: ${error.severity!.name.toUpperCase()}'),
        if (error.category != null)
          Text('   📂 Category: ${error.category}'),
        if (error.title != null)
          Text('   📝 Title: ${error.title}'),
        if (error.description != null)
          Text('   📄 Description: ${error.description}'),
        if (error.actionText != null)
          Text('   🔘 Action: ${error.actionText}'),
      ],
    );
  }
  
  Widget _buildServiceStatus() {
    final status = ErrorCodeService.getStatus();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('✅ Initialized: ${status['initialized']}'),
        Text('📊 Error Codes Count: ${status['errorCodesCount']}'),
        Text('🗃️ Collection: ${status['collectionName']}'),
        Text('🌐 Base URL: ${status['baseUrl']}'),
      ],
    );
  }
}
