import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Mark all as read button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Mark all as read
                  },
                  child: const Text(
                    'Mark all as read',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 8, // Sample data
                  itemBuilder: (context, index) {
                    final isUnread = index < 3; // First 3 are unread
                    return _buildNotificationItem(
                      title: _getNotificationTitle(index),
                      subtitle: _getNotificationSubtitle(index),
                      time: '${index + 1} hour${index > 0 ? 's' : ''} ago',
                      isUnread: isUnread,
                      icon: _getNotificationIcon(index),
                      iconColor: _getNotificationColor(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNotificationTitle(int index) {
    final titles = [
      'Document Approved',
      'New Scan Available',
      'Submission Reminder',
      'Profile Updated',
      'Document Rejected',
      'System Maintenance',
      'Welcome to GoScan',
      'Password Changed',
    ];
    return titles[index % titles.length];
  }

  String _getNotificationSubtitle(int index) {
    final subtitles = [
      'Your birth certificate has been approved',
      'You can now scan new documents',
      'You have 2 documents pending submission',
      'Your profile information was updated',
      'Please review and resubmit your ID',
      'Scheduled maintenance at 2:00 AM',
      'Thank you for joining GoScan!',
      'Your password was successfully changed',
    ];
    return subtitles[index % subtitles.length];
  }

  IconData _getNotificationIcon(int index) {
    final icons = [
      Icons.check_circle,
      Icons.document_scanner,
      Icons.notifications,
      Icons.person,
      Icons.cancel,
      Icons.build,
      Icons.waving_hand,
      Icons.security,
    ];
    return icons[index % icons.length];
  }

  Color _getNotificationColor(int index) {
    final colors = [
      const Color(0xFF059669), // Green
      const Color(0xFF2563EB), // Blue
      const Color(0xFFF59E0B), // Yellow
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEF4444), // Red
      const Color(0xFF6B7280), // Gray
      const Color(0xFF10B981), // Emerald
      const Color(0xFF3B82F6), // Blue
    ];
    return colors[index % colors.length];
  }

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required String time,
    required bool isUnread,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isUnread 
            ? Border.all(color: const Color(0xFF2563EB).withOpacity(0.2))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
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
                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
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
}
