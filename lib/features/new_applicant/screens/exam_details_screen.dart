import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class ExamDetailsScreen extends StatefulWidget {
  const ExamDetailsScreen({super.key});

  @override
  State<ExamDetailsScreen> createState() => _ExamDetailsScreenState();
}

class _ExamDetailsScreenState extends State<ExamDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _examData;
  String? _applicationStatus;
  String? _examStatus;

  @override
  void initState() {
    super.initState();
    _loadExamDetails();
  }

  Future<void> _loadExamDetails() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      final response = await ApiService.get('/scholarship/exam-interview-details?email=${Uri.encodeComponent(user.email)}');
      
      if (response['success'] == true) {
        setState(() {
          _examData = response['data']['exam_details'];
          _applicationStatus = response['data']['application_status'];
          _examStatus = response['data']['exam_status'];
          _isLoading = false;
        });
      } else {
        print('Failed to load exam details: ${response['message']}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading exam details: $e');
      setState(() {
        _isLoading = false;
      });
    }
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const Text(
                      'Examination Details',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your scholarship examination information',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
              
                    // Dynamic Exam Status Card
                    _buildExamStatusCard(),
                    const SizedBox(height: 24),
                    
                    // Dynamic Exam Information (always show)
                    _buildExamInformation(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoSection({required String title, required List<Widget> items}) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
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
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
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


  Widget _buildExamStatusCard() {
    // Determine status based on application status
    String title;
    String description;
    IconData icon;
    Color color;

    if (_applicationStatus == 'For Examination') {
      title = 'Pending Examination';
      description = 'Wait for the admin to give you a schedule for your examination.';
      icon = Icons.hourglass_empty;
      color = const Color(0xFFF59E0B);
    } else if (_applicationStatus == 'Scheduled Examination') {
      title = 'Exam Assigned';
      description = 'You have been assigned an examination. Please be on time and bring all required documents.';
      icon = Icons.assignment;
      color = const Color(0xFF2563EB);
    } else if (_examStatus == 'Passed') {
      title = 'Congratulations!';
      description = 'You have successfully passed the examination. You will now proceed to the interview stage.';
      icon = Icons.check_circle;
      color = const Color(0xFF10B981);
    } else if (_examStatus == 'Failed') {
      title = 'Exam Not Passed';
      description = 'Unfortunately, you did not meet the examination requirements. Better luck next time.';
      icon = Icons.cancel;
      color = const Color(0xFFEF4444);
    } else {
      title = 'Pending Examination';
      description = 'Complete your application requirements first. Examination will be scheduled after approval.';
      icon = Icons.hourglass_empty;
      color = const Color(0xFFF59E0B);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExamInformation() {
    final examDetails = _examData ?? {};
    
    return _buildInfoSection(
      title: 'Examination Information',
      items: [
        _buildInfoItem('Exam Type', 'Written Examination', Icons.edit),
        _buildInfoItem('Batch', examDetails['exam_batch'] ?? 'To be announced', Icons.group),
        _buildInfoItem('Date & Time', 
          examDetails['exam_schedule'] != null 
            ? _formatDateTime(examDetails['exam_schedule']) 
            : 'To be announced', 
          Icons.calendar_today),
        _buildInfoItem('Location', examDetails['exam_location'] ?? 'To be announced', Icons.location_on),
        _buildInfoItem('Building', examDetails['exam_building'] ?? 'To be announced', Icons.business),
        _buildInfoItem('Room', examDetails['exam_room'] ?? 'To be announced', Icons.meeting_room),
      ],
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'To be announced';
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
}
