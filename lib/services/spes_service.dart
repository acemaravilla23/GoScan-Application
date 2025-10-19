import 'api_service.dart';

class SpesService {
  // Get SPES program status
  static Future<SpesStatus> getSpesStatus() async {
    try {
      final response = await ApiService.get('/scholarship/status');

      if (response['success'] == true) {
        // Debug logging
        print('SPES Status API Response: ${response['data']}');
        if (response['data']['debug'] != null) {
          print('Debug Info: ${response['data']['debug']}');
        }
        
        return SpesStatus.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to get SPES status');
      }
    } catch (e) {
      throw Exception('Failed to get SPES status: $e');
    }
  }

  // Check for existing application
  static Future<ApplicationCheckResult> checkExistingApplication(String email) async {
    try {
      final response = await ApiService.get('/scholarship/check-application?email=$email');

      if (response['success'] == true) {
        return ApplicationCheckResult.success(
          hasApplication: response['has_application'] ?? false,
          applicationStatus: response['application_status'],
          examStatus: response['exam_status'],
          interviewStatus: response['interview_status'],
          classification: response['classification'],
          batch: response['batch'],
          district: response['district'],
          academicYear: response['academic_year'],
          message: response['message'],
          examDetails: response['exam_details'],
          interviewDetails: response['interview_details'],
          submittedAt: response['submitted_at'],
          spesId: response['spes_id'],
          spesBatch: response['spes_batch'],
          spesStatus: response['spes_status'],
          isSpes: response['is_spes'] ?? false,
          orientationDetails: response['orientation_details'],
        );
      } else {
        return ApplicationCheckResult.error(response['message'] ?? 'Failed to check application');
      }
    } on ApiException catch (e) {
      return ApplicationCheckResult.error(e.getAllErrors());
    } catch (e) {
      return ApplicationCheckResult.error('An unexpected error occurred: $e');
    }
  }

  // Submit SPES application
  static Future<ApplicationResult> submitApplication(Map<String, dynamic> applicationData) async {
    try {
      final response = await ApiService.post('/scholarship/apply', applicationData);

      // Debug logging (remove in production)
      print('API Response - Success: ${response['success']}, Message: ${response['message']}');

      if (response['success'] == true) {
        // Safely extract data with proper null checking and type conversion
        final data = response['data'] as Map<String, dynamic>?;
        return ApplicationResult.success(
          applicationId: data?['application_id']?.toString(),
          status: data?['status']?.toString(),
          message: response['message']?.toString() ?? 'Application submitted successfully!',
        );
      } else {
        return ApplicationResult.error(response['message']?.toString() ?? 'Application failed');
      }
    } on ApiException catch (e) {
      return ApplicationResult.error(e.getAllErrors());
    } catch (e) {
      return ApplicationResult.error('An unexpected error occurred: $e');
    }
  }
}

// SPES status model
class SpesStatus {
  final bool hasOngoingBatch;
  final bool isApplicationOpen;
  final String? currentBatch;
  final ApplicationDistrict? localApplication;
  final ApplicationDistrict? provincialApplication;
  final String? message;

  SpesStatus({
    required this.hasOngoingBatch,
    required this.isApplicationOpen,
    this.currentBatch,
    this.localApplication,
    this.provincialApplication,
    this.message,
  });

  factory SpesStatus.fromJson(Map<String, dynamic> json) {
    return SpesStatus(
      hasOngoingBatch: json['has_ongoing_batch'] ?? false,
      isApplicationOpen: json['is_application_open'] ?? false,
      currentBatch: json['current_batch'],
      localApplication: json['local_application'] != null 
          ? ApplicationDistrict.fromJson(json['local_application']) 
          : null,
      provincialApplication: json['provincial_application'] != null 
          ? ApplicationDistrict.fromJson(json['provincial_application']) 
          : null,
      message: json['message'],
    );
  }
}

class ApplicationDistrict {
  final bool isOpen;
  final String? period;
  final String? startDate;
  final String? endDate;
  final String? batch;

  ApplicationDistrict({
    required this.isOpen,
    this.period,
    this.startDate,
    this.endDate,
    this.batch,
  });

