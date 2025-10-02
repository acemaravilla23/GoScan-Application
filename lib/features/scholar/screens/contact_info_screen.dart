import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';

class ScholarContactInfoScreen extends StatefulWidget {
  const ScholarContactInfoScreen({super.key});

  @override
  State<ScholarContactInfoScreen> createState() => _ScholarContactInfoScreenState();
}

class _ScholarContactInfoScreenState extends State<ScholarContactInfoScreen> {
  bool _isLoading = true;
  bool _isUpdating = false;
  Map<String, dynamic>? _contactInfo;
  
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _barangayController = TextEditingController();
  final TextEditingController _municipalityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _socmedController = TextEditingController();
  final TextEditingController _socmedNameController = TextEditingController();
  
  String _selectedSocialMedia = 'Facebook';

  @override
  void initState() {
    super.initState();
    _loadContactInfo();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _houseNoController.dispose();
    _barangayController.dispose();
    _municipalityController.dispose();
    _provinceController.dispose();
    _regionController.dispose();
    _postalCodeController.dispose();
    _socmedController.dispose();
    _socmedNameController.dispose();
    super.dispose();
  }

  Future<void> _loadContactInfo() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      final response = await ApiService.get('/profile/contact?email=${Uri.encodeComponent(user.email)}');
      
      if (response['success'] == true) {
        setState(() {
          _contactInfo = response['data'];
          _populateControllers();
          _isLoading = false;
        });
      } else {
        _showError('Failed to load contact information: ${response['message']}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showError('Error loading contact information: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateControllers() {
    if (_contactInfo != null) {
      _phoneController.text = _contactInfo!['phone'] ?? '';
      _houseNoController.text = _contactInfo!['house_no'] ?? '';
      _barangayController.text = _contactInfo!['barangay'] ?? '';
      _municipalityController.text = _contactInfo!['municipality'] ?? '';
      _provinceController.text = _contactInfo!['province'] ?? '';
      _regionController.text = _contactInfo!['region'] ?? '';
      _postalCodeController.text = _contactInfo!['postal_code'] ?? '';
      _socmedController.text = _contactInfo!['socmed'] ?? 'Facebook';
      _socmedNameController.text = _contactInfo!['socmed_name'] ?? '';
      
      // Set default values if empty
      if (_municipalityController.text.isEmpty) _municipalityController.text = 'Bay';
      if (_provinceController.text.isEmpty) _provinceController.text = 'Laguna';
      if (_regionController.text.isEmpty) _regionController.text = 'Region IV-A';
      if (_postalCodeController.text.isEmpty) _postalCodeController.text = '4033';
    }
  }

  Future<void> _updateContactInfo() async {
    if (_phoneController.text.trim().isEmpty) {
      _showError('Phone number is required');
      return;
    }

    if (_houseNoController.text.trim().isEmpty) {
      _showError('House number is required');
      return;
    }

    if (_barangayController.text.trim().isEmpty) {
      _showError('Barangay is required');
      return;
    }

    if (_municipalityController.text.trim().isEmpty) {
      _showError('Municipality is required');
      return;
    }

    if (_provinceController.text.trim().isEmpty) {
      _showError('Province is required');
      return;
    }

    if (_postalCodeController.text.trim().isEmpty) {
      _showError('Postal code is required');
      return;
    }

    if (_socmedNameController.text.trim().isEmpty) {
      _showError('Social media username is required');
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
        'phone': _phoneController.text.trim(),
        'socmed': _socmedController.text.trim(),
        'socmed_name': _socmedNameController.text.trim(),
        'house_no': _houseNoController.text.trim(),
        'barangay': _barangayController.text.trim(),
        'municipality': _municipalityController.text.trim(),
        'province': _provinceController.text.trim(),
        'region': _regionController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
      };

      final response = await ApiService.post('/profile/update-contact', data);

      if (response['success'] == true) {
        _showSuccess('Contact information updated successfully');
        await _loadContactInfo();
      } else {
        final msg = response['message'] ?? 'Failed to update contact information';
        final err = response['errors'] ?? response['error'];
        _showError(err != null ? '$msg: $err' : msg);
      }
    } catch (e) {
      _showError('Error updating contact information: $e');
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
                    'Contact Information',
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
                    // Contact Information Form
                    _buildContactInfoForm(),
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUpdating ? null : _updateContactInfo,
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

  Widget _buildContactInfoForm() {
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
            'Contact Details',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          
          // Phone Number
          _buildFormField(
            label: 'Phone Number *',
            child: _buildTextField(
              controller: _phoneController,
              hintText: 'Enter your phone number (e.g., 09123456789)',
              maxLength: 11,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          const SizedBox(height: 20),
          
          // House Number
          _buildFormField(
            label: 'House Number *',
            child: _buildTextField(
              controller: _houseNoController,
              hintText: 'Enter your house number',
              maxLength: 100,
            ),
          ),
          const SizedBox(height: 20),
          
          // Barangay
          _buildFormField(
            label: 'Barangay *',
            child: _buildTextField(
              controller: _barangayController,
              hintText: 'Enter your barangay',
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 20),
          
          // Municipality
          _buildFormField(
            label: 'Municipality *',
            child: _buildTextField(
              controller: _municipalityController,
              hintText: 'Municipality name',
              maxLength: 100,
            ),
          ),
          const SizedBox(height: 20),
          
          // Province
          _buildFormField(
            label: 'Province *',
            child: _buildTextField(
              controller: _provinceController,
              hintText: 'Province name',
              maxLength: 100,
            ),
          ),
          const SizedBox(height: 20),
          
          // Region
          _buildFormField(
            label: 'Region *',
            child: _buildTextField(
              controller: _regionController,
              hintText: 'Region name',
              maxLength: 100,
            ),
          ),
          const SizedBox(height: 20),
          
          // Postal Code
          _buildFormField(
            label: 'Postal Code *',
            child: _buildTextField(
              controller: _postalCodeController,
              hintText: 'Enter postal code',
              maxLength: 10,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          const SizedBox(height: 20),
          
          // Social Media Platform
          _buildFormField(
            label: 'Social Media Platform *',
            child: _buildDropdown(
              value: _selectedSocialMedia,
              hintText: 'Select social media platform',
              items: ['Facebook', 'Instagram', 'TikTok', 'Twitter', 'LinkedIn', 'YouTube', 'Snapchat', 'Discord', 'Other'],
              onChanged: (value) {
                setState(() {
                  _selectedSocialMedia = value!;
                  _socmedController.text = value;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // Social Media Username
          _buildFormField(
            label: 'Social Media Username *',
            child: _buildTextField(
              controller: _socmedNameController,
              hintText: 'Your username/handle',
              maxLength: 100,
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
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
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
        counterText: '', // Hide character counter
      ),
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
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
}
