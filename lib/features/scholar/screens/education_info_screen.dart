import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';

class ScholarEducationInfoScreen extends StatefulWidget {
  const ScholarEducationInfoScreen({super.key});

  @override
  State<ScholarEducationInfoScreen> createState() => _ScholarEducationInfoScreenState();
}

class _ScholarEducationInfoScreenState extends State<ScholarEducationInfoScreen> {
  bool _isLoading = true;
  bool _isUpdating = false;
  Map<String, dynamic>? _educationInfo;
  
  // Elementary Education Controllers
  final TextEditingController _elementarySchoolController = TextEditingController();
  final TextEditingController _elementaryDegreeController = TextEditingController();
  final TextEditingController _elementaryYearLvlController = TextEditingController();
  final TextEditingController _elementaryDateAttendedController = TextEditingController();
  
  // Secondary Education Controllers
  final TextEditingController _secondarySchoolController = TextEditingController();
  final TextEditingController _secondaryDegreeController = TextEditingController();
  final TextEditingController _secondaryYearLvlController = TextEditingController();
  final TextEditingController _secondaryDateAttendedController = TextEditingController();
  
  // Tertiary Education Controllers
  final TextEditingController _tertiarySchoolController = TextEditingController();
  final TextEditingController _tertiaryDegreeController = TextEditingController();
  final TextEditingController _tertiaryYearLvlController = TextEditingController();
  final TextEditingController _tertiaryDateAttendedController = TextEditingController();
  
