import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class InterviewDetailsScreen extends StatefulWidget {
  const InterviewDetailsScreen({super.key});

  @override
  State<InterviewDetailsScreen> createState() => _InterviewDetailsScreenState();
}

class _InterviewDetailsScreenState extends State<InterviewDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _interviewData;
  String? _applicationStatus;
  String? _interviewStatus;

  @override
  void initState() {
    super.initState();
    _loadInterviewDetails();
  }

  Future<void> _loadInterviewDetails() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      final response = await ApiService.get('/scholarship/exam-interview-details?email=${Uri.encodeComponent(user.email)}');
      
      if (response['success'] == true) {
        setState(() {
          _interviewData = response['data']['interview_details'];
          _applicationStatus = response['data']['application_status'];
          _interviewStatus = response['data']['interview_status'];
          _isLoading = false;
        });
      } else {
        print('Failed to load interview details: ${response['message']}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading interview details: $e');
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
                      'Interview Details',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your scholarship interview information',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Dynamic Interview Status Card
                    _buildInterviewStatusCard(),
                    const SizedBox(height: 24),
                    
                    // Dynamic Interview Information (always show)
                    _buildInterviewInformation(),
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

  Widget _buildInfoItem(String step, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
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



  Widget _buildInterviewStatusCard() {
    // Determine status based on application status
    String title;
    String description;
    IconData icon;
    Color color;

    if (_applicationStatus == 'For Interview') {
      title = 'Pending Interview';
      description = 'Wait for the admin to give you a schedule for your interview.';
      icon = Icons.hourglass_empty;
      color = const Color(0xFFF59E0B);
    } else if (_applicationStatus == 'Scheduled Interview') {
      title = 'Interview Assigned';
      description = 'You have been assigned an interview. Please be on time and prepare well for your interview session.';
      icon = Icons.assignment;
      color = const Color(0xFF2563EB);
    } else if (_interviewStatus == 'Passed') {
      title = 'Congratulations!';
      description = 'You have successfully passed the interview. You will now proceed to the final verification stage.';
      icon = Icons.check_circle;
      color = const Color(0xFF10B981);
    } else if (_interviewStatus == 'Failed') {
      title = 'Interview Not Passed';
      description = 'Unfortunately, you did not meet the interview requirements. Better luck next time.';
      icon = Icons.cancel;
      color = const Color(0xFFEF4444);
    } else {
      title = 'Pending Interview';
      description = 'Complete your examination first. Interview will be scheduled after passing the exam.';
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

  Widget _buildInterviewInformation() {
    final interviewDetails = _interviewData ?? {};
    
    return _buildInfoSection(
      title: 'Interview Information',
      items: [
        _buildInfoItem('Interview Type', 'Panel Interview', Icons.people, const Color(0xFF2563EB)),
        _buildInfoItem('Batch', interviewDetails['interview_batch'] ?? 'To be announced', Icons.group, const Color(0xFF2563EB)),
        _buildInfoItem('Date & Time', 
          interviewDetails['interview_schedule'] != null 
            ? _formatDateTime(interviewDetails['interview_schedule']) 
            : 'To be announced', 
          Icons.calendar_today, const Color(0xFF2563EB)),
        _buildInfoItem('Location', interviewDetails['interview_location'] ?? 'To be announced', Icons.location_on, const Color(0xFF2563EB)),
        _buildInfoItem('Building', interviewDetails['interview_building'] ?? 'To be announced', Icons.business, const Color(0xFF2563EB)),
        _buildInfoItem('Room', interviewDetails['interview_room'] ?? 'To be announced', Icons.meeting_room, const Color(0xFF2563EB)),
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
