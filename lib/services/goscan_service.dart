import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class GoScanService {
  static const String flaskBaseUrl = 'http://192.168.1.3:5000/api/goscan';
  static const String laravelBaseUrl = 'http://192.168.1.3:8000/api/goscan';
  
  /// Test connection to GoScan backend
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$flaskBaseUrl/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  /// Verify document using GoScan backend
  static Future<Map<String, dynamic>> verifyDocument({
    required XFile imageFile,
    String? documentType,
    String? userId,
    String? sessionId,
  }) async {
    try {
      // Test connection first
      final isConnected = await testConnection();
      if (!isConnected) {
        throw Exception('Cannot connect to GoScan backend. Please check your internet connection and try again.');
      }
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final response = await http.post(
        Uri.parse('$flaskBaseUrl/verify-document'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image_data': base64Image,
          'document_type': documentType ?? 'application_form',
          'user_id': userId,
          'session_id': sessionId,
        }),
      ).timeout(
        const Duration(seconds: 120), // Increased timeout to 2 minutes
        onTimeout: () {
          throw Exception('Request timed out. Please try again.');
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify document: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error verifying document: $e');
    }
  }
  
  /// Extract text from document
  static Future<Map<String, dynamic>> extractText({
    required XFile imageFile,
    String? documentType,
  }) async {
    try {
      // Convert image to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final response = await http.post(
        Uri.parse('$flaskBaseUrl/extract-text'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image_data': base64Image,
          'document_type': documentType ?? 'application_form',
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to extract text: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error extracting text: $e');
    }
  }
  
  /// Validate extracted fields
  static Future<Map<String, dynamic>> validateFields({
    required Map<String, dynamic> extractedData,
    String? documentType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$flaskBaseUrl/validate-fields'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'extracted_data': extractedData,
          'document_type': documentType ?? 'application_form',
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to validate fields: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error validating fields: $e');
    }
  }
  
  /// Get available document templates
  static Future<Map<String, dynamic>> getTemplates() async {
    try {
      final response = await http.get(
        Uri.parse('$laravelBaseUrl/templates'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get templates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting templates: $e');
    }
  }
  
  /// Save extracted fields to Laravel backend
  static Future<Map<String, dynamic>> saveExtractedFields({
    required Map<String, dynamic> extractedData,
    required String documentType,
    String? userId,
    String? sessionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$laravelBaseUrl/save-fields'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'extracted_data': extractedData,
          'document_type': documentType,
          'user_id': userId,
          'session_id': sessionId,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to save fields: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving fields: $e');
    }
  }
}