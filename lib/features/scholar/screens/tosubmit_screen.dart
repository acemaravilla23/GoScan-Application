import 'package:flutter/material.dart';
import '../../../services/document_service.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class ToSubmitScreen extends StatefulWidget {
  const ToSubmitScreen({super.key});

  @override
  State<ToSubmitScreen> createState() => _ToSubmitScreenState();
}

class _ToSubmitScreenState extends State<ToSubmitScreen> {
  bool _isDownloading = false;
  bool _isLoading = true;
  Map<String, dynamic>? _requirementsStatus;
  bool _hasRenewalRequirements = false;

  @override
  void initState() {
    super.initState();
    _loadRequirementsStatus();
  }

  Future<void> _loadRequirementsStatus() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }
      
      print('=== LOADING SCHOLAR REQUIREMENTS STATUS ===');
      print('User email: ${user.email}');

      final response = await ApiService.get('/scholar/requirements-status?email=${Uri.encodeComponent(user.email)}');
      
      if (response['success'] == true) {
        print('=== SCHOLAR REQUIREMENTS STATUS LOADED ===');
        print('Data: ${response['data']}');
        setState(() {
          _requirementsStatus = response['data'];
          _hasRenewalRequirements = _checkIfHasRenewalRequirements();
          _isLoading = false;
        });
      } else {
        print('Failed to load requirements status: ${response['message']}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading requirements status: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _checkIfHasRenewalRequirements() {
    if (_requirementsStatus == null) return false;
    
    // Check if any renewal folder has data
    return _requirementsStatus!['renewal_folder1'] != null ||
           _requirementsStatus!['renewal_folder2'] != null ||
           _requirementsStatus!['renewal_folder3'] != null ||
           _requirementsStatus!['renewal_folder4'] != null;
  }

  Future<void> _downloadDocument(Future<bool> Function() downloadFunction, String documentName) async {
    if (_isDownloading) return;
    
    setState(() {
      _isDownloading = true;
    });

    try {
      final success = await downloadFunction();
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('$documentName Downloaded Successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('Download failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<void> _downloadApplicationForm() async {
    await _downloadDocument(DocumentService.downloadApplicationForm, 'SPES Application Form');
  }
  
  Future<void> _downloadEmploymentCertificate() async {
    await _downloadDocument(DocumentService.downloadCertificateOfEmployment, 'Certificate of Employment');
  }
  
  Future<void> _downloadSchoolCertification() async {
    await _downloadDocument(DocumentService.downloadSchoolCertification, 'School Certification');
  }
  
  Future<void> _downloadRulesUndertaking() async {
    await _downloadDocument(DocumentService.downloadRulesAndUndertaking, 'Rules and Undertaking');
  }
  
  Future<void> _downloadRequirementsChecklist() async {
    await _downloadDocument(DocumentService.downloadRequirementsChecklist, 'SPES Requirements Checklist');
  }

  Future<void> _downloadEndorsementRenewal() async {
    await _downloadDocument(DocumentService.downloadEndorsementRenewal, 'SPES Endorsement Renewal');
  }

  bool _getRequirementStatus(String folderTitle, String requirement) {
    if (_requirementsStatus == null) {
      print('Requirements status is null for: $folderTitle - $requirement');
      return false;
    }
    
    // Map folder titles to database keys (renewal folders for scholars)
    String folderKey;
    if (folderTitle.contains('Folder 1')) {
      folderKey = 'renewal_folder1';
    } else if (folderTitle.contains('Folder 2')) {
      folderKey = 'renewal_folder2';
    } else if (folderTitle.contains('Folder 3')) {
      folderKey = 'renewal_folder3';
    } else if (folderTitle.contains('Folder 4')) {
      folderKey = 'renewal_folder4';
    } else {
      return false;
    }

    final folderData = _requirementsStatus![folderKey] as Map<String, dynamic>?;
    if (folderData == null) return false;

    // Map requirement names to database field names
    String fieldName;
    if (requirement.contains('Application Form')) {
      fieldName = 'application_form';
    } else if (requirement.contains('Employment Certificate') && !folderTitle.contains('Folder 4')) {
      fieldName = 'employment_cert';
    } else if (requirement.contains('Certificate of Employment') && folderTitle.contains('Folder 4')) {
      fieldName = 'coe'; // Different field name in folder4
    } else if (requirement.contains('School Certificate') || requirement.contains('School Certification')) {
      fieldName = 'school_cert';
    } else if (requirement.contains('Endorsement Renewal')) {
      fieldName = 'endorsement_renewal';
    } else if (requirement.contains('1st Semester Registration Form')) {
      fieldName = '1st_sem_regform';
    } else if (requirement.contains('2nd Semester Registration Form')) {
      fieldName = '2nd_sem_regform';
    } else if (requirement.contains('1st Semester Copy of Grade')) {
      fieldName = '1st_sem_cog';
    } else if (requirement.contains('1st Quarter Copy of Grade')) {
      fieldName = '1st_quarter_cog';
    } else if (requirement.contains('1st Quarter Certificate of Enrollment')) {
      fieldName = '1st_quarter_coe';
    } else if (requirement.contains('Barangay Indigency')) {
      fieldName = 'brgy_indigency';
    } else if (requirement.contains('Birth Certificate')) {
      fieldName = 'birth_cert';
    } else {
      print('Unknown requirement: $requirement');
      return false;
    }

    final status = folderData[fieldName] as String?;
    print('Checking: $folderTitle - $requirement -> $folderKey.$fieldName = $status');
    
    // Consider these statuses as "complete" (should show as checked)
    final isComplete = status == 'Submitted' || 
                      status == 'Under Review' || 
                      status == 'Approved';
    
    print('Result: $isComplete');
    return isComplete;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2563EB),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To Submit',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _hasRenewalRequirements 
                          ? 'Required documents for your scholarship renewal.'
                          : 'Required documents for your scholarship renewal.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Notice Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: const Color(0xFF2563EB),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'IMPORTANT NOTICE',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _hasRenewalRequirements
                                ? 'Fill up the renewal forms in computerized format. After that, please use GoScan to scan and verify your documents before submitting the hardcopy to the PESO Bay Laguna office.'
                                : 'Fill up the application form in computerized format. After that, please use GoScan to scan and verify your documents before submitting the hardcopy to the PESO Bay Laguna office.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Expanded(
                      child: _hasRenewalRequirements 
                          ? _buildRenewalRequirements()
                          : _buildNoRequirementsMessage(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildNoRequirementsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Requirements To Submit Yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will be notified when renewal requirements are available.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalRequirements() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Renewal Templates
          _buildTemplateSection(
            'SPES Endorsement Renewal',
            'Endorsement renewal document for SPES program',
            Icons.description_outlined,
            () => _downloadEndorsementRenewal(),
          ),
          const SizedBox(height: 16),
          
          _buildTemplateSection(
            'Rules and Undertaking',
            'Rules and undertaking document for SPES program',
            Icons.rule,
            () => _downloadRulesUndertaking(),
          ),
          const SizedBox(height: 16),
          
          _buildTemplateSection(
            'SPES Requirements Checklist',
            'Complete checklist of all required documents',
            Icons.checklist,
            () => _downloadRequirementsChecklist(),
          ),
          const SizedBox(height: 16),
          
          // Renewal Folder Sections
          _buildFolderSection(
            'Folder 1 - Basic Requirements',
            [
              'Application Form (3 Copies)',
              'Employment Certificate (3 Copies)',
              'School Certificate (3 Copies)',
            ],
            Icons.folder_outlined,
          ),
          const SizedBox(height: 16),
          _buildFolderSection(
            'Folder 2 - Academic Records',
            [
              '1st Semester Registration Form (3 Copies)',
              '2nd Semester Registration Form (3 Copies)',
              '1st Semester Copy of Grade (3 Copies)',
              '1st Quarter Copy of Grade (3 Copies)',
              '1st Quarter Certificate of Enrollment (3 Copies)',
            ],
            Icons.school_outlined,
          ),
          const SizedBox(height: 16),
          _buildFolderSection(
            'Folder 3 - Personal Documents',
            [
              'Barangay Indigency (1 Original & 2 Photocopy)',
              'Birth Certificate (3 Copies)',
            ],
            Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildFolderSection(
            'Folder 4 - Additional Requirements',
            [
              'Endorsement Renewal (1 Copy)',
              'Application Form (1 Copy)',
              'Certificate of Employment (1 Copy)',
              'School Certification (1 Copy)',
              '1st Semester Registration Form (1 Copy)',
              '2nd Semester Registration Form (1 Copy)',
              'Barangay Indigency (1 Copy)',
              '1st Semester Copy of Grade (1 Copy)',
              '1st Quarter Copy of Grade (1 Copy)',
              '1st Quarter Certificate of Enrollment (1 Copy)',
              'Birth Certificate (1 Copy)',
            ],
            Icons.assignment_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSection(String title, String description, IconData icon, VoidCallback onDownload) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isDownloading ? null : onDownload,
              icon: const Icon(Icons.download, size: 16),
              label: const Text(
                'Download',
                style: TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderSection(String title, List<String> requirements, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...requirements.asMap().entries.map((entry) {
            String requirement = entry.value;
            // Check if requirement is complete based on database status
            bool isComplete = _getRequirementStatus(title, requirement);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Rounded checkbox
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isComplete ? const Color(0xFF2563EB) : Colors.transparent,
                      border: Border.all(
                        color: isComplete ? const Color(0xFF2563EB) : Colors.grey[400]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isComplete
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          )
                        : null,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            requirement,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.3,
                              decoration: isComplete ? TextDecoration.lineThrough : null,
                              decorationColor: Colors.grey[500],
                            ),
                          ),
                        ),
                        // Download buttons for downloadable documents
                        if (requirement.contains('Application Form') && !title.contains('Folder 4'))
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: ElevatedButton.icon(
                              onPressed: _isDownloading ? null : () => _downloadApplicationForm(),
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text(
                                'Download',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        if (requirement.contains('Employment Certificate'))
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: ElevatedButton.icon(
                              onPressed: _isDownloading ? null : () => _downloadEmploymentCertificate(),
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text(
                                'Download',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        if (requirement.contains('School Certificate'))
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: ElevatedButton.icon(
                              onPressed: _isDownloading ? null : () => _downloadSchoolCertification(),
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text(
                                'Download',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        if (requirement.contains('Endorsement Renewal'))
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: ElevatedButton.icon(
                              onPressed: _isDownloading ? null : () => _downloadEndorsementRenewal(),
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text(
                                'Download',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}