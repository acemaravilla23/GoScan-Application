import 'package:flutter/material.dart';
import '../widgets/scholar_topbar.dart';
import '../widgets/scholar_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'tosubmit_screen.dart';
import 'goscan_screen.dart';
import 'availment_screen.dart';
import 'allowance_screen.dart';
import 'scholar_settings_screen.dart';
import '../../../services/auth_service.dart';

class ScholarDashboard extends StatefulWidget {
  const ScholarDashboard({super.key});

  @override
  State<ScholarDashboard> createState() => _ScholarDashboardState();
}

class _ScholarDashboardState extends State<ScholarDashboard> {
  int _currentIndex = 0;
  String _userName = "Scholar";

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
    const DashboardScreen(),
    const ToSubmitScreen(),
    const GoScanScreen(),
    const AvailmentScreen(),
    const AllowanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            ScholarTopBar(
              userName: _userName,
              onProfileTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ScholarSettingsScreen(),
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
      bottomNavigationBar: ScholarBottomNav(
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
