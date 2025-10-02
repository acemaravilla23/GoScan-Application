import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'auth_service.dart';

class DocumentService {
  
  /// Download a document from the Laravel API
  static Future<bool> downloadDocument(String documentType, String fileName) async {
    try {
      // Get the API endpoint for the document type
      String endpoint = _getDocumentEndpoint(documentType);
      
      // Create the download URL
      final url = '${ApiService.baseUrl}$endpoint';
      final uri = Uri.parse(url);
      
      // Launch the download URL in the browser/download manager
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return true;
      } else {
        throw Exception('Cannot open download URL');
      }
    } catch (e) {
      print('Error downloading document: $e');
      throw Exception('Download failed: $e');
    }
  }

  /// Get list of available documents from API
  static Future<List<Map<String, dynamic>>> getDocumentsList() async {
    try {
      final response = await ApiService.get('/documents/list');
      
      if (response['success'] == true) {
        final documents = response['data']['documents'] as List;
        return documents.cast<Map<String, dynamic>>();
      } else {
        throw Exception(response['message'] ?? 'Failed to get documents list');
      }
    } catch (e) {
      print('Error getting documents list: $e');
      rethrow;
    }
  }

  /// Check if a document is available for download
  static Future<bool> checkDocumentAvailability(String documentId) async {
    try {
      final response = await ApiService.get('/documents/check-availability?document_id=$documentId');
      
      if (response['success'] == true) {
        return response['data']['is_available'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking document availability: $e');
      return false;
    }
  }

  /// Download specific documents and mark as submitted
  static Future<bool> downloadApplicationForm() async {
    final success = await downloadDocument('application_form', 'SPES Application Form.docx');
    if (success) {
      await _markDocumentAsSubmitted('application_form', 'folder1');
    }
    return success;
  }

  static Future<bool> downloadCertificateOfEmployment() async {
    final success = await downloadDocument('certificate_employment', 'Certificate of Employment.doc');
    if (success) {
      await _markDocumentAsSubmitted('employment_cert', 'folder1');
    }
    return success;
  }

  static Future<bool> downloadSchoolCertification() async {
    final success = await downloadDocument('school_certification', 'School Certification 2025.doc');
    if (success) {
      await _markDocumentAsSubmitted('school_cert', 'folder1');
    }
    return success;
  }

  static Future<bool> downloadRulesAndUndertaking() async {
    final success = await downloadDocument('rules_undertaking', 'Rules and Undertaking.docx');
    if (success) {
      // Rules and Undertaking is a general template, not folder-specific
      await _markDocumentAsSubmitted('rules_undertaking', 'folder1');
    }
    return success;
  }

  static Future<bool> downloadRequirementsChecklist() async {
    final success = await downloadDocument('requirements_checklist', 'SPES Requirements Checklist.docx');
    if (success) {
      // Requirements Checklist is a general template, not folder-specific
      await _markDocumentAsSubmitted('requirements_checklist', 'folder1');
    }
    return success;
  }

  static Future<bool> downloadProvincialEndorsement() async {
    return await downloadDocument('provincial_endorsement', 'SPES Provincial Endorsement Renewal 2025.docx');
  }

  static Future<bool> downloadEndorsementRenewal() async {
    final success = await downloadDocument('endorsement_renewal', 'SPES-PROVL.-ENDORSEMENT-RENEWAL-2025.docx');
    if (success) {
      await _markDocumentAsSubmitted('endorsement_renewal', 'folder4');
    }
    return success;
  }

  /// Get the API endpoint for a document type
  static String _getDocumentEndpoint(String documentType) {
    switch (documentType) {
      case 'application_form':
        return '/documents/application-form';
      case 'certificate_employment':
        return '/documents/certificate-employment';
      case 'school_certification':
        return '/documents/school-certification';
      case 'rules_undertaking':
        return '/documents/rules-undertaking';
      case 'requirements_checklist':
        return '/documents/requirements-checklist';
      case 'provincial_endorsement':
        return '/documents/provincial-endorsement';
      case 'endorsement_renewal':
        return '/documents/endorsement-renewal';
      default:
        throw Exception('Unknown document type: $documentType');
    }
  }


  /// Mark a document as submitted in the backend
  static Future<void> _markDocumentAsSubmitted(String documentType, String folder) async {
    try {
      final user = AuthService.currentUser;
      if (user == null) {
        print('No user logged in, cannot mark document as submitted');
        return;
      }

      final response = await ApiService.post('/documents/mark-submitted', {
        'email': user.email,
        'document_type': documentType,
        'folder': folder,
      });

      if (response['success'] == true) {
        print('Document $documentType marked as submitted in $folder');
      } else {
        print('Failed to mark document as submitted: ${response['message']}');
      }
    } catch (e) {
      print('Error marking document as submitted: $e');
      // Don't throw error - this is not critical for the download functionality
    }
  }

  /// Get file size in human readable format
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
