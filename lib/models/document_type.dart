class DocumentType {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> requiredFields;

  const DocumentType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredFields,
  });

  static const List<DocumentType> availableTypes = [
    DocumentType(
      id: 'application_form',
      name: 'SPES Application Form',
      description: 'Choose Document',
      icon: '📋',
      requiredFields: [
        'surname',
        'first_name',
        'middle_name',
        'date_of_birth',
        'contact_details',
        'email_address',
        'present_address',
        'permanent_address',
        'father_name_contact',
        'mother_name_contact',
        'elementary_school',
        'secondary_school',
        'tertiary_school',
      ],
    ),
    DocumentType(
      id: 'employment_certificate',
      name: 'Certificate of Employment',
      description: 'Choose Document',
      icon: '💼',
      requiredFields: [
        'employee_name',
        'company_name',
        'position',
        'employment_date',
        'signature',
      ],
    ),
    DocumentType(
      id: 'school_certification',
      name: 'School Certification',
      description: 'Choose Document',
      icon: '🎓',
      requiredFields: [
        'student_name',
        'school_name',
        'course',
        'year_level',
        'academic_year',
      ],
    ),
    DocumentType(
      id: 'endorsement_renewal',
      name: 'Endorsement Renewal',
      description: 'Choose Document',
      icon: '🔄',
      requiredFields: [
        'scholar_name',
        'spes_id',
        'batch',
        'renewal_date',
        'signature',
      ],
    ),
    DocumentType(
      id: 'rules_undertaking',
      name: 'Rules & Undertaking',
      description: 'Choose Document',
      icon: '📜',
      requiredFields: [
        'applicant_name',
        'signature',
        'date_signed',
        'witness_signature',
      ],
    ),
  ];

  static DocumentType? getById(String id) {
    try {
      return availableTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }
}