  factory ApplicationDistrict.fromJson(Map<String, dynamic> json) {
    return ApplicationDistrict(
      isOpen: json['is_open'] ?? false,
      period: json['period'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      batch: json['batch'],
    );
  }
}

// Application check result model
class ApplicationCheckResult {
  final bool isSuccess;
  final String? error;
  final bool? hasApplication;
  final String? applicationStatus;
  final String? examStatus;
  final String? interviewStatus;
  final String? classification;
  final String? batch;
  final String? district;
  final String? academicYear;
  final String? message;
  final ExamDetails? examDetails;
  final InterviewDetails? interviewDetails;
  final String? submittedAt;
  final String? spesId;
  final String? spesBatch;
  final String? spesStatus;
  final bool isSpes;
  final Map<String, dynamic>? orientationDetails;

  ApplicationCheckResult._({
    required this.isSuccess,
    this.error,
    this.hasApplication,
    this.applicationStatus,
    this.examStatus,
    this.interviewStatus,
    this.classification,
    this.batch,
    this.district,
    this.academicYear,
    this.message,
    this.examDetails,
    this.interviewDetails,
    this.submittedAt,
    this.spesId,
    this.spesBatch,
    this.spesStatus,
    this.isSpes = false,
    this.orientationDetails,
  });

  factory ApplicationCheckResult.success({
    bool? hasApplication,
    String? applicationStatus,
    String? examStatus,
    String? interviewStatus,
    String? classification,
    String? batch,
    String? district,
    String? academicYear,
    String? message,
    Map<String, dynamic>? examDetails,
    Map<String, dynamic>? interviewDetails,
    String? submittedAt,
    String? spesId,
    String? spesBatch,
    String? spesStatus,
    bool? isSpes,
    Map<String, dynamic>? orientationDetails,
  }) {
    return ApplicationCheckResult._(
      isSuccess: true,
      hasApplication: hasApplication,
      applicationStatus: applicationStatus,
      examStatus: examStatus,
      interviewStatus: interviewStatus,
      classification: classification,
      batch: batch,
      district: district,
      academicYear: academicYear,
      message: message,
      examDetails: examDetails != null ? ExamDetails.fromJson(examDetails) : null,
      interviewDetails: interviewDetails != null ? InterviewDetails.fromJson(interviewDetails) : null,
      submittedAt: submittedAt,
      spesId: spesId,
      spesBatch: spesBatch,
      spesStatus: spesStatus,
      isSpes: isSpes ?? false,
      orientationDetails: orientationDetails,
    );
  }

  factory ApplicationCheckResult.error(String error) {
    return ApplicationCheckResult._(
      isSuccess: false,
      error: error,
    );
  }
}

// Exam details model
class ExamDetails {
  final String? schedule;
  final String? location;
  final String? results;

  ExamDetails({
    this.schedule,
    this.location,
    this.results,
  });

  factory ExamDetails.fromJson(Map<String, dynamic> json) {
    return ExamDetails(
      schedule: json['schedule'],
      location: json['location'],
      results: json['results'],
    );
  }
}

// Interview details model
class InterviewDetails {
  final String? schedule;
  final String? location;
  final String? results;

  InterviewDetails({
    this.schedule,
    this.location,
    this.results,
  });

  factory InterviewDetails.fromJson(Map<String, dynamic> json) {
    return InterviewDetails(
      schedule: json['schedule'],
      location: json['location'],
      results: json['results'],
    );
  }
}

// Application result model
class ApplicationResult {
  final bool isSuccess;
  final String? error;
  final String? applicationId;
  final String? status;
  final String? message;

  ApplicationResult._({
    required this.isSuccess,
    this.error,
    this.applicationId,
    this.status,
    this.message,
  });

  factory ApplicationResult.success({
    String? applicationId,
    String? status,
    String? message,
  }) {
    return ApplicationResult._(
      isSuccess: true,
      applicationId: applicationId,
      status: status,
      message: message,
    );
  }

  factory ApplicationResult.error(String error) {
    return ApplicationResult._(
      isSuccess: false,
      error: error,
    );
  }
}