  // TechVoc Education Controllers
  final TextEditingController _techvocSchoolController = TextEditingController();
  final TextEditingController _techvocDegreeController = TextEditingController();
  final TextEditingController _techvocYearLvlController = TextEditingController();
  final TextEditingController _techvocDateAttendedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEducationInfo();
  }

  @override
  void dispose() {
    _elementarySchoolController.dispose();
    _elementaryDegreeController.dispose();
    _elementaryYearLvlController.dispose();
    _elementaryDateAttendedController.dispose();
    _secondarySchoolController.dispose();
    _secondaryDegreeController.dispose();
    _secondaryYearLvlController.dispose();
    _secondaryDateAttendedController.dispose();
    _tertiarySchoolController.dispose();
    _tertiaryDegreeController.dispose();
    _tertiaryYearLvlController.dispose();
    _tertiaryDateAttendedController.dispose();
    _techvocSchoolController.dispose();
    _techvocDegreeController.dispose();
    _techvocYearLvlController.dispose();
    _techvocDateAttendedController.dispose();
    super.dispose();
  }

  Future<void> _loadEducationInfo() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return;

      final response = await ApiService.get('/profile/education?email=${Uri.encodeComponent(user.email)}');
      
      if (response['success'] == true) {
        setState(() {
          _educationInfo = response['data'];
          _populateControllers();
          _isLoading = false;
        });
      } else {
        _showError('Failed to load education information: ${response['message']}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showError('Error loading education information: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _populateControllers() {
    if (_educationInfo != null) {
      // Elementary Education
      final elementary = _educationInfo!['elementary'];
      if (elementary != null) {
        _elementarySchoolController.text = elementary['school'] ?? '';
        _elementaryDegreeController.text = elementary['degree'] ?? '';
        _elementaryYearLvlController.text = elementary['year_lvl'] ?? '';
        _elementaryDateAttendedController.text = elementary['date_attended'] ?? '';
      }
      
      // Secondary Education
      final secondary = _educationInfo!['secondary'];
      if (secondary != null) {
        _secondarySchoolController.text = secondary['school'] ?? '';
        _secondaryDegreeController.text = secondary['degree'] ?? '';
        _secondaryYearLvlController.text = secondary['year_lvl'] ?? '';
        _secondaryDateAttendedController.text = secondary['date_attended'] ?? '';
      }
      
      // Tertiary Education
      final tertiary = _educationInfo!['tertiary'];
      if (tertiary != null) {
        _tertiarySchoolController.text = tertiary['school'] ?? '';
        _tertiaryDegreeController.text = tertiary['degree'] ?? '';
        _tertiaryYearLvlController.text = tertiary['year_lvl'] ?? '';
        _tertiaryDateAttendedController.text = tertiary['date_attended'] ?? '';
      }
      
      // TechVoc Education
      final techvoc = _educationInfo!['techvoc'];
      if (techvoc != null) {
        _techvocSchoolController.text = techvoc['school'] ?? '';
        _techvocDegreeController.text = techvoc['degree'] ?? '';
        _techvocYearLvlController.text = techvoc['year_lvl'] ?? '';
        _techvocDateAttendedController.text = techvoc['date_attended'] ?? '';
      }
    }
  }

  Future<void> _updateEducationInfo() async {
    if (_elementarySchoolController.text.trim().isEmpty) {
      _showError('Elementary school name is required');
      return;
    }

    if (_secondarySchoolController.text.trim().isEmpty) {
      _showError('Secondary school name is required');
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
        // Elementary (required)
        'elementary_school': _elementarySchoolController.text.trim(),
        'elementary_degree': _elementaryDegreeController.text.trim(),
        'elementary_year_lvl': _elementaryYearLvlController.text.trim(),
        'elementary_date_attended': _elementaryDateAttendedController.text.trim(),
        // Secondary (required)
        'secondary_school': _secondarySchoolController.text.trim(),
        'secondary_degree': _secondaryDegreeController.text.trim(),
        'secondary_year_lvl': _secondaryYearLvlController.text.trim(),
        'secondary_date_attended': _secondaryDateAttendedController.text.trim(),
        // Tertiary (nullable for SHS)
        'tertiary_school': _tertiarySchoolController.text.trim().isEmpty ? null : _tertiarySchoolController.text.trim(),
        'tertiary_degree': _tertiaryDegreeController.text.trim().isEmpty ? null : _tertiaryDegreeController.text.trim(),
        'tertiary_year_lvl': _tertiaryYearLvlController.text.trim().isEmpty ? null : _tertiaryYearLvlController.text.trim(),
        'tertiary_date_attended': _tertiaryDateAttendedController.text.trim().isEmpty ? null : _tertiaryDateAttendedController.text.trim(),
        // Techvoc (nullable)
        'techvoc_school': _techvocSchoolController.text.trim().isEmpty ? null : _techvocSchoolController.text.trim(),
        'techvoc_degree': _techvocDegreeController.text.trim().isEmpty ? null : _techvocDegreeController.text.trim(),
        'techvoc_year_lvl': _techvocYearLvlController.text.trim().isEmpty ? null : _techvocYearLvlController.text.trim(),
        'techvoc_date_attended': _techvocDateAttendedController.text.trim().isEmpty ? null : _techvocDateAttendedController.text.trim(),
      };

      final response = await ApiService.post('/profile/update-education', data);

      if (response['success'] == true) {
        _showSuccess('Education information updated successfully');
        await _loadEducationInfo();
      } else {
        final msg = response['message'] ?? 'Failed to update education information';
        final err = response['errors'] ?? response['error'];
        _showError(err != null ? '$msg: $err' : msg);
      }
    } catch (e) {
      _showError('Error updating education information: $e');
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
                    'Education Information',
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
                    // Education Information Form
                    _buildEducationInfoForm(),
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUpdating ? null : _updateEducationInfo,
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

  Widget _buildEducationInfoForm() {
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
            'Educational Background',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          
          // Elementary Education
          _buildSectionTitle('Elementary Education'),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'School Name *',
            child: _buildTextField(
              controller: _elementarySchoolController,
              hintText: 'Enter elementary school name',
              maxLength: 255,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Degree/Course *',
            child: _buildTextField(
              controller: _elementaryDegreeController,
              hintText: 'Elementary Graduate',
              maxLength: 100,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Year Level *',
            child: _buildTextField(
              controller: _elementaryYearLvlController,
              hintText: 'Grade 6',
              maxLength: 50,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Date Attended *',
            child: _buildTextField(
              controller: _elementaryDateAttendedController,
              hintText: '2010-2016',
              maxLength: 50,
            ),
          ),
          const SizedBox(height: 24),
          
          // Secondary Education
          _buildSectionTitle('Secondary Education'),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'School Name *',
            child: _buildTextField(
              controller: _secondarySchoolController,
              hintText: 'Enter secondary school name',
              maxLength: 255,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Degree/Course *',
            child: _buildTextField(
              controller: _secondaryDegreeController,
              hintText: 'High School Graduate',
              maxLength: 100,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Year Level *',
            child: _buildTextField(
              controller: _secondaryYearLvlController,
              hintText: 'Grade 12',
              maxLength: 50,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Date Attended *',
            child: _buildTextField(
              controller: _secondaryDateAttendedController,
              hintText: '2016-2022',
              maxLength: 50,
            ),
          ),
          const SizedBox(height: 24),
          
          // Tertiary Education (Optional)
          _buildSectionTitle('Tertiary Education (Optional)'),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'School Name',
            child: _buildTextField(
              controller: _tertiarySchoolController,
              hintText: 'Enter college/university name',
              maxLength: 255,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Degree/Course',
            child: _buildTextField(
              controller: _tertiaryDegreeController,
              hintText: 'Bachelor of Science',
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Year Level',
            child: _buildTextField(
              controller: _tertiaryYearLvlController,
              hintText: '1st Year',
              maxLength: 50,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Date Attended',
            child: _buildTextField(
              controller: _tertiaryDateAttendedController,
              hintText: '2022-Present or 2018-2022',
              maxLength: 50,
            ),
          ),
          const SizedBox(height: 24),
          
          // Technical Vocational Education (Optional)
          _buildSectionTitle('Technical Vocational Education (Optional)'),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'School Name',
            child: _buildTextField(
              controller: _techvocSchoolController,
              hintText: 'Enter technical/vocational school name',
              maxLength: 255,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Course/Program',
            child: _buildTextField(
              controller: _techvocDegreeController,
              hintText: 'Computer Programming, Culinary Arts, etc.',
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Year Level',
            child: _buildTextField(
              controller: _techvocYearLvlController,
              hintText: 'Certificate Level, NC I, NC II, etc.',
              maxLength: 50,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFormField(
            label: 'Date Attended',
            child: _buildTextField(
              controller: _techvocDateAttendedController,
              hintText: '2020-2021',
              maxLength: 50,
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
}