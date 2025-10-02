import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/scholarship_service.dart';
import 'scholarship_application_form.dart';

class NewApplicantHome extends StatefulWidget {
  const NewApplicantHome({super.key});

  @override
  State<NewApplicantHome> createState() => _NewApplicantHomeState();
}

class _NewApplicantHomeState extends State<NewApplicantHome> {
  bool _hasOngoingAcademicYear = false;
  bool _isApplicationOpen = false;
  String _currentAcademicYear = "";
  String _applicationPeriod = "";
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasExistingApplication = false;
  String? _existingApplicationStatus;
  String? _examStatus;
  String? _interviewStatus;
  String? _classification;
  String? _batch;
  String? _applicationMessage;
  ApplicationCheckResult? _applicationDetails;
  bool _isScholar = false;
  String? _spesId;
  String? _spesBatch;
  String? _scholarStatus;

  @override
  void initState() {
    super.initState();
    _checkScholarshipStatus();
  }

  void _checkScholarshipStatus() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get scholarship status and check for existing application
      final statusFuture = ScholarshipService.getScholarshipStatus();
      
      // Get user email for application check
      final user = AuthService.currentUser;
      final userEmail = user?.email ?? '';
      
      final applicationCheckFuture = ScholarshipService.checkExistingApplication(userEmail);

      final results = await Future.wait([statusFuture, applicationCheckFuture]);
      final status = results[0] as ScholarshipStatus;
      final applicationCheck = results[1] as ApplicationCheckResult;
      
