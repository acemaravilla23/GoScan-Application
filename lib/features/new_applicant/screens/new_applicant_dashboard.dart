import 'package:flutter/material.dart';
import '../widgets/new_applicant_topbar.dart';
import '../widgets/new_applicant_bottom_nav.dart';
import '../screens/new_applicant_home.dart';
import '../screens/tosubmit_screen.dart';
import '../screens/goscan_screen.dart';
import '../screens/exam_details_screen.dart';
import '../screens/interview_details_screen.dart';
import '../screens/settings_screen.dart';
import '../../../services/auth_service.dart';

class NewApplicantDashboard extends StatefulWidget {
  const NewApplicantDashboard({super.key});

  @override
  State<NewApplicantDashboard> createState() => _NewApplicantDashboardState();
}

class _NewApplicantDashboardState extends State<NewApplicantDashboard> {
  int _currentIndex = 0;
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = AuthService.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.firstName;
      });
    }
  }

  final List<Widget> _screens = [
    const NewApplicantHome(),
    const ToSubmitScreen(),
    const GoScanScreen(),
    const InterviewDetailsScreen(),
    const ExamDetailsScreen(),  
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            NewApplicantTopBar(
              userName: _userName,
              onProfileTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            Expanded(
              child: _screens[_currentIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: NewApplicantBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
