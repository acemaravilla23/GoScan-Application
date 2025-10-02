import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // User model
  static User? _currentUser;
  static User? get currentUser => _currentUser;

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null;
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Login
  static Future<AuthResult> login(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        final userData = response['data'];
        final token = userData['token'];
        final user = User.fromJson(userData['user']);

        // Store token and user data
        await _storeAuthData(token, user);
        _currentUser = user;

        return AuthResult.success(user: user);
      } else {
        return AuthResult.error(response['message'] ?? 'Login failed');
      }
    } on ApiException catch (e) {
      return AuthResult.error(e.message);
    } catch (e) {
      return AuthResult.error('An unexpected error occurred');
    }
  }

  // Register
  static Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await ApiService.post('/auth/register', {
        'firstname': firstName,
        'lastname': lastName,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      if (response['success'] == true) {
        final userData = response['data'];
        final token = userData['token'];
        final user = User.fromJson(userData['user']);
        final requiresVerification = userData['requires_verification'] ?? false;

        // Store token and user data
        await _storeAuthData(token, user);
        _currentUser = user;

        return AuthResult.success(
          user: user,
          message: response['message'],
          requiresVerification: requiresVerification,
        );
      } else {
        return AuthResult.error(response['message'] ?? 'Registration failed');
      }
    } on ApiException catch (e) {
      return AuthResult.error(e.getAllErrors());
    } catch (e) {
      return AuthResult.error('An unexpected error occurred');
    }
  }

  // Resend email verification
  static Future<AuthResult> resendVerification(String email) async {
    try {
      final response = await ApiService.post('/auth/resend-verification', {
        'email': email,
      });

      if (response['success'] == true) {
        return AuthResult.success(message: response['message']);
      } else {
        return AuthResult.error(response['message'] ?? 'Failed to send verification email');
      }
    } on ApiException catch (e) {
      return AuthResult.error(e.getAllErrors());
    } catch (e) {
      return AuthResult.error('An unexpected error occurred');
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      // Call logout API
      await ApiService.post('/auth/logout', {}, requiresAuth: true);
    } catch (e) {
      // Continue with local logout even if API call fails
      print('Logout API call failed: $e');
    }

    // Clear local data
    await _clearAuthData();
    _currentUser = null;
  }

  // Get current user from API
  static Future<User?> getCurrentUser() async {
    try {
      if (!await isLoggedIn()) return null;

      final response = await ApiService.get('/auth/user', requiresAuth: true);

      if (response['success'] == true) {
        final user = User.fromJson(response['data']['user']);
        _currentUser = user;
        return user;
      }
    } catch (e) {
      print('Get current user failed: $e');
      // If token is invalid, logout
      await logout();
    }

    return null;
  }

  // Update profile
  static Future<AuthResult> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['firstname'] = firstName;
      if (lastName != null) data['lastname'] = lastName;
      if (email != null) data['email'] = email;

      final response = await ApiService.put('/profile', data, requiresAuth: true);

      if (response['success'] == true) {
        final user = User.fromJson(response['data']['user']);
        
        // Update stored user data
        await _updateStoredUser(user);
        _currentUser = user;

        return AuthResult.success(user: user);
      } else {
        return AuthResult.error(response['message'] ?? 'Update failed');
      }
    } on ApiException catch (e) {
      return AuthResult.error(e.getAllErrors());
    } catch (e) {
      return AuthResult.error('An unexpected error occurred');
    }
  }

  // Initialize auth service (call on app startup)
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      
      if (userData != null) {
        // Parse the stored JSON string
        final Map<String, dynamic> userMap = json.decode(userData);
        _currentUser = User.fromJson(userMap);
      }

      // Verify token is still valid if we have a user
      if (_currentUser != null) {
        await getCurrentUser();
      }
    } catch (e) {
      print('Auth initialization failed: $e');
    }
  }

  // Store authentication data
  static Future<void> _storeAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  // Update stored user data
  static Future<void> _updateStoredUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  // Clear authentication data
  static Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}

// User model
class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final DateTime? createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstname'] ?? '',
      lastName: json['lastname'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'New Applicant',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstName,
      'lastname': lastName,
      'email': email,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

// Authentication result
class AuthResult {
  final bool isSuccess;
  final String? error;
  final User? user;
  final String? message;
  final bool requiresVerification;

  AuthResult._({
    required this.isSuccess,
    this.error,
    this.user,
    this.message,
    this.requiresVerification = false,
  });

  factory AuthResult.success({
    User? user, 
    String? message,
    bool requiresVerification = false,
  }) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      message: message,
      requiresVerification: requiresVerification,
    );
  }

  factory AuthResult.error(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}
