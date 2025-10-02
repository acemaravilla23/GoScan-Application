import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  // API URL is now configured in ApiConfig
  static String get baseUrl => ApiConfig.baseUrl;
  
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get headers with authentication token
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    Map<String, String> headers = Map.from(_headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Handle API response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw ApiException(
          message: data['message'] ?? 'An error occurred',
          statusCode: response.statusCode,
          errors: data['errors'],
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      
      // Handle cases where response body is not valid JSON
      throw ApiException(
        message: 'Invalid response from server: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = requiresAuth ? await _getAuthHeaders() : _headers;
      final url = '$baseUrl$endpoint';
      
      print('Making POST request to: $url'); // Debug log
      print('Request data: ${json.encode(data)}'); // Debug log
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      
      // Provide more specific error messages
      String errorMessage = 'Network error: $e';
      if (e.toString().contains('Connection refused')) {
        errorMessage = 'Cannot connect to server. Please ensure:\n'
            '1. Your Laravel server is running on port 8000\n'
            '2. Run: php artisan serve --host=0.0.0.0 --port=8000\n'
            '3. Check your firewall settings';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout. Please check your internet connection.';
      }
      
      throw ApiException(message: errorMessage);
    }
  }

  // GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = requiresAuth ? await _getAuthHeaders() : _headers;
      
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e');
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = requiresAuth ? await _getAuthHeaders() : _headers;
      
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e');
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = requiresAuth ? await _getAuthHeaders() : _headers;
      
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e');
    }
  }

  // Upload file
  static Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file,
    String fieldName, {
    Map<String, String>? additionalData,
    bool requiresAuth = false,
  }) async {
    try {
      final headers = requiresAuth ? await _getAuthHeaders() : <String, String>{};
      // Remove Content-Type header to let http package set it for multipart
      headers.remove('Content-Type');
      
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
      request.headers.addAll(headers);
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      
      // Add additional data
      if (additionalData != null) {
        request.fields.addAll(additionalData);
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'File upload error: $e');
    }
  }

  // Test API connection
  static Future<bool> testConnection() async {
    try {
      final response = await get('/test');
      return response['success'] == true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() {
    return 'ApiException: $message';
  }

  // Get validation error for a specific field
  String? getFieldError(String field) {
    if (errors != null && errors!.containsKey(field)) {
      final fieldErrors = errors![field];
      if (fieldErrors is List && fieldErrors.isNotEmpty) {
        return fieldErrors.first.toString();
      }
    }
    return null;
  }

  // Get all validation errors as a single string
  String getAllErrors() {
    if (errors != null) {
      List<String> errorMessages = [];
      errors!.forEach((field, messages) {
        if (messages is List) {
          errorMessages.addAll(messages.map((msg) => msg.toString()));
        }
      });
      return errorMessages.join('\n');
    }
    return message;
  }
}
