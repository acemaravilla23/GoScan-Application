import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../config/api_config.dart';
import '../screens/notifications_screen.dart';
import '../screens/settings_screen.dart';

class NewApplicantTopBar extends StatefulWidget {
  final String userName;
  final VoidCallback? onProfileTap;

  const NewApplicantTopBar({
    super.key,
    required this.userName,
    this.onProfileTap,
  });

  @override
  State<NewApplicantTopBar> createState() => _NewApplicantTopBarState();
}

class _NewApplicantTopBarState extends State<NewApplicantTopBar> {
  int unreadCount = 0;
  String? profilePicUrl;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
    _fetchProfilePicture();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      
      if (userDataString != null) {
        final userData = json.decode(userDataString);
        final email = userData['email'];
        
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/notifications?email=$email'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success']) {
            setState(() {
              unreadCount = data['data']['unread_count'] ?? 0;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching unread count: $e');
    }
  }

  Future<void> _fetchProfilePicture() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      
      print('=== FETCH PROFILE PICTURE (TopBar) ===');
      
      if (userDataString != null) {
        final userData = json.decode(userDataString);
        final email = userData['email'];
        
        print('User email: $email');
        print('API URL: ${ApiConfig.baseUrl}/profile/details?email=${Uri.encodeComponent(email)}');
        
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/profile/details?email=${Uri.encodeComponent(email)}'),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Success: ${data['success']}');
          print('Profile pic value: ${data['data']['profile_pic']}');
          print('Profile pic is null: ${data['data']['profile_pic'] == null}');
          print('Profile pic is empty: ${data['data']['profile_pic'].toString().isEmpty}');
          
          if (data['success'] && data['data']['profile_pic'] != null && data['data']['profile_pic'].toString().isNotEmpty) {
            final fullUrl = '${ApiConfig.staticUrl}/${data['data']['profile_pic']}';
            print('Setting profile pic URL to: $fullUrl');
            setState(() {
              profilePicUrl = fullUrl;
            });
          } else {
            print('Profile pic not set - condition failed');
          }
        }
      }
    } catch (e, stackTrace) {
      print('Error fetching profile picture: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            children: [
              // Notifications
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationsScreen(),
                      ),
                    );
                    // Refresh unread count when returning from notifications
                    _fetchUnreadCount();
                  },
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: Colors.grey[700],
                        size: 24,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Profile
              GestureDetector(
                onTap: widget.onProfileTap ?? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: profilePicUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            profilePicUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
