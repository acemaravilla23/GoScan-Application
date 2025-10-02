import 'dart:io';
import '../config/api_config.dart';
import '../services/api_service.dart';

class NetworkUtils {
  /// Test if the server is reachable
  static Future<NetworkTestResult> testServerConnection() async {
    try {
      // First, try to ping the server IP
      final pingResult = await _pingServer();
      
      // Then, try to connect to the API endpoint
      final apiResult = await _testApiEndpoint();
      
      return NetworkTestResult(
        serverReachable: pingResult,
        apiReachable: apiResult.success,
        apiResponse: apiResult.response,
        recommendations: _getRecommendations(pingResult, apiResult.success),
      );
    } catch (e) {
      return NetworkTestResult(
        serverReachable: false,
        apiReachable: false,
        apiResponse: 'Error: $e',
        recommendations: ['Check your network connection', 'Verify server is running'],
      );
    }
  }

  /// Test basic network connectivity to server IP
  static Future<bool> _pingServer() async {
    try {
      final result = await InternetAddress.lookup(ApiConfig.serverIp)
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Test API endpoint specifically
  static Future<ApiTestResult> _testApiEndpoint() async {
    try {
      final response = await ApiService.testConnection();
      return ApiTestResult(success: response, response: 'API test successful');
    } catch (e) {
      return ApiTestResult(success: false, response: 'API test failed: $e');
    }
  }

  /// Get recommendations based on test results
  static List<String> _getRecommendations(bool serverReachable, bool apiReachable) {
    List<String> recommendations = [];

    if (!serverReachable) {
      recommendations.addAll([
        'Check if your computer IP (${ApiConfig.serverIp}) is correct',
        'Ensure both devices are on the same WiFi network',
        'Try running: ping ${ApiConfig.serverIp} from command line',
        'Check Windows Firewall settings',
      ]);
    } else if (!apiReachable) {
      recommendations.addAll([
        'Server is reachable but Laravel API is not responding',
        'Make sure Laravel is running: composer run dev',
        'Check if Laravel is running on port ${ApiConfig.serverPort}',
        'Verify Laravel routes are working',
        'Try accessing ${ApiConfig.baseUrl}/test in browser',
      ]);
    } else {
      recommendations.add('Connection is working properly!');
    }

    return recommendations;
  }

  /// Get current network configuration info
  static Map<String, String> getNetworkInfo() {
    return {
      'Server IP': ApiConfig.serverIp,
      'Server Port': ApiConfig.serverPort,
      'Full API URL': ApiConfig.baseUrl,
      'Test Endpoint': '${ApiConfig.baseUrl}/test',
    };
  }

  /// Instructions for finding computer IP
  static String getIpInstructions() {
    return ApiConfig.ipInstructions;
  }
}

class NetworkTestResult {
  final bool serverReachable;
  final bool apiReachable;
  final String apiResponse;
  final List<String> recommendations;

  NetworkTestResult({
    required this.serverReachable,
    required this.apiReachable,
    required this.apiResponse,
    required this.recommendations,
  });

  bool get isFullyWorking => serverReachable && apiReachable;
}

class ApiTestResult {
  final bool success;
  final String response;

  ApiTestResult({required this.success, required this.response});
}
