import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/spes_service.dart';
import '../../../services/auth_service.dart';
import '../screens/new_applicant_dashboard.dart';

class ScholarshipApplicationForm extends StatefulWidget {
  final String? selectedDistrict;
  
  const ScholarshipApplicationForm({super.key, this.selectedDistrict});

  @override
  State<ScholarshipApplicationForm> createState() => _ScholarshipApplicationFormState();
}

class _ScholarshipApplicationFormState extends State<ScholarshipApplicationForm> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;
  bool _isSubmitting = false;

  // Form keys for each section
  final _personalFormKey = GlobalKey<FormState>();
  final _contactFormKey = GlobalKey<FormState>();
  final _familyFormKey = GlobalKey<FormState>();
  final _educationFormKey = GlobalKey<FormState>();

  // Personal Information Controllers
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _suffixController = TextEditingController();
  final _ageController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _citizenshipController = TextEditingController(text: 'Filipino');
  final _birthplaceController = TextEditingController(text: 'Bay Laguna');
  final _skillsController = TextEditingController();
  String _selectedSex = 'Male';
  String _selectedCivilStatus = 'Single';
  String _selectedClassification = 'College';
  String _selectedSuffix = '';
  String _selectedBeneficiaryStatus = 'Living together';
  String _selectedGsisBeneficiary = 'Father';
  
  // GSIS Beneficiary Controllers (only used when Guardian is selected)
  final _gsisBeneficiaryFirstNameController = TextEditingController();
  final _gsisBeneficiaryMiddleNameController = TextEditingController();
  final _gsisBeneficiaryLastNameController = TextEditingController();
  final _gsisBeneficiarySuffixController = TextEditingController();
  String _selectedGsisRelationship = 'Father';
  
  // Education dropdown selections
  String _selectedSecondaryDegree = 'High School Graduate';
  String _selectedSecondaryYearLevel = 'Grade 12';
  String _selectedTertiaryYearLevel = '1st Year';
  String _selectedSocialMedia = 'Facebook';

  // Contact & Address Controllers
  final _emailController = TextEditingController();
  final _houseNoController = TextEditingController();
  final _barangayController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _regionController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _socmedController = TextEditingController();
  final _socmedNameController = TextEditingController();

  // Family Information Controllers
  final _beneficiaryStatusController = TextEditingController();
  final _motherFirstNameController = TextEditingController();
  final _motherMiddleNameController = TextEditingController();
  final _motherLastNameController = TextEditingController();
  final _motherSuffixController = TextEditingController();
  final _motherOccupationController = TextEditingController();
  final _motherContactController = TextEditingController();
  final _fatherFirstNameController = TextEditingController();
  final _fatherMiddleNameController = TextEditingController();
  final _fatherLastNameController = TextEditingController();
  final _fatherSuffixController = TextEditingController();
  final _fatherOccupationController = TextEditingController();
  final _fatherContactController = TextEditingController();

  // Education Information Controllers
  final _elementarySchoolController = TextEditingController();
  final _elementaryDegreeController = TextEditingController();
  final _elementaryYearLvlController = TextEditingController();
  final _elementaryDateAttendedController = TextEditingController();
  final _secondarySchoolController = TextEditingController();
  final _secondaryDegreeController = TextEditingController();
  final _secondaryYearLvlController = TextEditingController();
  final _secondaryDateAttendedController = TextEditingController();
  final _tertiarySchoolController = TextEditingController();
  final _tertiaryDegreeController = TextEditingController();
  final _tertiaryYearLvlController = TextEditingController();
  final _tertiaryDateAttendedController = TextEditingController();
  final _techvocSchoolController = TextEditingController();
  final _techvocDegreeController = TextEditingController();
  final _techvocYearLvlController = TextEditingController();
  final _techvocDateAttendedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set default location values
    _municipalityController.text = 'Bay';
    _provinceController.text = 'Laguna';
    _regionController.text = 'Region IV-A';
    _postalCodeController.text = '4033';
    
    // Set default education values
    _elementaryDegreeController.text = 'Elementary Graduate';
    _elementaryYearLvlController.text = 'Graduated';
    _secondaryDegreeController.text = _selectedSecondaryDegree;
    _secondaryYearLvlController.text = _selectedSecondaryYearLevel;
    _tertiaryYearLvlController.text = _selectedTertiaryYearLevel;
    _socmedController.text = _selectedSocialMedia;
    
    // Auto-fill user data from account
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      // Get current user from static property first
      User? currentUser = AuthService.currentUser;
      
      // If not available, try to get from API
      if (currentUser == null) {
        currentUser = await AuthService.getCurrentUser();
      }
      
      if (currentUser != null) {
        setState(() {
          _firstNameController.text = currentUser!.firstName;
          _lastNameController.text = currentUser.lastName;
          _emailController.text = currentUser.email;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _firstNameController.dispose();    
    _middleNameController.dispose();
    _lastNameController.dispose();
    _suffixController.dispose();    
    _birthdateController.dispose();
    _ageController.dispose();
    _skillsController.dispose();
    _emailController.dispose();
    _houseNoController.dispose();
    _barangayController.dispose();
    _municipalityController.dispose();
    _provinceController.dispose();
    _regionController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _socmedController.dispose();
    _socmedNameController.dispose();
    _beneficiaryStatusController.dispose();
    _gsisBeneficiaryFirstNameController.dispose();
    _gsisBeneficiaryMiddleNameController.dispose();
    _gsisBeneficiaryLastNameController.dispose();
    _gsisBeneficiarySuffixController.dispose();
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
    _pageController.dispose();
    super.dispose();
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
          'SPES Application',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),
          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalInformationForm(),
                _buildContactAddressForm(),
                _buildFamilyInformationForm(),
                _buildEducationInformationForm(),
              ],
            ),
          ),
          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF2563EB) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : Colors.grey[600],
                            ),
                          ),
                  ),
                ),
                if (index < _totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: isCompleted ? const Color(0xFF2563EB) : Colors.grey[300],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: SafeArea(
        child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                ),
                child: const Text(
                  'Previous',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : () {
                if (_currentStep < _totalSteps - 1) {
                  _nextStep();
                } else {
                  _submitApplication();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep < _totalSteps - 1 ? 'Next' : 'Submit Application',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  void _nextStep() {
    // Validate current form before proceeding
    bool isValid = false;
    
    switch (_currentStep) {
      case 0:
        isValid = _personalFormKey.currentState?.validate() ?? false;
        break;
      case 1:
        isValid = _contactFormKey.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = _familyFormKey.currentState?.validate() ?? false;
        break;
      case 3:
        isValid = _educationFormKey.currentState?.validate() ?? false;
        break;
    }

    if (isValid) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitApplication() async {
    if (!_educationFormKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare application data
      final applicationData = {
        // Personal Information
        'firstname': _firstNameController.text.trim(),
        'middle': _middleNameController.text.trim().isEmpty ? null : _middleNameController.text.trim(),
        'lastname': _lastNameController.text.trim(),
        'suffix': _selectedSuffix.isEmpty ? null : _selectedSuffix,
        'sex': _selectedSex,        
        'birthdate': _birthdateController.text.trim(), // Format: YYYY-MM-DD
        'age': _calculateAge(),
        'birthplace': _birthplaceController.text.trim(),
        'citizenship': _citizenshipController.text.trim(),
        'civil_status': _selectedCivilStatus,
        'classification': _selectedClassification,
        'district': widget.selectedDistrict ?? 'Provincial', // Use the district from button clicked
        'skills': _skillsController.text.trim().isEmpty ? null : _skillsController.text.trim(),

        // Contact & Address
        'email': _emailController.text.trim(),
        'house_no': _houseNoController.text.trim(),
        'barangay': _barangayController.text.trim(),
        'municipality': _municipalityController.text.trim(),
        'province': _provinceController.text.trim(),
        'region': _regionController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
        'phone': _phoneController.text.trim(),
        'socmed': _socmedController.text.trim(),
        'socmed_name': _socmedNameController.text.trim(),

        // Family Information
        'gsis_firstname': _getGsisFirstName(),
        'gsis_middle': _getGsisMiddleName(),
        'gsis_lastname': _getGsisLastName(),
        'gsis_suffix': _getGsisSuffix(),
        'gsis_relationship': _getGsisRelationship(),
        'beneficiary_status': _selectedBeneficiaryStatus,
        'mother_firstname': _motherFirstNameController.text.trim(),        
        'mother_middle': _motherMiddleNameController.text.trim().isEmpty ? null : _motherMiddleNameController.text.trim(),
        'mother_lastname': _motherLastNameController.text.trim(),
        'mother_suffix': _motherSuffixController.text.trim().isEmpty || _motherSuffixController.text.trim() == '' ? 'None' : _motherSuffixController.text.trim(),
        'mother_occupation': _motherOccupationController.text.trim(),
        'mother_contact': _motherContactController.text.trim(),
        'father_firstname': _fatherFirstNameController.text.trim(),        
        'father_middle': _fatherMiddleNameController.text.trim().isEmpty ? null : _fatherMiddleNameController.text.trim(),
        'father_lastname': _fatherLastNameController.text.trim(),
        'father_suffix': _fatherSuffixController.text.trim().isEmpty || _fatherSuffixController.text.trim() == '' ? 'None' : _fatherSuffixController.text.trim(),
        'father_occupation': _fatherOccupationController.text.trim(),
        'father_contact': _fatherContactController.text.trim(),

        // Education Information
        'elementary_school': _elementarySchoolController.text.trim(),
        'elementary_degree': _elementaryDegreeController.text.trim(),
        'elementary_year_lvl': _elementaryYearLvlController.text.trim(),
        'elementary_date_attended': _elementaryDateAttendedController.text.trim(),
        'secondary_school': _secondarySchoolController.text.trim(),
        'secondary_degree': _secondaryDegreeController.text.trim(),
        'secondary_year_lvl': _secondaryYearLvlController.text.trim(),
        'secondary_date_attended': _secondaryDateAttendedController.text.trim(),
        'tertiary_school': _tertiarySchoolController.text.trim().isEmpty ? null : _tertiarySchoolController.text.trim(),
        'tertiary_degree': _tertiaryDegreeController.text.trim().isEmpty ? null : _tertiaryDegreeController.text.trim(),
        'tertiary_year_lvl': _tertiaryYearLvlController.text.trim().isEmpty ? null : _tertiaryYearLvlController.text.trim(),
        'tertiary_date_attended': _tertiaryDateAttendedController.text.trim().isEmpty ? null : _tertiaryDateAttendedController.text.trim(),
        'techvoc_school': _techvocSchoolController.text.trim().isEmpty ? null : _techvocSchoolController.text.trim(),
        'techvoc_degree': _techvocDegreeController.text.trim().isEmpty ? null : _techvocDegreeController.text.trim(),
        'techvoc_year_lvl': _techvocYearLvlController.text.trim().isEmpty ? null : _techvocYearLvlController.text.trim(),
        'techvoc_date_attended': _techvocDateAttendedController.text.trim().isEmpty ? null : _techvocDateAttendedController.text.trim(),
      };

      // Debug: Log the application data being sent
      print('=== APPLICATION DATA DEBUG ===');
      print('Age calculation: ${_calculateAge()} (${_calculateAge().runtimeType})');
      applicationData.forEach((key, value) {
        if (key == 'age') {
          print('$key: $value (${value.runtimeType}) - CRITICAL FOR BACKEND');
        } else {
          print('$key: $value (${value.runtimeType})');
        }
      });
      print('===============================');
      
      final result = await SpesService.submitApplication(applicationData);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (result.isSuccess) {
          _showSuccessDialog(result.message ?? 'Application submitted successfully!');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Application failed'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  int _calculateAge() {
    if (_birthdateController.text.isEmpty) {
      return 18; // Default age
    }
    
    try {
      final birthdate = DateTime.parse(_birthdateController.text);
      final now = DateTime.now();
      int age = now.year - birthdate.year;
      
      // Adjust if birthday hasn't occurred this year
      if (now.month < birthdate.month || (now.month == birthdate.month && now.day < birthdate.day)) {
        age--;
      }
      
      return age;
    } catch (e) {
      print('Error calculating age: $e');
      return 18; // Default age if parsing fails
    }
  }

  Future<void> _selectBirthdate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime.now().subtract(const Duration(days: 11000)), // 30 years ago
      lastDate: DateTime.now().subtract(const Duration(days: 5475)), // 15 years ago
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthdateController.text = picked.toString().split(' ')[0]; // YYYY-MM-DD format
        // Auto-calculate age
        final now = DateTime.now();
        int age = now.year - picked.year;
        
        // Adjust if birthday hasn't occurred this year
        if (now.month < picked.month || (now.month == picked.month && now.day < picked.day)) {
          age--;
        }
        
        _ageController.text = age.toString();
        
        // Debug: Log the age calculation
        print('Birthdate: ${_birthdateController.text}, Age: $age (${age.runtimeType})');
      });
    }
  }

  // GSIS Beneficiary Helper Methods
  String _getGsisFirstName() {
    if (_selectedGsisBeneficiary == 'Father') {
      return _fatherFirstNameController.text.trim();
    } else if (_selectedGsisBeneficiary == 'Mother') {
      return _motherFirstNameController.text.trim();
    } else {
      return _gsisBeneficiaryFirstNameController.text.trim();
    }
  }

  String? _getGsisMiddleName() {
    if (_selectedGsisBeneficiary == 'Father') {
      return _fatherMiddleNameController.text.trim().isEmpty ? null : _fatherMiddleNameController.text.trim();
    } else if (_selectedGsisBeneficiary == 'Mother') {
      return _motherMiddleNameController.text.trim().isEmpty ? null : _motherMiddleNameController.text.trim();
    } else {
      return _gsisBeneficiaryMiddleNameController.text.trim().isEmpty ? null : _gsisBeneficiaryMiddleNameController.text.trim();
    }
  }

  String _getGsisLastName() {
    if (_selectedGsisBeneficiary == 'Father') {
      return _fatherLastNameController.text.trim();
    } else if (_selectedGsisBeneficiary == 'Mother') {
      return _motherLastNameController.text.trim();
    } else {
      return _gsisBeneficiaryLastNameController.text.trim();
    }
  }

  String? _getGsisSuffix() {
    if (_selectedGsisBeneficiary == 'Father') {
      return _fatherSuffixController.text.trim().isEmpty || _fatherSuffixController.text.trim() == 'None' ? null : _fatherSuffixController.text.trim();
    } else if (_selectedGsisBeneficiary == 'Mother') {
      return _motherSuffixController.text.trim().isEmpty || _motherSuffixController.text.trim() == 'None' ? null : _motherSuffixController.text.trim();
    } else {
      return _gsisBeneficiarySuffixController.text.trim().isEmpty || _gsisBeneficiarySuffixController.text.trim() == 'None' ? null : _gsisBeneficiarySuffixController.text.trim();
    }
  }

  String _getGsisRelationship() {
    if (_selectedGsisBeneficiary == 'Father') {
      return 'Father';
    } else if (_selectedGsisBeneficiary == 'Mother') {
      return 'Mother';
    } else {
      return _selectedGsisRelationship;
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Application Submitted!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You will receive updates about your application status via email and through the app.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Navigate back to dashboard and refresh
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const NewApplicantDashboard()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Personal Information Form
  Widget _buildPersonalInformationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _personalFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your personal details',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Name Fields (Single Column)
            _buildTextFormField(
              controller: _firstNameController,
              label: 'First Name',
              hint: 'Enter your first name',
              isRequired: true,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                LengthLimitingTextInputFormatter(50),
              ],
            ),
            const SizedBox(height: 16),
                                 
            _buildTextFormField(
              controller: _middleNameController,
              label: 'Middle Name',
              hint: 'Enter your middle name (optional)',
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                LengthLimitingTextInputFormatter(50),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextFormField(
              controller: _lastNameController,
              label: 'Last Name',
              hint: 'Enter your last name',
              isRequired: true,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                LengthLimitingTextInputFormatter(50),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildDropdownField(
              label: 'Suffix',
              value: _selectedSuffix,
              items: ['', 'Jr', 'Sr', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'],
              onChanged: (value) => setState(() => _selectedSuffix = value!),
              isRequired: false,
            ),
            const SizedBox(height: 16),
            
            // Sex
            _buildDropdownField(
              label: 'Sex',
              value: _selectedSex,
              items: ['Male', 'Female'],
              onChanged: (value) => setState(() => _selectedSex = value!),
            ),
            const SizedBox(height: 16),

            // Birthdate with Date Picker
            GestureDetector(
              onTap: () => _selectBirthdate(context),
              child: AbsorbPointer(
                child: _buildTextFormField(
                  controller: _birthdateController,
                  label: 'Birthdate',
                  hint: 'Select your birthdate',
                  isRequired: true,
                  suffixIcon: Icons.calendar_today,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Age (Auto-calculated, read-only)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  const Text(
                    'Age: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  Text(
                    _ageController.text.isEmpty ? 'Select birthdate first' : '${_ageController.text} years old',
                    style: TextStyle(
                      fontSize: 16,
                      color: _ageController.text.isEmpty ? Colors.grey[600] : const Color(0xFF1F2937),
                      fontWeight: _ageController.text.isEmpty ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Citizenship Field
            _buildTextFormField(
              controller: _citizenshipController,
              label: 'Citizenship',
              hint: 'Enter your citizenship',
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Citizenship is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Birthplace Field
            _buildTextFormField(
              controller: _birthplaceController,
              label: 'Birthplace',
              hint: 'Enter your birthplace',
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Birthplace is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
                       
            // Civil Status
            _buildDropdownField(
              label: 'Civil Status',
              value: _selectedCivilStatus,
              items: ['Single', 'Married', 'Widowed', 'Separated'],
              onChanged: (value) => setState(() => _selectedCivilStatus = value!),
            ),
            const SizedBox(height: 16),
            
            // Classification
            _buildDropdownField(
              label: 'Classification',
              value: _selectedClassification,
              items: ['College', 'SHS'],
              onChanged: (value) => setState(() => _selectedClassification = value!),
            ),
            const SizedBox(height: 16),
            
            // Skills
            _buildTextFormField(
              controller: _skillsController,
              label: 'Skills and Talents',
              hint: 'Enter your skills and talents (optional)',
              inputFormatters: [LengthLimitingTextInputFormatter(500)],
            ),
          ],
        ),
      ),
    );
  }

  // Contact & Address Form
  Widget _buildContactAddressForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _contactFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact & Address',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your contact and address information',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Email Field
            _buildTextFormField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter your email address',
              isRequired: true,
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                LengthLimitingTextInputFormatter(100),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Address Fields (Single Column)
            _buildTextFormField(
              controller: _houseNoController,
              label: 'House Number',
              hint: 'Enter your house number',
              isRequired: true,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _barangayController,
              label: 'Barangay',
              hint: 'Enter your barangay',
              isRequired: true,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s.-]')),
                LengthLimitingTextInputFormatter(100),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _municipalityController,
              label: 'Municipality',
              hint: 'Municipality name',
              isRequired: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s.-]')),
                LengthLimitingTextInputFormatter(100),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _provinceController,
              label: 'Province',
              hint: 'Province name',
              isRequired: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s.-]')),
                LengthLimitingTextInputFormatter(100),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _regionController,
              label: 'Region',
              hint: 'Region name',
              isRequired: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s.-IV]')),
                LengthLimitingTextInputFormatter(100),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _postalCodeController,
              label: 'Postal Code',
              hint: 'Enter postal code',
              isRequired: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number (e.g., 09123456789)',
              isRequired: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Phone number is required';
                }
                if (value.length != 11) {
                  return 'Phone number must be exactly 11 digits';
                }
                if (!value.startsWith('09')) {
                  return 'Phone number must start with 09';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Social Media
            _buildDropdownField(
              label: 'Social Media Platform',
              value: _selectedSocialMedia,
              items: ['Facebook', 'Instagram', 'TikTok', 'Twitter', 'LinkedIn', 'YouTube', 'Snapchat', 'Discord', 'Other'],
              onChanged: (value) {
                setState(() {
                  _selectedSocialMedia = value!;
                  _socmedController.text = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _socmedNameController,
              label: 'Social Media Username',
              hint: 'Your username/handle',
              isRequired: true,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
            ),
          ],
        ),
      ),
    );
  }

  // Family Information Form
  Widget _buildFamilyInformationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _familyFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Family Information',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your family and beneficiary information',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // GSIS Information
            const Text(
              'GSIS Beneficiary Information',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            
            // GSIS Beneficiary Selection
            _buildDropdownField(
              label: 'GSIS Beneficiary',
              value: _selectedGsisBeneficiary,
              items: ['Father', 'Mother', 'Guardian'],
              onChanged: (value) => setState(() => _selectedGsisBeneficiary = value!),
            ),
            const SizedBox(height: 16),
            
            // Show GSIS beneficiary info based on selection
            if (_selectedGsisBeneficiary == 'Father') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GSIS Beneficiary will be set to Father information above',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_selectedGsisBeneficiary == 'Mother') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.pink[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.pink[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GSIS Beneficiary will be set to Mother information above',
                        style: TextStyle(
                          color: Colors.pink[800],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Guardian - show input fields
              _buildTextFormField(
                controller: _gsisBeneficiaryFirstNameController,
                label: 'Guardian First Name',
                hint: 'Enter guardian\'s first name',
                isRequired: true,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s.-]')),
                  LengthLimitingTextInputFormatter(100),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _gsisBeneficiaryMiddleNameController,
                label: 'Guardian Middle Name',
                hint: 'Enter guardian\'s middle name (optional)',
                isRequired: false,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s.-]')),
                  LengthLimitingTextInputFormatter(100),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildTextFormField(
                controller: _gsisBeneficiaryLastNameController,
                label: 'Guardian Last Name',
                hint: 'Enter guardian\'s last name',
                isRequired: true,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s.-]')),
                  LengthLimitingTextInputFormatter(100),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildDropdownField(
                label: 'Guardian Suffix',
                value: _gsisBeneficiarySuffixController.text.isEmpty ? 'None' : _gsisBeneficiarySuffixController.text,
                items: ['None', 'Jr', 'Sr', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'],
                onChanged: (value) {
                  setState(() {
                    _gsisBeneficiarySuffixController.text = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              _buildDropdownField(
                label: 'Relationship to Guardian',
                value: _selectedGsisRelationship,
                items: ['Father', 'Mother', 'Grandfather', 'Grandmother', 'Brother', 'Sister', 'Friend', 'Colleague', 'Spouse', 'Partner'],
                onChanged: (value) => setState(() => _selectedGsisRelationship = value!),
              ),
            ],
            const SizedBox(height: 16),
            
            _buildDropdownField(
              label: 'Beneficiary Status',
              value: _selectedBeneficiaryStatus,
              items: ['Living together', 'Solo Parent', 'Separated', 'Senior Citizen', 'Sugar Plantation Worker', 'Indigenous People', 'Displaced Worker', 'Local', 'OFW', 'Rebel Returnee', 'Victims of Armed Conflicts', 'Person with Disability'],
              onChanged: (value) => setState(() => _selectedBeneficiaryStatus = value!),
            ),
            const SizedBox(height: 24),
            
            // Mother Information
            const Text(
              'Mother\'s Information',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            
            _buildTextFormField(
              controller: _motherFirstNameController,
              label: 'Mother\'s First Name',
              hint: 'Enter mother\'s first name',
              isRequired: true,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                LengthLimitingTextInputFormatter(100),
              ],
            ),
            const SizedBox(height: 16),
                                 
            _buildTextFormField(
              controller: _motherMiddleNameController,
              label: 'Mother\'s Middle Name',
              hint: 'Enter mother\'s middle name (optional)',
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                LengthLimitingTextInputFormatter(100),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextFormField(
              controller: _motherLastNameController,
              label: 'Mother\'s Last Name',
              hint: 'Enter mother\'s last name',
              isRequired: true,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                LengthLimitingTextInputFormatter(100),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildDropdownField(
              label: 'Mother\'s Suffix',
              value: _motherSuffixController.text.isEmpty ? 'None' : _motherSuffixController.text,
              items: ['None', 'Jr', 'Sr', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'],
              onChanged: (value) {
                setState(() {
                  _motherSuffixController.text = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _motherOccupationController,
              label: 'Mother\'s Occupation',
              hint: 'Enter mother\'s occupation',
              isRequired: true,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _motherContactController,
              label: 'Mother\'s Contact Number',
              hint: 'Enter mother\'s contact number',
              isRequired: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Mother\'s contact number is required';
                }
                if (value.length != 11) {
                  return 'Contact number must be exactly 11 digits';
                }
                if (!value.startsWith('09')) {
                  return 'Contact number must start with 09';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Father Information
            const Text(
              'Father\'s Information',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            
            _buildTextFormField(
              controller: _fatherFirstNameController,
              label: 'Father\'s First Name',
              hint: 'Enter father\'s first name',
              isRequired: true,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                LengthLimitingTextInputFormatter(100),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextFormField(
              controller: _fatherMiddleNameController,
              label: 'Father\'s Middle Name',
              hint: 'Enter father\'s middle name (optional)',
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                LengthLimitingTextInputFormatter(100),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _fatherLastNameController,
              label: 'Father\'s Last Name',
              hint: 'Enter father\'s last name',
              isRequired: true,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                LengthLimitingTextInputFormatter(100),
              ],
            ),
            const SizedBox(height: 16),                      
            
            _buildDropdownField(
              label: 'Father\'s Suffix',
              value: _fatherSuffixController.text.isEmpty ? 'None' : _fatherSuffixController.text,
              items: ['None', 'Jr', 'Sr', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'],
              onChanged: (value) {
                setState(() {
                  _fatherSuffixController.text = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _fatherOccupationController,
              label: 'Father\'s Occupation',
              hint: 'Enter father\'s occupation',
              isRequired: true,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _fatherContactController,
              label: 'Father\'s Contact Number',
              hint: 'Enter father\'s contact number',
              isRequired: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Father\'s contact number is required';
                }
                if (value.length != 11) {
                  return 'Contact number must be exactly 11 digits';
                }
                if (!value.startsWith('09')) {
                  return 'Contact number must start with 09';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // Education Information Form
  Widget _buildEducationInformationForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _educationFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Education Information',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your educational background',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Elementary Education
            const Text(
              'Elementary Education',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            
            _buildTextFormField(
              controller: _elementarySchoolController,
              label: 'School Name',
              hint: 'Enter elementary school name',
              isRequired: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _elementaryDegreeController,
              label: 'Degree/Course',
              hint: 'Elementary Graduate',
              isRequired: true,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _elementaryYearLvlController,
              label: 'Year Level',
              hint: 'Grade 6',
              isRequired: true,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _elementaryDateAttendedController,
              label: 'Date Attended',
              hint: '2010-2016',
              isRequired: true,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
            ),
            const SizedBox(height: 24),
            
            // Secondary Education
            const Text(
              'Secondary Education',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            
            _buildTextFormField(
              controller: _secondarySchoolController,
              label: 'School Name',
              hint: 'Enter secondary school name',
              isRequired: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            
            _buildDropdownField(
              label: 'Degree/Course',
              value: _selectedSecondaryDegree,
              items: ['Junior High Graduate', 'High School Graduate'],
              onChanged: (value) {
                setState(() {
                  _selectedSecondaryDegree = value!;
                  _secondaryDegreeController.text = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            _buildDropdownField(
              label: 'Year Level',
              value: _selectedSecondaryYearLevel,
              items: ['Grade 11', 'Grade 12', 'Graduated'],
              onChanged: (value) {
                setState(() {
                  _selectedSecondaryYearLevel = value!;
                  _secondaryYearLvlController.text = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _secondaryDateAttendedController,
              label: 'Date Attended',
              hint: '2016-2022',
              isRequired: true,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
            ),
            const SizedBox(height: 24),
            
            // Tertiary Education (Optional)
            const Text(
              'Tertiary Education (Optional)',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            
            _buildTextFormField(
              controller: _tertiarySchoolController,
              label: 'School Name',
              hint: 'Enter college/university name',
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _tertiaryDegreeController,
              label: 'Degree/Course',
              hint: 'Bachelor of Science',
              textCapitalization: TextCapitalization.words,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
            ),
            const SizedBox(height: 16),
            
            _buildDropdownField(
              label: 'Year Level',
              value: _selectedTertiaryYearLevel,
              items: ['1st Year', '2nd Year', '3rd Year', '4th Year'],
              onChanged: (value) {
                setState(() {
                  _selectedTertiaryYearLevel = value!;
                  _tertiaryYearLvlController.text = value;
                });
              },
              isRequired: false,
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _tertiaryDateAttendedController,
              label: 'Date Attended',
              hint: '2022-Present or 2018-2022',
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
            ),
            const SizedBox(height: 24),
            
            // Technical Vocational Education (Optional)
            const Text(
              'Technical Vocational Education (Optional)',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            
            _buildTextFormField(
              controller: _techvocSchoolController,
              label: 'School Name',
              hint: 'Enter technical/vocational school name',
              textCapitalization: TextCapitalization.words,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _techvocDegreeController,
              label: 'Course/Program',
              hint: 'Computer Programming, Culinary Arts, etc.',
              textCapitalization: TextCapitalization.words,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _techvocYearLvlController,
              label: 'Year Level',
              hint: 'Certificate Level, NC I, NC II, etc.',
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
            ),
            const SizedBox(height: 16),
            
            _buildTextFormField(
              controller: _techvocDateAttendedController,
              label: 'Date Attended',
              hint: '2020-2021',
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build text form fields
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
    IconData? suffixIcon,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textInputAction: textInputAction ?? (maxLines == 1 ? TextInputAction.next : TextInputAction.newline),
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        hintText: hint,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: const Color(0xFF2563EB)) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator ?? (isRequired ? (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      } : null),
    );
  }

  // Helper method to build dropdown fields
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
