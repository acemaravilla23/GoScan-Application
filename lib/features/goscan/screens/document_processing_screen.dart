import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:goscan_app/services/goscan_service.dart';
import 'package:goscan_app/models/goscan_result.dart';
import 'package:goscan_app/models/document_type.dart';
import 'package:goscan_app/features/goscan/screens/scan_result_screen.dart';

class DocumentProcessingScreen extends StatefulWidget {
  final XFile imageFile;
  final DocumentType? documentType;
  
  const DocumentProcessingScreen({
    super.key,
    required this.imageFile,
    this.documentType,
  });

  @override
  State<DocumentProcessingScreen> createState() => _DocumentProcessingScreenState();
}

class _DocumentProcessingScreenState extends State<DocumentProcessingScreen> {
  bool _isProcessing = false;
  String _currentStep = 'Preparing image...';
  GoScanResult? _result;
  String? _error;
  int _currentStepIndex = 0;
  
  final List<String> _processingSteps = [
    'Testing connection to verification service...',
    'Preparing image for analysis...',
    'Detecting document template...',
    'Extracting personal information fields...',
    'Extracting contact information fields...',
    'Detecting status checkbox selections...',
    'Extracting address information fields...',
    'Extracting family information fields...',
    'Processing education information table...',
    'Validating field formats and consistency...',
    'Generating verification report...',
    'Saving results to database...',
  ];

  @override
  void initState() {
    super.initState();
    _processDocument();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        title: const Text(
          'Processing Document',
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
            children: [
              // Document preview
              Container(
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
                    File(widget.imageFile.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Processing status
              if (_isProcessing) ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                ),
                const SizedBox(height: 24),
                Text(
                  _currentStep,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Step ${_currentStepIndex + 1} of ${_processingSteps.length}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Processing steps list
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Processing Steps',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._processingSteps.asMap().entries.map((entry) {
                        int index = entry.key;
                        String step = entry.value;
                        bool isCompleted = index < _currentStepIndex;
                        bool isCurrent = index == _currentStepIndex;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isCompleted 
                                    ? Colors.green 
                                    : isCurrent 
                                      ? const Color(0xFF2563EB)
                                      : Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: isCompleted
                                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                                  : isCurrent
                                    ? const SizedBox(
                                        width: 8,
                                        height: 8,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  step,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: isCompleted 
                                      ? Colors.green[700]
                                      : isCurrent 
                                        ? const Color(0xFF2563EB)
                                        : Colors.grey[600],
                                    fontWeight: isCurrent ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
              
              // Error state
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[600],
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Processing Failed',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.red[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Try Again'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _retryProcessing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Success state
              if (_result != null && !_isProcessing) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green[600],
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Processing Complete',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Document processed successfully',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.green[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _viewResults,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'View Results',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processDocument() async {
    setState(() {
      _isProcessing = true;
      _error = null;
      _currentStepIndex = 0;
      _currentStep = _processingSteps[0];
    });

    try {
      // Test connection first
      setState(() {
        _currentStep = 'Testing connection to verification service...';
      });
      
      final isConnected = await GoScanService.testConnection();
      if (!isConnected) {
        throw Exception('Cannot connect to GoScan backend. Please check your internet connection and try again.');
      }
      
      // Simulate processing steps with delays
      for (int i = 1; i < _processingSteps.length; i++) {
        await Future.delayed(const Duration(milliseconds: 800));
        
        if (mounted) {
          setState(() {
            _currentStepIndex = i;
            _currentStep = _processingSteps[i];
          });
        }
      }
      
      // Final step: Call the actual GoScan service
      setState(() {
        _currentStep = 'Connecting to verification service...';
      });
      
      final result = await GoScanService.verifyDocument(
        imageFile: widget.imageFile,
        documentType: widget.documentType?.id,
      );
      
      if (result['success'] == true) {
        setState(() {
          _currentStep = 'Processing complete!';
          _result = GoScanResult.fromJson(result);
        });
      } else {
        throw Exception(result['message'] ?? 'Document verification failed');
      }
      
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _retryProcessing() {
    _processDocument();
  }

  void _viewResults() {
    if (_result != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ScanResultScreen(
            result: _result!,
            imageFile: widget.imageFile,
            documentType: widget.documentType,
          ),
        ),
      );
    }
  }
}