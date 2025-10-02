import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';

class FamilyInfoScreen extends StatefulWidget {
  const FamilyInfoScreen({super.key});

  @override
  State<FamilyInfoScreen> createState() => _FamilyInfoScreenState();
}

class _FamilyInfoScreenState extends State<FamilyInfoScreen> {
  bool _loading = true;
  bool _saving = false;

  final TextEditingController _gsisBeneficiary = TextEditingController();
  final TextEditingController _gsisRelationship = TextEditingController();
  String? _beneficiaryStatus;

  // Mother
  final TextEditingController _motherFirst = TextEditingController();
  final TextEditingController _motherMiddle = TextEditingController();
  final TextEditingController _motherLast = TextEditingController();
  final TextEditingController _motherSuffix = TextEditingController();
  final TextEditingController _motherContact = TextEditingController();
  final TextEditingController _motherOccupation = TextEditingController();
  // Father
  final TextEditingController _fatherFirst = TextEditingController();
  final TextEditingController _fatherMiddle = TextEditingController();
  final TextEditingController _fatherLast = TextEditingController();
  final TextEditingController _fatherSuffix = TextEditingController();
  final TextEditingController _fatherContact = TextEditingController();
  final TextEditingController _fatherOccupation = TextEditingController();

  final List<String> _beneficiaryOptions = const [
    'Living together',
    'Separated',
    'Solo Parent',
    'Deceased',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return;
      final res = await ApiService.get('/profile/family?email=${Uri.encodeComponent(user.email)}');
      if (res['success'] == true && res['data'] != null) {
        final d = res['data'];
        _gsisBeneficiary.text = d['gsis_beneficiary'] ?? '';
        _gsisRelationship.text = d['gsis_relationship'] ?? '';
        final loadedStatus = d['beneficiary_status'];
        _beneficiaryStatus = _beneficiaryOptions.contains(loadedStatus) ? loadedStatus : null;
        final mother = d['mother'] ?? {};
        _motherFirst.text = mother['firstname'] ?? '';
        _motherMiddle.text = mother['middle'] ?? '';
        _motherLast.text = mother['lastname'] ?? '';
        _motherSuffix.text = mother['suffix'] ?? '';
        _motherContact.text = mother['contact'] ?? '';
        _motherOccupation.text = mother['occupation'] ?? '';
        final father = d['father'] ?? {};
        _fatherFirst.text = father['firstname'] ?? '';
        _fatherMiddle.text = father['middle'] ?? '';
        _fatherLast.text = father['lastname'] ?? '';
        _fatherSuffix.text = father['suffix'] ?? '';
        _fatherContact.text = father['contact'] ?? '';
        _fatherOccupation.text = father['occupation'] ?? '';
      }
    } catch (e) {
      _showError('Error loading family info: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_gsisBeneficiary.text.trim().isEmpty ||
        _gsisRelationship.text.trim().isEmpty ||
        (_beneficiaryStatus == null || _beneficiaryStatus!.isEmpty) ||
        _motherFirst.text.trim().isEmpty ||
        _motherLast.text.trim().isEmpty ||
        _motherOccupation.text.trim().isEmpty ||
        _fatherFirst.text.trim().isEmpty ||
        _fatherLast.text.trim().isEmpty ||
        _fatherOccupation.text.trim().isEmpty) {
      _showError('Please fill in required fields');
      return;
    }

    setState(() => _saving = true);
    try {
      final user = AuthService.currentUser;
      if (user == null) return;
      final payload = {
        'email': user.email,
        'gsis_beneficiary': _gsisBeneficiary.text.trim(),
        'gsis_relationship': _gsisRelationship.text.trim(),
        'beneficiary_status': _beneficiaryStatus,
        'mother_firstname': _motherFirst.text.trim(),
        'mother_lastname': _motherLast.text.trim(),
        'mother_middle': _motherMiddle.text.trim(),
        'mother_suffix': _motherSuffix.text.trim(),
        'mother_contact': _motherContact.text.trim(),
        'mother_occupation': _motherOccupation.text.trim(),
        'father_firstname': _fatherFirst.text.trim(),
        'father_lastname': _fatherLast.text.trim(),
        'father_middle': _fatherMiddle.text.trim(),
        'father_suffix': _fatherSuffix.text.trim(),
        'father_contact': _fatherContact.text.trim(),
        'father_occupation': _fatherOccupation.text.trim(),
      };
      final res = await ApiService.post('/profile/update-family', payload);
      if (res['success'] == true) {
        _showSuccess('Family information saved');
        Navigator.of(context).pop();
      } else {
        _showError(res['message'] ?? 'Failed to save family information');
      }
    } catch (e) {
      _showError('Error saving family info: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
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
          'Family Information',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
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
                          _field('GSIS Beneficiary', _gsisBeneficiary, maxLen: 200),
                          const SizedBox(height: 16),
                          _field('Relationship', _gsisRelationship, maxLen: 100),
                          const SizedBox(height: 16),
                          _dropdown('Beneficiary Status', _beneficiaryStatus, _beneficiaryOptions, (v) => setState(() => _beneficiaryStatus = v)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _cardSection('Mother', [
                      _field('Firstname', _motherFirst, maxLen: 100),
                      const SizedBox(height: 12),
                      _field('Middlename', _motherMiddle, maxLen: 100),
                      const SizedBox(height: 12),
                      _field('Lastname', _motherLast, maxLen: 100),
                      const SizedBox(height: 12),
                      _field('Suffix', _motherSuffix, maxLen: 10),
                      const SizedBox(height: 12),
                      _field('Contact', _motherContact, maxLen: 30),
                      const SizedBox(height: 12),
                      _field('Occupation', _motherOccupation, maxLen: 100),
                    ]),
                    const SizedBox(height: 16),
                    _cardSection('Father', [
                      _field('Firstname', _fatherFirst, maxLen: 100),
                      const SizedBox(height: 12),
                      _field('Middlename', _fatherMiddle, maxLen: 100),
                      const SizedBox(height: 12),
                      _field('Lastname', _fatherLast, maxLen: 100),
                      const SizedBox(height: 12),
                      _field('Suffix', _fatherSuffix, maxLen: 10),
                      const SizedBox(height: 12),
                      _field('Contact', _fatherContact, maxLen: 30),
                      const SizedBox(height: 12),
                      _field('Occupation', _fatherOccupation, maxLen: 100),
                    ]),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _field(String label, TextEditingController controller, {int? maxLen}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            counterText: '',
          ),
          maxLength: maxLen,
        )
      ],
    );
  }

  Widget _dropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : null,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Select $label',
          ),
        )
      ],
    );
  }
}


