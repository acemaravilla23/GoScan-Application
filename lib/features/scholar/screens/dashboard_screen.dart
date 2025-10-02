import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _analytics;
  String _classification = '';
  String _currentAvailment = '';
  String _currentStatus = '';
  bool _isProgramCompleted = false;
  Map<String, dynamic>? _renewalNotice;
  List<Map<String, dynamic>> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardAnalytics();
    _loadAnnouncements();
  }

  Future<void> _loadDashboardAnalytics() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) {
        print('No user logged in');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.get('/scholar/dashboard-analytics?email=${Uri.encodeComponent(user.email)}');
      
      if (response['success'] == true) {
        setState(() {
          _classification = response['data']['classification'] ?? '';
          _currentAvailment = response['data']['current_availment'] ?? '';
          _currentStatus = response['data']['current_status'] ?? '';
          _isProgramCompleted = response['data']['is_program_completed'] ?? false;
          _analytics = response['data']['analytics'] ?? {};
          _renewalNotice = response['data']['renewal_notice'];
          _isLoading = false;
        });
      } else {
        _showError('Failed to load analytics: ${response['message']}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showError('Error loading analytics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAnnouncements() async {
    try {
      final response = await ApiService.get('/scholar/announcements');
      
      if (response['success'] == true) {
        setState(() {
          _announcements = List<Map<String, dynamic>>.from(response['data']['announcements'] ?? []);
        });
      } else {
        print('Failed to load announcements: ${response['message']}');
      }
    } catch (e) {
      print('Error loading announcements: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Check if scholar has completed their final availment
          if (_isProgramCompleted) ...[
            _buildCompletionMessage(),
            const SizedBox(height: 20),
          ] else ...[
            // Current Availment Title
            Text(
              _currentStatus.isNotEmpty 
                  ? '$_classification - $_currentAvailment ($_currentStatus)'
                  : '$_classification - $_currentAvailment',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Renewal Notice (if applicable)
          if (_renewalNotice != null && _renewalNotice!['show'] == true) ...[
            _buildRenewalNotice(),
            const SizedBox(height: 20),
          ],
          
          // Scholar Analytics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'No. of Allowance Received',
                  value: '${_analytics?['allowance_received'] ?? 0}',
                  icon: Icons.attach_money,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Scanned Documents',
                  value: '${_analytics?['scanned_documents'] ?? 0}',
                  icon: Icons.document_scanner,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Incomplete Documents',
                  value: '${_analytics?['incomplete_documents'] ?? 0}',
                  icon: Icons.pending_actions,
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Complete Documents',
                  value: '${_analytics?['complete_documents'] ?? 0}',
                  icon: Icons.check_circle,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Announcements
          const Text(
            'Announcements',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          ..._buildAnnouncementsList(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnnouncementsList() {
    if (_announcements.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.campaign_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No Announcements',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Check back later for updates',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ];
    }

    List<Widget> announcementWidgets = [];
    for (int i = 0; i < _announcements.length; i++) {
      final announcement = _announcements[i];
      announcementWidgets.add(
        _buildAnnouncementCard(
          title: announcement['title'] ?? 'No Title',
          content: announcement['description'] ?? 'No Description',
          date: announcement['created_at'] ?? 'No Date',
          isNew: announcement['is_new'] ?? false,
        ),
      );
      
      // Add spacing between cards (except for the last one)
      if (i < _announcements.length - 1) {
        announcementWidgets.add(const SizedBox(height: 12));
      }
    }
    
    return announcementWidgets;
  }

  Widget _buildAnnouncementCard({
    required String title,
    required String content,
    required String date,
    required bool isNew,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isNew ? Border.all(color: const Color(0xFF2563EB), width: 1) : null,
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              if (isNew) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalNotice() {
    final noticeType = _renewalNotice!['type'] ?? 'info';
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData icon;

    switch (noticeType) {
      case 'warning':
        backgroundColor = const Color(0xFFFEF3C7);
        borderColor = const Color(0xFFF59E0B);
        iconColor = const Color(0xFFF59E0B);
        icon = Icons.warning_amber_rounded;
        break;
      case 'success':
        backgroundColor = const Color(0xFFD1FAE5);
        borderColor = const Color(0xFF10B981);
        iconColor = const Color(0xFF10B981);
        icon = Icons.check_circle_rounded;
        break;
      default: // info
        backgroundColor = const Color(0xFFDDEEFF);
        borderColor = const Color(0xFF3B82F6);
        iconColor = const Color(0xFF3B82F6);
        icon = Icons.info_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _renewalNotice!['title'] ?? 'Notice',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _renewalNotice!['message'] ?? '',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: iconColor.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  /**
   * Build the completion congratulatory message
   */
  Widget _buildCompletionMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF10B981), // Green
            Color(0xFF059669), // Darker green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Success Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.celebration,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          
          // Congratulations Title
          const Text(
            'Congratulations!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          
          // Completion Message
          Text(
            'You have successfully completed your $_classification SPES scholarship program!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          
          // Achievement Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Program Completed',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
