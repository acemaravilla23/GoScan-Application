import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';

class ScholarFamilyInfoScreen extends StatefulWidget {
  const ScholarFamilyInfoScreen({super.key});

  @override
  State<ScholarFamilyInfoScreen> createState() => _ScholarFamilyInfoScreenState();
}

class _ScholarFamilyInfoScreenState extends State<ScholarFamilyInfoScreen> {
  bool _isLoading = true;
  bool _isUpdating = false;
  Map<String, dynamic>? _familyInfo;
  
  // GSIS Information Controllers
  final TextEditingController _gsisBeneficiaryController = TextEditingController();
  String _selectedRelationship = 'Father';
  
  // Mother Information Controllers
  final TextEditingController _motherFirstNameController = TextEditingController();
  final TextEditingController _motherMiddleNameController = TextEditingController();
  final TextEditingController _motherLastNameController = TextEditingController();
  final TextEditingController _motherSuffixController = TextEditingController();
  final TextEditingController _motherOccupationController = TextEditingController();
  final TextEditingController _motherContactController = TextEditingController();
  
  // Father Information Controllers
  final TextEditingController _fatherFirstNameController = TextEditingController();
  final TextEditingController _fatherMiddleNameController = TextEditingController();
  final TextEditingController _fatherLastNameController = TextEditingController();
  final TextEditingController _fatherSuffixController = TextEditingController();
  final TextEditingController _fatherOccupationController = TextEditingController();
  final TextEditingController _fatherContactController = TextEditingController();
  
  String? _selectedBeneficiaryStatus;

  @override
  void initState() {
    super.initState();
    _loadFamilyInfo();
  }

