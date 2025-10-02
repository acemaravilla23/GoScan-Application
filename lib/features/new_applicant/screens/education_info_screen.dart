import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/api_service.dart';

class EducationInfoScreen extends StatefulWidget {
  const EducationInfoScreen({super.key});

  @override
  State<EducationInfoScreen> createState() => _EducationInfoScreenState();
}

class _EducationInfoScreenState extends State<EducationInfoScreen> {
  bool _loading = true;
  bool _saving = false;

  // Elementary
  final TextEditingController _elemSchool = TextEditingController();
  final TextEditingController _elemDegree = TextEditingController();
  final TextEditingController _elemYearLvl = TextEditingController();
  DateTime? _elemDateAttended;

  // Secondary
  final TextEditingController _secSchool = TextEditingController();
  final TextEditingController _secDegree = TextEditingController();
  final TextEditingController _secYearLvl = TextEditingController();
  DateTime? _secDateAttended;

  // Tertiary (optional)
  final TextEditingController _terSchool = TextEditingController();
  final TextEditingController _terDegree = TextEditingController();
  final TextEditingController _terYearLvl = TextEditingController();
  DateTime? _terDateAttended;

  // Techvoc (optional)
  final TextEditingController _tvSchool = TextEditingController();
  final TextEditingController _tvDegree = TextEditingController();
  final TextEditingController _tvYearLvl = TextEditingController();
  DateTime? _tvDateAttended;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return;
      final res = await ApiService.get('/profile/education?email=${Uri.encodeComponent(user.email)}');
      if (res['success'] == true && res['data'] != null) {
        final d = res['data'];
        final elem = d['elementary'] ?? {};
        _elemSchool.text = elem['school'] ?? '';
        _elemDegree.text = elem['degree'] ?? '';
        _elemYearLvl.text = elem['year_lvl'] ?? '';
        if (elem['date_attended'] != null) _elemDateAttended = DateTime.tryParse(elem['date_attended']);

        final sec = d['secondary'] ?? {};
        _secSchool.text = sec['school'] ?? '';
        _secDegree.text = sec['degree'] ?? '';
        _secYearLvl.text = sec['year_lvl'] ?? '';
        if (sec['date_attended'] != null) _secDateAttended = DateTime.tryParse(sec['date_attended']);

        final ter = d['tertiary'] ?? {};
        _terSchool.text = ter['school'] ?? '';
        _terDegree.text = ter['degree'] ?? '';
        _terYearLvl.text = ter['year_lvl'] ?? '';
        if (ter['date_attended'] != null) _terDateAttended = DateTime.tryParse(ter['date_attended']);

        final tv = d['techvoc'] ?? {};
        _tvSchool.text = tv['school'] ?? '';
        _tvDegree.text = tv['degree'] ?? '';
        _tvYearLvl.text = tv['year_lvl'] ?? '';
        if (tv['date_attended'] != null) _tvDateAttended = DateTime.tryParse(tv['date_attended']);
      }
    } catch (e) {
      _showError('Error loading education info: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_elemSchool.text.trim().isEmpty ||
        _elemDegree.text.trim().isEmpty ||
        _elemYearLvl.text.trim().isEmpty ||
        _elemDateAttended == null ||
        _secSchool.text.trim().isEmpty ||
        _secDegree.text.trim().isEmpty ||
        _secYearLvl.text.trim().isEmpty ||
        _secDateAttended == null) {
      _showError('Please fill in required elementary and secondary fields');
      return;
    }

    setState(() => _saving = true);
    try {
      final user = AuthService.currentUser;
      if (user == null) return;
      final payload = {
        'email': user.email,
        'elementary_school': _elemSchool.text.trim(),
        'elementary_degree': _elemDegree.text.trim(),
        'elementary_year_lvl': _elemYearLvl.text.trim(),
        'elementary_date_attended': _elemDateAttended!.toIso8601String().split('T')[0],
        'secondary_school': _secSchool.text.trim(),
        'secondary_degree': _secDegree.text.trim(),
        'secondary_year_lvl': _secYearLvl.text.trim(),
        'secondary_date_attended': _secDateAttended!.toIso8601String().split('T')[0],
        'tertiary_school': _terSchool.text.trim().isEmpty ? null : _terSchool.text.trim(),
        'tertiary_degree': _terDegree.text.trim().isEmpty ? null : _terDegree.text.trim(),
        'tertiary_year_lvl': _terYearLvl.text.trim().isEmpty ? null : _terYearLvl.text.trim(),
        'tertiary_date_attended': _terDateAttended == null ? null : _terDateAttended!.toIso8601String().split('T')[0],
        'techvoc_school': _tvSchool.text.trim().isEmpty ? null : _tvSchool.text.trim(),
        'techvoc_degree': _tvDegree.text.trim().isEmpty ? null : _tvDegree.text.trim(),
        'techvoc_year_lvl': _tvYearLvl.text.trim().isEmpty ? null : _tvYearLvl.text.trim(),
        'techvoc_date_attended': _tvDateAttended == null ? null : _tvDateAttended!.toIso8601String().split('T')[0],
      };
      final res = await ApiService.post('/profile/update-education', payload);
      if (res['success'] == true) {
        _showSuccess('Education information saved');
        Navigator.of(context).pop();
      } else {
        _showError(res['message'] ?? 'Failed to save education information');
      }
    } catch (e) {
      _showError('Error saving education info: $e');
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
          'Education Information',
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
                    _section('Elementary', [
              _field('School', _elemSchool),
              _gap(),
              _field('Degree', _elemDegree),
              _gap(),
              _field('Year Level', _elemYearLvl),
              _gap(),
              _date('Date Attended', _elemDateAttended, (d) => setState(() => _elemDateAttended = d)),
            ]),
            _space(),
            _section('Secondary', [
              _field('School', _secSchool),
              _gap(),
              _field('Degree', _secDegree),
              _gap(),
              _field('Year Level', _secYearLvl),
              _gap(),
              _date('Date Attended', _secDateAttended, (d) => setState(() => _secDateAttended = d)),
            ]),
            _space(),
            _section('Tertiary (optional)', [
              _field('School', _terSchool),
              _gap(),
              _field('Degree', _terDegree),
              _gap(),
              _field('Year Level', _terYearLvl),
              _gap(),
              _date('Date Attended', _terDateAttended, (d) => setState(() => _terDateAttended = d)),
            ]),
            _space(),
            _section('Techvoc (optional)', [
              _field('School', _tvSchool),
              _gap(),
              _field('Degree', _tvDegree),
              _gap(),
              _field('Year Level', _tvYearLvl),
              _gap(),
              _date('Date Attended', _tvDateAttended, (d) => setState(() => _tvDateAttended = d)),
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

  Widget _space() => const SizedBox(height: 24);
  Widget _gap() => const SizedBox(height: 12);

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _field(String label, TextEditingController controller) {
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
          ),
        )
      ],
    );
  }

  Widget _date(String label, DateTime? value, ValueChanged<DateTime?> onChanged) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: value ?? DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime.now().add(const Duration(days: 3650)));
        if (picked != null) onChanged(picked);
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            hintText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          controller: TextEditingController(text: value == null ? '' : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'),
        ),
      ),
    );
  }
}


