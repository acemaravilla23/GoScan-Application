import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  int unreadCount = 0;
  bool isLoading = true;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    
    print('=== SHARED PREFERENCES DEBUG ===');
    print('All SharedPreferences keys: ${prefs.getKeys()}');
    
    // Try to get email from user_data JSON
    final userDataString = prefs.getString('user_data');
    print('user_data string: $userDataString');
    
    if (userDataString != null) {
      try {
        final userData = json.decode(userDataString);
        userEmail = userData['email'];
        print('Email extracted from user_data: $userEmail');
      } catch (e) {
        print('Error parsing user_data: $e');
      }
    }
    
    // Fallback to user_email key if user_data parsing fails
    if (userEmail == null) {
      userEmail = prefs.getString('user_email');
      print('Email from user_email key: $userEmail');
    }
    
    if (userEmail != null) {
      print('Email found, fetching notifications...');
      await _fetchNotifications();
    } else {
      print('ERROR: No email found in SharedPreferences!');
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchNotifications() async {
    if (userEmail == null) {
      print('ERROR: userEmail is null');
      return;
    }

    print('=== FETCHING NOTIFICATIONS ===');
    print('User email: $userEmail');
    print('API URL: ${ApiConfig.baseUrl}/notifications?email=$userEmail');

    setState(() => isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications?email=$userEmail'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded data: $data');
        
        if (data['success']) {
          print('Success! Notifications count: ${data['data']['notifications'].length}');
          setState(() {
            notifications = data['data']['notifications'];
            unreadCount = data['data']['unread_count'];
          });
        } else {
          print('API returned success=false');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    if (userEmail == null) return;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId/mark-read'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': userEmail}),
      );

      if (response.statusCode == 200) {
        await _fetchNotifications(); // Refresh
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    if (userEmail == null) return;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/mark-all-read'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': userEmail}),
      );

      if (response.statusCode == 200) {
        await _fetchNotifications(); // Refresh
      }
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

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
              if (unreadCount > 0)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _markAllAsRead,
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
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : notifications.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return _buildNotificationItem(
                                notification: notification,
                                onTap: () => _markAsRead(notification['notification_id']),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll be notified about application updates',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'Success':
        return Icons.check_circle_outline;
      case 'Information':
        return Icons.info_outline;
      case 'Warning':
        return Icons.warning_amber_rounded;
      case 'Error':
      case 'Failed':
        return Icons.error_outline;
      case 'System':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'Success':
        return const Color(0xFF059669); // Green
      case 'Information':
        return const Color(0xFF2563EB); // Blue
      case 'Warning':
        return const Color(0xFFF59E0B); // Yellow
      case 'Error':
      case 'Failed':
        return const Color(0xFFEF4444); // Red
      case 'System':
        return const Color(0xFF6B7280); // Gray
      default:
        return const Color(0xFF2563EB); // Blue
    }
  }

  String _formatDateTime(String dateString) {
    final date = DateTime.parse(dateString);
    
    // Month names
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    // Format hour for 12-hour time
    int hour = date.hour;
    String period = 'AM';
    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) hour -= 12;
    }
    if (hour == 0) hour = 12;
    
    // Format minute with leading zero
    String minute = date.minute.toString().padLeft(2, '0');
    
    return '${months[date.month - 1]} ${date.day}, ${date.year} $hour:$minute $period';
  }

  Widget _buildNotificationItem({
    required Map<String, dynamic> notification,
    required VoidCallback onTap,
  }) {
    // Handle is_read as either bool or int (0/1 from database)
    final isReadValue = notification['is_read'];
    final isUnread = isReadValue is bool ? !isReadValue : (isReadValue == 0 || isReadValue == false);
    final type = notification['type'] ?? 'Information';
    final icon = _getNotificationIcon(type);
    final iconColor = _getNotificationColor(type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                          notification['title'] ?? 'Notification',
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
                    notification['message'] ?? '',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(notification['created_at'] ?? DateTime.now().toString()),
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
      ),
    );
  }
}