  @override
  void dispose() {
    _gsisBeneficiaryController.dispose();
    _motherFirstNameController.dispose();
    _motherMiddleNameController.dispose();
    _motherLastNameController.dispose();
    _motherSuffixController.dispose();
    _motherOccupationController.dispose();
    _motherContactController.dispose();
    _fatherFirstNameController.dispose();
    _fatherMiddleNameController.dispose();
    _fatherLastNameController.dispose();
    _fatherSuffixController.dispose();
    _fatherOccupationController.dispose();
    _fatherContactController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyInfo() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      final response = await ApiService.get('/profile/family?email=${Uri.encodeComponent(user.email)}');
      
      if (response['success'] == true) {
        setState(() {
          _familyInfo = response['data'];
          _populateControllers();
          _isLoading = false;
        });
      } else {
        _showError('Failed to load family information: ${response['message']}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showError('Error loading family information: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateControllers() {
    if (_familyInfo != null) {
      // GSIS Information
      _gsisBeneficiaryController.text = _familyInfo!['gsis_beneficiary'] ?? '';
      _selectedRelationship = _familyInfo!['gsis_relationship'] ?? 'Father';
      
      // Mother Information
      final mother = _familyInfo!['mother'];
      if (mother != null) {
        _motherFirstNameController.text = mother['firstname'] ?? '';
        _motherMiddleNameController.text = mother['middle'] ?? '';
        _motherLastNameController.text = mother['lastname'] ?? '';
        _motherSuffixController.text = mother['suffix'] ?? '';
        _motherOccupationController.text = mother['occupation'] ?? '';
        _motherContactController.text = mother['contact'] ?? '';
      }
      
      // Father Information
      final father = _familyInfo!['father'];
      if (father != null) {
        _fatherFirstNameController.text = father['firstname'] ?? '';
        _fatherMiddleNameController.text = father['middle'] ?? '';
        _fatherLastNameController.text = father['lastname'] ?? '';
        _fatherSuffixController.text = father['suffix'] ?? '';
        _fatherOccupationController.text = father['occupation'] ?? '';
        _fatherContactController.text = father['contact'] ?? '';
      }
      
      // Beneficiary Status
      final beneficiaryStatus = _familyInfo!['beneficiary_status'];
      if (beneficiaryStatus != null && 
          ['Living together', 'Solo Parent', 'Separated', 'Senior Citizen', 'Sugar Plantation Worker', 'Indigenous People', 'Displaced Worker', 'Local', 'OFW', 'Rebel Returnee', 'Victims of Armed Conflicts', 'Person with Disability'].contains(beneficiaryStatus)) {
        _selectedBeneficiaryStatus = beneficiaryStatus;
      } else {
        _selectedBeneficiaryStatus = null;
      }
    }
  }

  Future<void> _updateFamilyInfo() async {
    if (_gsisBeneficiaryController.text.trim().isEmpty) {
      _showError('GSIS beneficiary name is required');
      return;
    }

    if (_motherFirstNameController.text.trim().isEmpty) {
      _showError('Mother\'s first name is required');
      return;
    }

    if (_motherLastNameController.text.trim().isEmpty) {
      _showError('Mother\'s last name is required');
      return;
    }

    if (_fatherFirstNameController.text.trim().isEmpty) {
      _showError('Father\'s first name is required');
      return;
    }

    if (_fatherLastNameController.text.trim().isEmpty) {
      _showError('Father\'s last name is required');
      return;
    }

    if (_selectedBeneficiaryStatus == null || _selectedBeneficiaryStatus!.isEmpty) {
      _showError('Please select beneficiary status');
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
        'gsis_beneficiary': _gsisBeneficiaryController.text.trim(),
        'gsis_relationship': _selectedRelationship,
        'beneficiary_status': _selectedBeneficiaryStatus,
        'mother_firstname': _motherFirstNameController.text.trim(),
        'mother_middle': _motherMiddleNameController.text.trim().isEmpty ? null : _motherMiddleNameController.text.trim(),
        'mother_lastname': _motherLastNameController.text.trim(),
        'mother_suffix': _motherSuffixController.text.trim().isEmpty ? null : _motherSuffixController.text.trim(),
        'mother_contact': _motherContactController.text.trim().isEmpty ? null : _motherContactController.text.trim(),
        'mother_occupation': _motherOccupationController.text.trim().isEmpty ? null : _motherOccupationController.text.trim(),
        'father_firstname': _fatherFirstNameController.text.trim(),
        'father_middle': _fatherMiddleNameController.text.trim().isEmpty ? null : _fatherMiddleNameController.text.trim(),
        'father_lastname': _fatherLastNameController.text.trim(),
        'father_suffix': _fatherSuffixController.text.trim().isEmpty ? null : _fatherSuffixController.text.trim(),
        'father_contact': _fatherContactController.text.trim().isEmpty ? null : _fatherContactController.text.trim(),
        'father_occupation': _fatherOccupationController.text.trim().isEmpty ? null : _fatherOccupationController.text.trim(),
      };

      final response = await ApiService.post('/profile/update-family', data);

      if (response['success'] == true) {
        _showSuccess('Family information updated successfully');
        await _loadFamilyInfo();
      } else {
        final msg = response['message'] ?? 'Failed to update family information';
        final err = response['errors'] ?? response['error'];
        _showError(err != null ? '$msg: $err' : msg);
      }
    } catch (e) {
      _showError('Error updating family information: $e');
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
                    'Family Information',
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
                    // Family Information Form
                    _buildFamilyInfoForm(),
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUpdating ? null : _updateFamilyInfo,
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

  Widget _buildFamilyInfoForm() {
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
            'Family Details',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          
          // GSIS Information
          _buildSectionTitle('GSIS Beneficiary Information'),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'GSIS Beneficiary Name *',
            child: _buildTextField(
              controller: _gsisBeneficiaryController,
              hintText: 'Full name of GSIS beneficiary',
              maxLength: 200,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Relationship to Beneficiary *',
            child: _buildDropdown(
              value: _selectedRelationship,
              hintText: 'Select relationship',
              items: ['Father', 'Mother', 'Grandfather', 'Grandmother', 'Brother', 'Sister', 'Friend', 'Colleague', 'Spouse', 'Partner'],
              onChanged: (value) => setState(() => _selectedRelationship = value!),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Beneficiary Status *',
            child: _buildDropdown(
              value: _selectedBeneficiaryStatus,
              hintText: 'Select beneficiary status',
              items: ['Living together', 'Solo Parent', 'Separated', 'Senior Citizen', 'Sugar Plantation Worker', 'Indigenous People', 'Displaced Worker', 'Local', 'OFW', 'Rebel Returnee', 'Victims of Armed Conflicts', 'Person with Disability'],
              onChanged: (value) => setState(() => _selectedBeneficiaryStatus = value),
            ),
          ),
          const SizedBox(height: 24),
          
          // Mother Information
          _buildSectionTitle('Mother\'s Information'),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Mother\'s First Name *',
            child: _buildTextField(
              controller: _motherFirstNameController,
              hintText: 'Enter mother\'s first name',
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Mother\'s Middle Name',
            child: _buildTextField(
              controller: _motherMiddleNameController,
              hintText: 'Enter mother\'s middle name (optional)',
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Mother\'s Last Name *',
            child: _buildTextField(
              controller: _motherLastNameController,
              hintText: 'Enter mother\'s last name',
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Mother\'s Suffix',
            child: _buildTextField(
              controller: _motherSuffixController,
              hintText: 'Jr., Sr., III (optional)',
              maxLength: 20,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Mother\'s Occupation',
            child: _buildTextField(
              controller: _motherOccupationController,
              hintText: 'Enter mother\'s occupation (optional)',
              maxLength: 100,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Mother\'s Contact Number',
            child: _buildTextField(
              controller: _motherContactController,
              hintText: 'Enter mother\'s contact number (optional)',
              maxLength: 11,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          const SizedBox(height: 24),
          
          // Father Information
          _buildSectionTitle('Father\'s Information'),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Father\'s First Name *',
            child: _buildTextField(
              controller: _fatherFirstNameController,
              hintText: 'Enter father\'s first name',
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Father\'s Middle Name',
            child: _buildTextField(
              controller: _fatherMiddleNameController,
              hintText: 'Enter father\'s middle name (optional)',
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Father\'s Last Name *',
            child: _buildTextField(
              controller: _fatherLastNameController,
              hintText: 'Enter father\'s last name',
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Father\'s Suffix',
            child: _buildTextField(
              controller: _fatherSuffixController,
              hintText: 'Jr., Sr., III (optional)',
              maxLength: 20,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Father\'s Occupation',
            child: _buildTextField(
              controller: _fatherOccupationController,
              hintText: 'Enter father\'s occupation (optional)',
              maxLength: 100,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Father\'s Contact Number',
            child: _buildTextField(
              controller: _fatherContactController,
              hintText: 'Enter father\'s contact number (optional)',
              maxLength: 11,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2563EB),
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
}