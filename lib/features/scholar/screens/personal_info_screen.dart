import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';
import '../../../config/api_config.dart';

class ScholarPersonalInfoScreen extends StatefulWidget {
  const ScholarPersonalInfoScreen({super.key});

  @override
  State<ScholarPersonalInfoScreen> createState() => _ScholarPersonalInfoScreenState();
}

class _ScholarPersonalInfoScreenState extends State<ScholarPersonalInfoScreen> {
  bool _isLoading = true;
  bool _isUpdating = false;
  Map<String, dynamic>? _userProfile;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  
  // Controllers for editable fields
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _middlenameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  String? _selectedSuffix;
  String? _selectedSex;
  String? _selectedCivilStatus;
  DateTime? _selectedBirthdate;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _middlenameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      print('=== LOAD USER PROFILE (Scholar Personal Info) ===');
      print('User email: ${user.email}');

      final response = await ApiService.get('/profile/details?email=${Uri.encodeComponent(user.email)}');
      
      print('Profile response: $response');
      print('Profile pic in response: ${response['data']?['profile_pic']}');
      
      if (response['success'] == true) {
        setState(() {
          _userProfile = response['data'];
          _populateControllers();
          _isLoading = false;
        });
        print('User profile loaded, profile_pic: ${_userProfile?['profile_pic']}');
      } else {
        _showError('Failed to load profile: ${response['message']}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      _showError('Error loading profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateControllers() {
    if (_userProfile != null) {
      _firstnameController.text = _userProfile!['firstname'] ?? '';
      _middlenameController.text = _userProfile!['middle'] ?? '';
      _lastnameController.text = _userProfile!['lastname'] ?? '';
      _emailController.text = _userProfile!['email'] ?? '';
      _selectedSuffix = _userProfile!['suffix'];
      _selectedSex = _userProfile!['sex'];
      _selectedCivilStatus = _userProfile!['civil_status'];
      
      if (_userProfile!['birthdate'] != null) {
        _selectedBirthdate = DateTime.parse(_userProfile!['birthdate']);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      final response = await ApiService.uploadFile(
        '/profile/upload-picture',
        _selectedImage!,
        'profile_picture',
        additionalData: {'email': user.email},
      );

      if (response['success'] == true) {
        _showSuccess('Profile picture updated successfully');
        await _loadUserProfile();
        setState(() {
          _selectedImage = null;
        });
      } else {
        _showError('Failed to upload picture: ${response['message']}');
      }
    } catch (e) {
      _showError('Error uploading picture: $e');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _updatePersonalInfo() async {
    if (_firstnameController.text.trim().isEmpty ||
        _lastnameController.text.trim().isEmpty) {
      _showError('First name and last name are required');
      return;
    }

    if (_selectedSex == null || _selectedSex!.isEmpty) {
      _showError('Please select sex');
      return;
    }

    if (_selectedCivilStatus == null || _selectedCivilStatus!.isEmpty) {
      _showError('Please select civil status');
      return;
    }

    if (_selectedBirthdate == null) {
      _showError('Please select birthdate');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      final data = {
        'email': user.email,
        'firstname': _firstnameController.text.trim(),
        'middle': _middlenameController.text.trim().isEmpty ? null : _middlenameController.text.trim(),
        'lastname': _lastnameController.text.trim(),
        'suffix': (_selectedSuffix == null || _selectedSuffix!.isEmpty) ? null : _selectedSuffix,
        'sex': _selectedSex,
        'civil_status': _selectedCivilStatus,
        'birthdate': _selectedBirthdate?.toIso8601String().split('T')[0],
      };

      final response = await ApiService.post('/profile/update-personal', data);

      if (response['success'] == true) {
        _showSuccess('Personal information updated successfully');
        await _loadUserProfile();
      } else {
        final msg = response['message'] ?? 'Failed to update personal information';
        final err = response['errors'] ?? response['error'];
        _showError(err != null ? '$msg: $err' : msg);
      }
    } catch (e) {
      _showError('Error updating information: $e');
    } finally {
      setState(() {
        _isUpdating = false;
      });
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

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
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
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    _buildProfilePictureSection(),
                    const SizedBox(height: 32),
                    
                    // Personal Information Form
                    _buildPersonalInfoForm(),
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUpdating ? null : _updatePersonalInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isUpdating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
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
        children: [
          const Text(
            'Profile Picture',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: _selectedImage != null
                  ? ClipOval(
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : _userProfile?['profile_pic'] != null && _userProfile!['profile_pic'].toString().isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            _userProfile!['profile_pic'].toString().startsWith('http')
                                ? _userProfile!['profile_pic']
                                : '${ApiConfig.staticUrl}/${_userProfile!['profile_pic']}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading profile image: $error');
                              return const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
            ),
          ),
          const SizedBox(height: 16),
          
          if (_selectedImage != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isUpdating ? null : _uploadProfilePicture,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Upload'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt, size: 20),
              label: const Text('Change Picture'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Details',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          
          // First Name
          _buildFormField(
            label: 'First Name',
            child: _buildTextField(
              controller: _firstnameController,
              hintText: 'Enter your first name',
            ),
          ),
          const SizedBox(height: 20),
          
          // Middle Name
          _buildFormField(
            label: 'Middle Name (Optional)',
            child: _buildTextField(
              controller: _middlenameController,
              hintText: 'Enter your middle name',
            ),
          ),
          const SizedBox(height: 20),
          
          // Last Name
          _buildFormField(
            label: 'Last Name',
            child: _buildTextField(
              controller: _lastnameController,
              hintText: 'Enter your last name',
            ),
          ),
          const SizedBox(height: 20),
          
          // Suffix
          _buildFormField(
            label: 'Suffix (Optional)',
            child: _buildDropdown(
              value: _selectedSuffix,
              hintText: 'Select suffix',
              items: ['Jr', 'Sr', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'],
              onChanged: (value) => setState(() => _selectedSuffix = value),
            ),
          ),
          const SizedBox(height: 20),
          
          // Email (disabled)
          _buildFormField(
            label: 'Email Address',
            child: _buildTextField(
              controller: _emailController,
              hintText: 'Email address',
              enabled: false,
            ),
          ),
          const SizedBox(height: 20),
          
          // Sex
          _buildFormField(
            label: 'Sex',
            child: _buildDropdown(
              value: _selectedSex,
              hintText: 'Select sex',
              items: ['Male', 'Female'],
              onChanged: (value) => setState(() => _selectedSex = value),
            ),
          ),
          const SizedBox(height: 20),
          
          // Birthdate
          _buildFormField(
            label: 'Birthdate',
            child: _buildDateField(),
          ),
          const SizedBox(height: 20),
          
          // Civil Status
          _buildFormField(
            label: 'Civil Status',
            child: _buildDropdown(
              value: _selectedCivilStatus,
              hintText: 'Select civil status',
              items: ['Single', 'Married', 'Widowed', 'Separated'],
              onChanged: (value) => setState(() => _selectedCivilStatus = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Colors.grey[500],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hintText,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Colors.grey[500],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedBirthdate ?? DateTime.now().subtract(const Duration(days: 6570)),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != _selectedBirthdate) {
          setState(() {
            _selectedBirthdate = picked;
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            hintText: 'Select your birthdate',
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.grey[500],
            ),
            suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          controller: TextEditingController(
            text: _selectedBirthdate != null
                ? '${_selectedBirthdate!.day}/${_selectedBirthdate!.month}/${_selectedBirthdate!.year}'
                : '',
          ),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }
}
