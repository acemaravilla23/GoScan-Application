import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';

class ContactInfoScreen extends StatefulWidget {
  const ContactInfoScreen({super.key});

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  bool _loading = true;
  bool _saving = false;

  final TextEditingController _phone = TextEditingController();
  final TextEditingController _socmed = TextEditingController();
  final TextEditingController _socmedName = TextEditingController();
  final TextEditingController _houseNo = TextEditingController();
  final TextEditingController _barangay = TextEditingController();
  final TextEditingController _municipality = TextEditingController();
  final TextEditingController _province = TextEditingController();
  final TextEditingController _region = TextEditingController();
  final TextEditingController _postalCode = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return;
      final res = await ApiService.get('/profile/contact?email=${Uri.encodeComponent(user.email)}');
      if (res['success'] == true && res['data'] != null) {
        final d = res['data'];
        _phone.text = d['phone'] ?? '';
        _socmed.text = d['socmed'] ?? '';
        _socmedName.text = d['socmed_name'] ?? '';
        _houseNo.text = d['house_no'] ?? '';
        _barangay.text = d['barangay'] ?? '';
        _municipality.text = d['municipality'] ?? '';
        _province.text = d['province'] ?? '';
        _region.text = d['region'] ?? '';
        _postalCode.text = d['postal_code'] ?? '';
      }
    } catch (e) {
      _showError('Error loading contact info: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_phone.text.trim().isEmpty ||
        _socmed.text.trim().isEmpty ||
        _socmedName.text.trim().isEmpty ||
        _houseNo.text.trim().isEmpty ||
        _barangay.text.trim().isEmpty ||
        _municipality.text.trim().isEmpty ||
        _province.text.trim().isEmpty ||
        _region.text.trim().isEmpty ||
        _postalCode.text.trim().isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _saving = true);
    try {
      final user = AuthService.currentUser;
      if (user == null) return;
      final payload = {
        'email': user.email,
        'phone': _phone.text.trim(),
        'socmed': _socmed.text.trim(),
        'socmed_name': _socmedName.text.trim(),
        'house_no': _houseNo.text.trim(),
        'barangay': _barangay.text.trim(),
        'municipality': _municipality.text.trim(),
        'province': _province.text.trim(),
        'region': _region.text.trim(),
        'postal_code': _postalCode.text.trim(),
      };
      final res = await ApiService.post('/profile/update-contact', payload);
      if (res['success'] == true) {
        _showSuccess('Contact information saved');
        Navigator.of(context).pop();
      } else {
        _showError(res['message'] ?? 'Failed to save contact information');
      }
    } catch (e) {
      _showError('Error saving contact info: $e');
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
          'Contact Information',
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
                        children: [
                          _field('Phone Number', _phone, keyboardType: TextInputType.phone, maxLen: 20),
                          const SizedBox(height: 16),
                          _field('Social Media', _socmed, maxLen: 100),
                          const SizedBox(height: 16),
                          _field('Social Media Username', _socmedName, maxLen: 100),
                          const SizedBox(height: 16),
                          _field('House No.', _houseNo, maxLen: 100),
                          const SizedBox(height: 16),
                          _field('Barangay', _barangay, maxLen: 100),
                          const SizedBox(height: 16),
                          _field('Municipality', _municipality, maxLen: 100),
                          const SizedBox(height: 16),
                          _field('Province', _province, maxLen: 100),
                          const SizedBox(height: 16),
                          _field('Region', _region, maxLen: 100),
                          const SizedBox(height: 16),
                          _field('Postal Code', _postalCode, keyboardType: TextInputType.number, maxLen: 10),
                        ],
                      ),
                    ),
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

  Widget _field(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, int? maxLen}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLen,
          decoration: InputDecoration(
            hintText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            counterText: '',
          ),
        )
      ],
    );
  }
}


