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
  Map<String, dynamic>? _renewalInfo;
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
          _renewalInfo = response['data']['renewal_info'];
          _isLoading = false;
        });
        
        // Debug: Print current availment and renewal info
        print('Current Availment: "$_currentAvailment"');
        print('Renewal Info: $_renewalInfo');
        print('Has Renewal Data: ${_renewalInfo != null && _renewalInfo!['has_renewal'] == true}');
        print('Will show renewal section: ${(_currentAvailment == '2nd Availment' || _currentAvailment == '3rd Availment' || _currentAvailment == '4th Availment') && _renewalInfo != null && _renewalInfo!['has_renewal'] == true}');
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
      final user = AuthService.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      final response = await ApiService.get('/scholar/announcements?email=${Uri.encodeComponent(user.email)}');
      
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
          
          // Renewal Application Section (only show for 2nd, 3rd, 4th availments AND if renewal dates exist)
          if ((_currentAvailment == '2nd Availment' || 
               _currentAvailment == '3rd Availment' || 
               _currentAvailment == '4th Availment') &&
              _renewalInfo != null && 
              _renewalInfo!['has_renewal'] == true)
            _buildRenewalSection(),
          const SizedBox(height: 20),
          
          // Scholar Analytics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'No. of Deployments',
                  value: '${_analytics?['deployments_count'] ?? 0}',
                  icon: Icons.work_outline,
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
          content: announcement['content'] ?? 'No Description',
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

  Widget _buildRenewalSection() {
    return Container(
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
              Icon(
                Icons.refresh_rounded,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Renewal Application',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_renewalInfo == null)
            _buildNoRenewalMessage()
          else if (_renewalInfo!['has_renewal'] == false)
            _buildNoRenewalMessage()
          else
            _buildRenewalDates(),
        ],
      ),
    );
  }

  Widget _buildNoRenewalMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey[500],
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _renewalInfo?['message'] ?? 'You are in your first availment. Renewal will be available after completion.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalDates() {
    final renewalDates = List<Map<String, dynamic>>.from(
      _renewalInfo!['renewal_dates'] ?? []
    );

    return Column(
      children: renewalDates.map((renewal) {
        final status = renewal['status'] ?? 'Closed';
        final isOpen = status == 'Open';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isOpen ? Colors.green[50] : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOpen ? Colors.green[200]! : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isOpen ? Icons.access_time : Icons.schedule,
                color: isOpen ? Colors.green[600] : Colors.grey[500],
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${renewal['batch']} - ${renewal['district']}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '${renewal['from_date']} - ${renewal['to_date']}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOpen ? Colors.green[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isOpen ? Colors.green[700] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
