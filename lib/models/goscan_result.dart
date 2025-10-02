class GoScanResult {
  final bool isValid;
  final String documentType;
  final double confidence;
  final double templateMatchScore;
  final List<ExtractedField> extractedFields;
  final List<String> missingFields;
  final List<String> validationErrors;
  final Map<String, dynamic>? imageProcessing;
  final double processingTime;

  const GoScanResult({
    required this.isValid,
    required this.documentType,
    required this.confidence,
    required this.templateMatchScore,
    required this.extractedFields,
    required this.missingFields,
    required this.validationErrors,
    this.imageProcessing,
    required this.processingTime,
  });

  factory GoScanResult.fromJson(Map<String, dynamic> json) {
    final verificationResult = json['verification_result'] as Map<String, dynamic>? ?? {};
    
    return GoScanResult(
      isValid: verificationResult['is_valid'] as bool? ?? false,
      documentType: verificationResult['document_type'] as String? ?? 'unknown',
      confidence: (verificationResult['confidence'] as num?)?.toDouble() ?? 0.0,
      templateMatchScore: (verificationResult['template_match_score'] as num?)?.toDouble() ?? 0.0,
      extractedFields: (verificationResult['extracted_fields'] as List<dynamic>? ?? [])
          .map((field) => ExtractedField.fromJson(field as Map<String, dynamic>))
          .toList(),
      missingFields: (verificationResult['missing_fields'] as List<dynamic>? ?? [])
          .map((field) => field.toString())
          .toList(),
      validationErrors: (verificationResult['validation_errors'] as List<dynamic>? ?? [])
          .map((error) => error.toString())
          .toList(),
      imageProcessing: json['image_processing'] as Map<String, dynamic>?,
      processingTime: (json['processing_time'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_valid': isValid,
      'document_type': documentType,
      'confidence': confidence,
      'template_match_score': templateMatchScore,
      'extracted_fields': extractedFields.map((field) => field.toJson()).toList(),
      'missing_fields': missingFields,
      'validation_errors': validationErrors,
      'image_processing': imageProcessing,
      'processing_time': processingTime,
    };
  }
}

class ExtractedField {
  final String fieldName;
  final String value;
  final double confidence;
  final bool isRequired;
  final bool isFilled;

  const ExtractedField({
    required this.fieldName,
    required this.value,
    required this.confidence,
    required this.isRequired,
    required this.isFilled,
  });

  factory ExtractedField.fromJson(Map<String, dynamic> json) {
    return ExtractedField(
      fieldName: json['field_name'] as String? ?? '',
      value: json['value'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      isRequired: json['is_required'] as bool? ?? false,
      isFilled: json['is_filled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field_name': fieldName,
      'value': value,
      'confidence': confidence,
      'is_required': isRequired,
      'is_filled': isFilled,
    };
  }
}