import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/network_utils.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  NetworkTestResult? _testResult;
  bool _isTesting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Network Debug',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Configuration
            _buildSectionCard(
              'Current Configuration',
              Icons.settings,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: NetworkUtils.getNetworkInfo().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            '${entry.key}:',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SelectableText(
                            entry.value,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Test Connection Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.network_check),
                label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Results
            if (_testResult != null) ...[
              _buildSectionCard(
                'Test Results',
                _testResult!.isFullyWorking ? Icons.check_circle : Icons.error,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusRow('Server Reachable', _testResult!.serverReachable),
                    _buildStatusRow('API Reachable', _testResult!.apiReachable),
                    const SizedBox(height: 8),
                    const Text(
                      'API Response:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _testResult!.apiResponse,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                color: _testResult!.isFullyWorking ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 16),

              // Recommendations
              _buildSectionCard(
                'Recommendations',
                Icons.lightbulb,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _testResult!.recommendations.map((rec) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(rec, style: const TextStyle(fontSize: 14))),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Configuration Instructions
            _buildSectionCard(
              'How to Change IP Address',
              Icons.info,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Find your computer\'s IP address',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '2. Edit the file: lib/config/api_config.dart',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '3. Change the serverIp value to your IP',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _copyConfigPath,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Config Path'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // IP Instructions
            _buildSectionCard(
              'Find Your IP Address',
              Icons.computer,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Windows:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Text('1. Press Win + R, type "cmd"'),
                  const Text('2. Type "ipconfig"'),
                  const Text('3. Look for IPv4 Address'),
                  const SizedBox(height: 12),
                  const Text(
                    'Mac:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Text('1. System Preferences > Network'),
                  const Text('2. Select your connection'),
                  const Text('3. IP address shown on right'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget content, {Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: color != null ? Border.all(color: color.withOpacity(0.3)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color ?? const Color(0xFF2563EB), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color ?? const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final result = await NetworkUtils.testServerConnection();
      setState(() {
        _testResult = result;
      });
    } catch (e) {
      setState(() {
        _testResult = NetworkTestResult(
          serverReachable: false,
          apiReachable: false,
          apiResponse: 'Test failed: $e',
          recommendations: ['Check your network connection'],
        );
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  void _copyConfigPath() {
    Clipboard.setData(const ClipboardData(text: 'lib/config/api_config.dart'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Config path copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
