import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/spes_service.dart';
import 'scholarship_application_form.dart';

class NewApplicantHome extends StatefulWidget {
  const NewApplicantHome({super.key});

  @override
  State<NewApplicantHome> createState() => _NewApplicantHomeState();
}

class _NewApplicantHomeState extends State<NewApplicantHome> {
  bool _hasOngoingBatch = false;
  bool _isApplicationOpen = false;
  String _currentBatch = "";
  ApplicationDistrict? _localApplication;
  ApplicationDistrict? _provincialApplication;
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
  bool _isSpes = false;
  String? _spesId;
  String? _spesBatch;
  String? _spesStatus;

  @override
  void initState() {
    super.initState();
    _checkSpesStatus();
  }

  void _checkSpesStatus() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('=== FLUTTER DEBUG: Checking SPES Status ===');
      print('User email: ${AuthService.currentUser?.email}');

      // Get SPES status and check for existing application
      final statusFuture = SpesService.getSpesStatus();
      
      // Get user email for application check
      final user = AuthService.currentUser;
      final userEmail = user?.email ?? '';
      
      final applicationCheckFuture = SpesService.checkExistingApplication(userEmail);

      final results = await Future.wait([statusFuture, applicationCheckFuture]);
      final status = results[0] as SpesStatus;
      final applicationCheck = results[1] as ApplicationCheckResult;
      
      print('=== FLUTTER DEBUG: Application Check Results ===');
      print('Application Status: ${applicationCheck.applicationStatus}');
      print('Has Application: ${applicationCheck.hasApplication}');
      print('Is SPES: ${applicationCheck.isSpes}');
      print('Full Response: ${applicationCheck.toString()}');
      
      // Check orientation details specifically
      if (applicationCheck.orientationDetails != null) {
        print('=== FLUTTER DEBUG: Orientation Details ===');
        print('Has Schedule: ${applicationCheck.orientationDetails!['has_schedule']}');
        if (applicationCheck.orientationDetails!['has_schedule'] == true) {
          print('Schedule: ${applicationCheck.orientationDetails!['schedule']}');
          print('Location: ${applicationCheck.orientationDetails!['location']}');
          print('Building: ${applicationCheck.orientationDetails!['building']}');
          print('Room: ${applicationCheck.orientationDetails!['room']}');
          print('District: ${applicationCheck.orientationDetails!['district']}');
          print('Status: ${applicationCheck.orientationDetails!['status']}');
        } else {
          print('Message: ${applicationCheck.orientationDetails!['message']}');
        }
      } else {
        print('=== FLUTTER DEBUG: No Orientation Details Found ===');
      }
      