      setState(() {
        _hasOngoingAcademicYear = status.hasOngoingAcademicYear;
        _isApplicationOpen = status.isApplicationOpen;
        _currentAcademicYear = status.currentAcademicYear ?? "";
        _applicationPeriod = status.applicationPeriod ?? "";
        
        if (applicationCheck.isSuccess) {
          _hasExistingApplication = applicationCheck.hasApplication ?? false;
          _existingApplicationStatus = applicationCheck.applicationStatus;
          _examStatus = applicationCheck.examStatus;
          _interviewStatus = applicationCheck.interviewStatus;
          _classification = applicationCheck.classification;
          _batch = applicationCheck.batch;
          _applicationMessage = applicationCheck.message;
          _applicationDetails = applicationCheck;
          
          // Check if user is already a scholar
          if (applicationCheck.applicationStatus == 'Scholar') {
            _isScholar = true;
            _spesId = applicationCheck.spesId;
            _spesBatch = applicationCheck.spesBatch;
            _scholarStatus = applicationCheck.scholarStatus;
          }
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Widget _buildApplicationProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Application Progress',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        // Progress Steps Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
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
              // Progress Steps
              _buildProgressStep(
                title: 'Requirements',
                description: _applicationDetails?.requirementsStatus == 'Complete' 
                    ? 'All requirements submitted' 
                    : 'Submit required documents',
                isCompleted: _applicationDetails?.requirementsStatus == 'Complete',
                isActive: _existingApplicationStatus == 'Pending' || _applicationDetails?.requirementsStatus == 'Incomplete',
              ),
              _buildProgressStep(
                title: 'Pending Application',
                description: _existingApplicationStatus == 'Pending' 
                    ? 'Your application is being reviewed' 
                    : 'Application received and approved',
                isCompleted: _existingApplicationStatus != 'Pending',
                isActive: _existingApplicationStatus == 'Pending',
              ),
              _buildProgressStep(
                title: 'Examination',
                description: _applicationDetails?.examDetails?.schedule != null 
                    ? 'Scheduled: ${_formatDateTime(_applicationDetails!.examDetails!.schedule!)}'
                    : _existingApplicationStatus == 'Pending'
                        ? 'Pending application approval'
                        : _existingApplicationStatus == 'For Examination'
                            ? 'Waiting for exam schedule'
                            : 'Pending schedule',
                isCompleted: _applicationDetails?.examDetails?.results == 'Passed',
                isActive: _applicationDetails?.examStatus == 'Ongoing' || _existingApplicationStatus == 'For Examination' || _existingApplicationStatus == 'Scheduled Examination',
              ),
              _buildProgressStep(
                title: 'Interview',
                description: _applicationDetails?.interviewDetails?.schedule != null 
                    ? 'Scheduled: ${_formatDateTime(_applicationDetails!.interviewDetails!.schedule!)}'
                    : _existingApplicationStatus == 'Pending'
                        ? 'Pending application approval'
                        : _existingApplicationStatus == 'For Interview'
                            ? 'Waiting for interview schedule'
                            : 'Pending schedule',
                isCompleted: _applicationDetails?.interviewDetails?.results == 'Passed',
                isActive: _applicationDetails?.interviewStatus == 'Ongoing' || _existingApplicationStatus == 'For Interview' || _existingApplicationStatus == 'Scheduled Interview',
              ),
              _buildProgressStep(
                title: 'Verification',
                description: 'Final verification and approval',
                isCompleted: _existingApplicationStatus == 'Approved',
                isActive: _existingApplicationStatus == 'For Verification',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildExamProgress() {
    final examDetails = _applicationDetails?.examDetails;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _getStatusColor(_examStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.quiz,
                color: _getStatusColor(_examStatus),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Examination',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(_examStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _examStatus ?? 'Pending',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(_examStatus),
                ),
              ),
            ),
          ],
        ),
        
        if (examDetails?.schedule != null) ...[
          const SizedBox(height: 8),
          _buildDetailRow('Schedule', _formatDateTime(examDetails!.schedule!)),
        ],
        
        if (examDetails?.location != null) ...[
          const SizedBox(height: 4),
          _buildDetailRow('Location', examDetails!.location!),
        ],
        
        if (examDetails?.building != null && examDetails?.room != null) ...[
          const SizedBox(height: 4),
          _buildDetailRow('Venue', '${examDetails!.building}, ${examDetails.room}'),
        ],
        
        if (examDetails?.results != null && examDetails!.results != 'Pending') ...[
          const SizedBox(height: 4),
          _buildDetailRow('Results', examDetails.results!, isResult: true),
        ],
      ],
    );
  }

  Widget _buildInterviewProgress() {
    final interviewDetails = _applicationDetails?.interviewDetails;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _getStatusColor(_interviewStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.person,
                color: _getStatusColor(_interviewStatus),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Interview',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(_interviewStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _interviewStatus ?? 'Pending',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getStatusColor(_interviewStatus),
                ),
              ),
            ),
          ],
        ),
        
        if (interviewDetails?.schedule != null) ...[
          const SizedBox(height: 8),
          _buildDetailRow('Schedule', _formatDateTime(interviewDetails!.schedule!)),
        ],
        
        if (interviewDetails?.location != null) ...[
          const SizedBox(height: 4),
          _buildDetailRow('Location', interviewDetails!.location!),
        ],
        
        if (interviewDetails?.results != null && interviewDetails!.results != 'Pending') ...[
          const SizedBox(height: 4),
          _buildDetailRow('Results', interviewDetails.results!, isResult: true),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isResult = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: isResult ? FontWeight.w600 : FontWeight.normal,
                color: isResult ? _getResultColor(value) : const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'passed':
        return const Color(0xFF10B981);
      case 'rejected':
      case 'failed':
        return const Color(0xFFEF4444);
      case 'ongoing':
      case 'scheduled examination':
      case 'scheduled interview':
        return const Color(0xFF2563EB);
      case 'for examination':
      case 'for interview':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getResultColor(String result) {
    switch (result.toLowerCase()) {
      case 'passed':
        return const Color(0xFF10B981);
      case 'failed':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'for examination':
      case 'scheduled examination':
        return Icons.quiz;
      case 'for interview':
      case 'scheduled interview':
        return Icons.person;
      case 'for verification':
        return Icons.verified;
      default:
        return Icons.hourglass_empty;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load scholarship information',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkScholarshipStatus,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Academic Year Status
          if (_hasOngoingAcademicYear) ...[
            _buildInfoCard(
              title: 'Current Academic Year',
              content: _currentAcademicYear,
              icon: Icons.school,
              color: const Color(0xFF2563EB),
              subtitle: 'Scholarship applications are being processed',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Application Period',
              content: _isApplicationOpen ? 'Open' : 'Closed',
              icon: Icons.calendar_today,
              color: _isApplicationOpen ? const Color(0xFF2563EB) : const Color(0xFFEF4444),
              subtitle: _applicationPeriod,
            ),
            const SizedBox(height: 32),
          ] else ...[
            _buildInfoCard(
              title: 'Academic Year Status',
              content: 'No Ongoing Academic Year',
              icon: Icons.info,
              color: const Color(0xFFF59E0B),
              subtitle: 'Please wait for the next academic year to open',
            ),
            const SizedBox(height: 32),
          ],
          
          // Application Process or Progress
          if (_isScholar) ...[
            _buildCongratulationsCard(),
          ] else if (_hasExistingApplication) ...[
            _buildApplicationProgress(),
          ] else ...[
            const Text(
              'Application Process',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProcessStep(1, 'Submit Application', 'Fill out the application form with your details', true),
                _buildProcessStep(2, 'Document Review', 'Submit required documents for verification', false),
                _buildProcessStep(3, 'Written Examination', 'Take the scholarship examination', false),
                _buildProcessStep(4, 'Interview', 'Attend the scholarship interview', false),
                _buildProcessStep(5, 'Final Approval', 'Wait for final scholarship approval', false),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Apply Button or Status Message
          if (_hasOngoingAcademicYear && _isApplicationOpen) ...[
            if (_hasExistingApplication) ...[
              // Show status card for existing application
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF2563EB),
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Application Submitted',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${_existingApplicationStatus ?? 'Pending'}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _applicationMessage ?? 'We will verify your application and notify you of any updates.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Show apply button for new applications
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showApplicationForm();
                  },
                  icon: const Icon(Icons.assignment),
                  label: const Text(
                    'Apply for Scholarship',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600], size: 24),
                  const SizedBox(height: 8),
                  Text(
                    _hasOngoingAcademicYear 
                        ? 'Application period is currently closed'
                        : 'No ongoing academic year',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please check back later for application updates',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
        ], // Close main children array
      ),
    );
  }

  void _showApplicationForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ScholarshipApplicationForm(),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep(int step, String title, String description, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF2563EB) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? const Color(0xFF2563EB) : Colors.grey[700],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep({
    required String title,
    required String description,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
    bool showSeeDetails = false,
    VoidCallback? onSeeDetails,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? const Color(0xFF10B981) 
                  : isActive 
                      ? const Color(0xFF2563EB) 
                      : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                isCompleted ? Icons.check : Icons.radio_button_unchecked,
                color: isCompleted || isActive ? Colors.white : Colors.grey[600],
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCompleted || isActive 
                              ? const Color(0xFF1F2937) 
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    if (showSeeDetails && onSeeDetails != null) ...[
                      GestureDetector(
                        onTap: onSeeDetails,
                        child: const Text(
                          'See Details',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCongratulationsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Congratulations!',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.celebration,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Welcome to PESO Bay Laguna!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              Text(
                'You are now part of the scholars of PESO Bay Laguna. Your SPES ID is ${_spesId ?? 'N/A'}.',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // Scholar Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildScholarDetailRow('SPES ID', _spesId ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildScholarDetailRow('Batch', _spesBatch ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildScholarDetailRow('Classification', _classification ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildScholarDetailRow('Status', _scholarStatus ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleScholarLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Log out and access Scholar Dashboard',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScholarDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _handleScholarLogout() async {
    try {
      await AuthService.logout();
      if (mounted) {
        // Use pushReplacementNamed instead of pushNamedAndRemoveUntil
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


}
