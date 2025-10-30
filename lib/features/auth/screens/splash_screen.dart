import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import '../../scholar/screens/scholar_dashboard.dart';
import '../../new_applicant/screens/new_applicant_dashboard.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';
import '../../../config/api_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();

    // Check authentication status and navigate accordingly
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation to complete (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Test API connection first
      print('Testing API connection...');
      final connectionOk = await ApiService.testConnection();
      print('API connection test result: $connectionOk');
      
      if (!connectionOk) {
        // Show connection error dialog
        _showConnectionErrorDialog();
        return;
      }

      // Check if user is already logged in
      final isLoggedIn = await AuthService.isLoggedIn();
      
      if (isLoggedIn) {
        // Try to get current user to verify token is still valid
        final user = await AuthService.getCurrentUser();
        
        if (user != null) {
          // User is logged in and token is valid, go to appropriate dashboard
          Widget dashboard;
          if (user.role == 'SPES') {
            dashboard = const ScholarDashboard(); // SPES dashboard
          } else {
            dashboard = const NewApplicantDashboard(); // Applicant dashboard
          }
          
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => dashboard),
          );
        } else {
          // Token is invalid, go to login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        // User is not logged in, go to login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  void _showConnectionErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Connection Error'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cannot connect to server. Please ensure:\n\n'
                '1. Your Laravel server is running\n'
                '2. Your computer and mobile device are on the same network\n'
                '3. Check your firewall settings\n\n'
                'Current Configuration:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Server IP: ${ApiConfig.serverIp}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                    Text('Port: ${ApiConfig.serverPort}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                    Text('Full URL: ${ApiConfig.baseUrl}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '\nTo change the IP address, edit:\nlib/config/api_config.dart',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _checkAuthAndNavigate(); // Retry
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Continue Offline'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1D4ED8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.document_scanner,
                          size: 60,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Column(
                      children: [
                        Text(
                          'GoScan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Document Scanner for PESO Bay Laguna',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
