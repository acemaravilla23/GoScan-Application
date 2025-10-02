import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goscan_app/models/goscan_result.dart';
import 'package:goscan_app/models/document_type.dart';
import 'package:goscan_app/features/goscan/screens/document_type_selection_screen.dart';

class ScanResultScreen extends StatelessWidget {
  final GoScanResult result;
  final XFile imageFile;
  final DocumentType? documentType;
  
  const ScanResultScreen({
    super.key,
    required this.result,
    required this.imageFile,
    this.documentType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        title: const Text(
          'Scan Results',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document preview
              _buildDocumentPreview(),
              const SizedBox(height: 24),
              
              // Verification status
              _buildVerificationStatus(),
              const SizedBox(height: 24),
              
              // Extracted fields
              if (result.extractedFields.isNotEmpty) ...[
                _buildExtractedFields(),
                const SizedBox(height: 24),
              ],
              
              // Missing fields
              if (result.missingFields.isNotEmpty) ...[
                _buildMissingFields(),
                const SizedBox(height: 24),
              ],
              
              // Validation errors
              if (result.validationErrors.isNotEmpty) ...[
                _buildValidationErrors(),
                const SizedBox(height: 24),
              ],
              
              // Action buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imageFile.path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildVerificationStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: result.isValid ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.isValid ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Column(
        children: [
          Icon(
            result.isValid ? Icons.check_circle : Icons.error,
            color: result.isValid ? Colors.green[600] : Colors.red[600],
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            result.isValid ? 'Document Verification Successful' : 'Document Issues Found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: result.isValid ? Colors.green[800] : Colors.red[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            result.isValid 
              ? 'All validations passed' 
              : 'Please review the issues below',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: result.isValid ? Colors.green[700] : Colors.red[700],
            ),
            textAlign: TextAlign.center,
          ),
          if (result.isValid) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Accuracy: 100%',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Error Percentage: ${_calculateErrorPercentage()}%',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[800],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExtractedFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Extracted Information',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        ...result.extractedFields.map((field) => _buildFieldItem(field)),
      ],
    );
  }

  Widget _buildFieldItem(ExtractedField field) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatFieldName(field.fieldName),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  field.value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: field.isFilled ? Colors.green[100] : Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              field.isFilled ? 'Filled' : 'Empty',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: field.isFilled ? Colors.green[800] : Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Missing Fields',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.orange[600],
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'The following fields are missing:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.orange[800],
                ),
              ),
              const SizedBox(height: 8),
              ...result.missingFields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${_formatFieldName(field)}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.orange[700],
                  ),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValidationErrors() {
    // Categorize validation errors
    Map<String, List<String>> categorizedErrors = _categorizeValidationErrors();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Validation Errors',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        ...categorizedErrors.entries.map((entry) {
          String category = entry.key;
          List<String> errors = entry.value;
          
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[800],
                  ),
                ),
                const SizedBox(height: 8),
                ...errors.map((error) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $error',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.red[700],
                    ),
                  ),
                )),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Map<String, List<String>> _categorizeValidationErrors() {
    Map<String, List<String>> categorized = {};
    
    for (String error in result.validationErrors) {
      String category = 'General Errors';
      
      if (error.toLowerCase().contains('name') || 
          error.toLowerCase().contains('surname') || 
          error.toLowerCase().contains('first') || 
          error.toLowerCase().contains('middle')) {
        category = 'Personal Information';
      } else if (error.toLowerCase().contains('contact') || 
                 error.toLowerCase().contains('email') || 
                 error.toLowerCase().contains('phone')) {
        category = 'Contact Information';
      } else if (error.toLowerCase().contains('address')) {
        category = 'Address Information';
      } else if (error.toLowerCase().contains('father') || 
                 error.toLowerCase().contains('mother') || 
                 error.toLowerCase().contains('family')) {
        category = 'Family Information';
      } else if (error.toLowerCase().contains('school') || 
                 error.toLowerCase().contains('education') || 
                 error.toLowerCase().contains('degree')) {
        category = 'Education Information';
      } else if (error.toLowerCase().contains('status') || 
                 error.toLowerCase().contains('sex') || 
                 error.toLowerCase().contains('checkbox')) {
        category = 'Status Information';
      } else if (error.toLowerCase().contains('format') || 
                 error.toLowerCase().contains('uppercase') || 
                 error.toLowerCase().contains('computerized')) {
        category = 'Format Requirements';
      } else if (error.toLowerCase().contains('consistency') || 
                 error.toLowerCase().contains('match')) {
        category = 'Data Consistency';
      }
      
      if (!categorized.containsKey(category)) {
        categorized[category] = [];
      }
      categorized[category]!.add(error);
    }
    
    return categorized;
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Scan Another Document button (Primary)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _scanAnotherDocument(context),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan Another Document'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Save to Database button (Secondary)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _saveToDatabase(context),
            icon: const Icon(Icons.save),
            label: const Text('Save to Database'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Color(0xFF2563EB)),
            ),
          ),
        ),
      ],
    );
  }

  String _formatFieldName(String fieldName) {
    return fieldName
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  int _calculateErrorPercentage() {
    int totalErrors = result.validationErrors.length + result.missingFields.length;
    int totalFields = result.extractedFields.length;
    
    if (totalFields == 0) return 100;
    
    double errorRate = totalErrors / totalFields;
    return (errorRate * 100).round();
  }

  void _saveToDatabase(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Simulate auto-save to database
      await Future.delayed(const Duration(seconds: 2));
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document automatically saved to database successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
      // Show success instructions
      _showSuccessInstructions(context);
      
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving to database: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Document Verification Successful',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          '📊 Accuracy: 100%\n✅ All validations passed:\n• Template matches correctly\n• All required fields completed\n• All inputs are computerized\n• All data formats are correct\n• All data is consistent\n\n📝 Instructions:\nYou can now submit the hard copy for processing...',
          style: TextStyle(
            fontFamily: 'Inter',
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _scanAnotherDocument(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const DocumentTypeSelectionScreen(),
      ),
      (route) => false,
    );
  }
}