      setState(() {
        _hasOngoingBatch = status.hasOngoingBatch;
        _isApplicationOpen = status.isApplicationOpen;
        _currentBatch = status.currentBatch ?? "";
        _localApplication = status.localApplication;
        _provincialApplication = status.provincialApplication;
        
        if (applicationCheck.isSuccess) {
          _hasExistingApplication = applicationCheck.hasApplication ?? false;
          _existingApplicationStatus = applicationCheck.applicationStatus;
          _examStatus = applicationCheck.examStatus;
          _interviewStatus = applicationCheck.interviewStatus;
          _classification = applicationCheck.classification;
          _batch = applicationCheck.batch;
          _applicationMessage = applicationCheck.message;
          _applicationDetails = applicationCheck;
          
          // Check if user is already a SPES student
          if (applicationCheck.applicationStatus == 'SPES' || applicationCheck.isSpes) {
            _isSpes = true;
            _spesId = applicationCheck.spesId;
            _spesBatch = applicationCheck.spesBatch;
            _spesStatus = applicationCheck.spesStatus;
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
                title: 'Application Submitted',
                description: 'Your application has been received',
                isCompleted: true,
                isActive: false,
              ),
              _buildProgressStep(
                title: 'Checking of Requirements',
                description: _existingApplicationStatus != 'Pending'
                    ? 'Completed'
                    : 'Submit required documents for verification',
                isCompleted: _existingApplicationStatus != 'Pending',
                isActive: _existingApplicationStatus == 'Pending',
              ),
              _buildProgressStep(
                title: 'Interview',
                description: _applicationDetails?.interviewDetails?.results != null && _applicationDetails!.interviewDetails!.results != 'Pending'
                    ? '${_applicationDetails!.interviewDetails!.results!}'
                    : _applicationDetails?.interviewDetails?.schedule != null 
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
                title: 'Written Examination',
                description: _applicationDetails?.examDetails?.results != null && _applicationDetails!.examDetails!.results != 'Pending'
                    ? '${_applicationDetails!.examDetails!.results!}'
                    : _applicationDetails?.examDetails?.schedule != null 
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
                title: 'Verification',
                description: _existingApplicationStatus == 'Contract Signing' || _existingApplicationStatus == 'Approved'
                    ? 'Verified and Approved'
                    : _existingApplicationStatus == 'For Verification'
                        ? 'Under review'
                        : 'Final verification and approval',
                isCompleted: _existingApplicationStatus == 'Contract Signing' || _existingApplicationStatus == 'Approved',
                isActive: _existingApplicationStatus == 'For Verification',
              ),
              _buildProgressStep(
                title: 'Contract Signing',
                description: _existingApplicationStatus == 'Approved'
                    ? 'Contract Signed'
                    : _existingApplicationStatus == 'Contract Signing'
                        ? 'Visit PESO office to sign your SPES contract'
                        : 'Visit PESO office to sign your SPES contract',
                isCompleted: _existingApplicationStatus == 'Approved',
                isActive: _existingApplicationStatus == 'Contract Signing',
              ),
              _buildProgressStep(
                title: 'Orientation',
                description: _applicationDetails?.orientationDetails != null && _applicationDetails!.orientationDetails!['has_schedule'] == true
                    ? _applicationDetails!.orientationDetails!['status'] == 'Done'
                        ? 'Orientation Done'
                        : _applicationDetails!.orientationDetails!['status'] == 'Ongoing'
                            ? 'Ongoing'
                            : 'Scheduled: ${_formatDateTime(_applicationDetails!.orientationDetails!['schedule'])}'
                    : 'Waiting for orientation schedule',
                isCompleted: _applicationDetails?.orientationDetails?['status'] == 'Done',
                isActive: _applicationDetails?.orientationDetails?['status'] == 'Pending' || _applicationDetails?.orientationDetails?['status'] == 'Ongoing',
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

  Widget _buildOrientationDetails() {
    final orientationDetails = _applicationDetails?.orientationDetails;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Orientation Details',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.event,
                      color: Color(0xFF10B981),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Orientation Information',
                    style: TextStyle(
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
                      color: _getOrientationStatusColor(orientationDetails?['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      orientationDetails?['status'] ?? 'Pending',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getOrientationStatusColor(orientationDetails?['status']),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              if (orientationDetails != null && orientationDetails['has_schedule'] == true) ...[
                _buildDetailRow('Schedule', _formatDateTime(orientationDetails['schedule'])),
                const SizedBox(height: 8),
                _buildDetailRow('Location', orientationDetails['location'] ?? 'TBA'),
                const SizedBox(height: 8),
                _buildDetailRow('Building', orientationDetails['building'] ?? 'TBA'),
                const SizedBox(height: 8),
                _buildDetailRow('Room', orientationDetails['room'] ?? 'TBA'),
                const SizedBox(height: 8),
                _buildDetailRow('District', orientationDetails['district'] ?? 'TBA'),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          orientationDetails?['message'] ?? 'No orientation schedule yet. Please wait for further announcements.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Colors.grey[600],
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
      ],
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
      case 'contract signing':
        return const Color(0xFF8B5CF6);
      case 'for verification':
        return const Color(0xFF059669);
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
      case 'contract signing':
        return Icons.edit_document;
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

  Color _getOrientationStatusColor(String? status) {
    switch (status) {
      case 'Done':
        return const Color(0xFF10B981); // Green
      case 'Ongoing':
        return const Color(0xFF3B82F6); // Blue
      case 'Pending':
        return const Color(0xFFF59E0B); // Yellow
      default:
        return const Color(0xFFF59E0B); // Default to yellow
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
              'Failed to load SPES information',
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
              onPressed: _checkSpesStatus,
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
          if (_hasOngoingBatch) ...[
            _buildInfoCard(
              title: 'Current SPES Batch',
              content: _currentBatch,
              icon: Icons.school,
              color: const Color(0xFF2563EB),
              subtitle: 'SPES applications are being processed',
            ),
            const SizedBox(height: 16),
            
            // Only show application cards if user hasn't submitted an application yet
            if (!_hasExistingApplication) ...[
              // Local Application Card
              if (_localApplication != null) ...[
                _buildInfoCard(
                  title: 'SPES Local Application',
                  content: _localApplication!.isOpen ? 'Open' : 'Closed',
                  icon: Icons.location_city,
                  color: _localApplication!.isOpen ? const Color(0xFF2563EB) : const Color(0xFFEF4444),
                  subtitle: _localApplication!.isOpen 
                      ? '${_localApplication!.period} (Batch ${_localApplication!.batch})'
                      : 'Local application period is closed',
                ),
                const SizedBox(height: 12),
              ],
              
              // Provincial Application Card
              if (_provincialApplication != null) ...[
                _buildInfoCard(
                  title: 'SPES Provincial Application',
                  content: _provincialApplication!.isOpen ? 'Open' : 'Closed',
                  icon: Icons.public,
                  color: _provincialApplication!.isOpen ? const Color(0xFF2563EB) : const Color(0xFFEF4444),
                  subtitle: _provincialApplication!.isOpen 
                      ? '${_provincialApplication!.period} (Batch ${_provincialApplication!.batch})'
                      : 'Provincial application period is closed',
                ),
                const SizedBox(height: 12),
              ],
            ],
            
            // Show message if no applications are available
            if (_localApplication == null && _provincialApplication == null) ...[
              _buildInfoCard(
                title: 'Application Period',
                content: 'Not Available',
                icon: Icons.calendar_today,
                color: const Color(0xFF6B7280),
                subtitle: 'No application periods are currently set',
              ),
              const SizedBox(height: 12),
            ],
            
            const SizedBox(height: 20),
          ] else ...[
            _buildInfoCard(
              title: 'SPES Batch Status',
              content: 'No Ongoing SPES Batch',
              icon: Icons.info,
              color: const Color(0xFFF59E0B),
              subtitle: 'Please wait for the next SPES batch to open',
            ),
            const SizedBox(height: 32),
          ],
          
          // Application Process or Progress
          if (_isSpes) ...[
            _buildCongratulationsCard(),
          ] else if (_hasExistingApplication) ...[
            _buildApplicationProgress(),
            const SizedBox(height: 24),
            // Add orientation details for approved applicants
            if (_existingApplicationStatus == 'Approved') ...[
              _buildOrientationDetails(),
            ],
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
                _buildProcessStep(1, 'Submit Application', 'Fill out the SPES application form with your details', true),
                _buildProcessStep(2, 'Checking of Requirements', 'Submit required documents for verification', false),
                _buildProcessStep(3, 'Interview', 'Attend the SPES interview', false),
                _buildProcessStep(4, 'Written Examination', 'Take the SPES examination', false),
                _buildProcessStep(5, 'Verification', 'Final verification and approval', false),
                _buildProcessStep(6, 'Contract Signing', 'Visit PESO office to sign your SPES contract', false),
                _buildProcessStep(7, 'Orientation', 'Attend the SPES orientation program', false),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Apply Buttons or Status Message
          if (_hasOngoingBatch && (_localApplication?.isOpen == true || _provincialApplication?.isOpen == true)) ...[
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
            ] else if (!_hasExistingApplication) ...[
              // Show apply buttons for new applications (only if no existing application)
              Column(
                children: [
                  // Local Application Button
                  if (_localApplication?.isOpen == true) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showApplicationForm(district: 'Local');
                        },
                        icon: const Icon(Icons.location_city),
                        label: Text(
                          'Apply for SPES Local',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Provincial Application Button
                  if (_provincialApplication?.isOpen == true) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showApplicationForm(district: 'Provincial');
                        },
                        icon: const Icon(Icons.public),
                        label: Text(
                          'Apply for SPES Provincial',
                          style: const TextStyle(
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
                ],
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
                    _hasOngoingBatch 
                        ? 'Application period is currently closed'
                        : 'No ongoing SPES batch',
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

  void _showApplicationForm({String? district}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScholarshipApplicationForm(selectedDistrict: district),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
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
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.celebration,
                  size: 40,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Congratulations you are now part of the SPES Program in PESO Bay Laguna',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              Text(
                'You are now part of the scholars of PESO Bay Laguna. Your SPES ID is ${_spesId ?? 'N/A'}.',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  color: Color(0xFF1F2937),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              
              // SPES Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildSpesDetailRow('SPES ID', _spesId ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildSpesDetailRow('Batch', _spesBatch ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildSpesDetailRow('Classification', _classification ?? 'N/A'),
                    const SizedBox(height: 8),
                    _buildSpesDetailRow('Status', _spesStatus ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSpesLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
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
                        'Log out and access SPES Dashboard',
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

  Widget _buildSpesDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF6B7280),
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

  void _handleSpesLogout() async {
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
